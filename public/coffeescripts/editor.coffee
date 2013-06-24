
LS_KEY = "paircodr"

@localSetting = do ->
  ls = {}

  if localStorage[LS_KEY]
    try
      tmp = JSON.parse localStorage[LS_KEY]
      ls[key] = value for key, value of tmp
    catch e
      console.log e.message

  return {
    save: ->
      localStorage[LS_KEY] = JSON.stringify ls

    get: (key) ->
      if key then ls[key] else false

    set: (key, val) ->
      ls[key] = val
      localSetting.save()
  }

class Editor
  constructor: (@edit) ->
    @socket = io.connect()
    @id = @edit.data "id"

    @body = ""
    @cm = CodeMirror.fromTextArea @edit[0],
      mode: "ruby"
      theme: "lesser-dark"
      lineNumbers: true
      matchBrackets: true
      # lineWrapping: false
      autoCloseBrackets: true
      styleActiveLine: true
      onKeyEvent: (cm, e) =>
        if e.type is "keydown"
          @shortcutHandler(e)
        else if e.type is "keyup"
          @shortcutUpHandler(e)

    $(".CodeMirror,.CodeMirror-gutters").css
      "height": "100%"
      "-moz-box-sizing": "border-box"
      "box-sizing": "border-box"

    @cm.focus()

    @socket.on "connected", =>
      @socket.emit "code:join",
        id: @id
        user: "Anonymous"
        body: @edit.text()
        cursor: @cm.cursorCoords true, "local"


    @socket.on "code:joined", (data) =>
      @edit_flag = false
      @cm.setValue data
      @edit_flag = true

    @socket.on 'user:enter', (data) =>
      $.pnotify
        title: false
        text: "#{data.user} comes."
        height: ""
        delay: 1000
      cursor = $("<div/>")
      .addClass("CodeMirror-cursor cursor-#{data.socket_id}")
      .append("&nbsp;")
      .css
        position: "absolute"
        top: data.cursor.top-4
        left: data.cursor.left
        height: 16
      $(".CodeMirror-secondarycursor").after cursor

    @socket.on "user:exit", ->
      $.pnotify
        title: false
        text: "#{data.user} exits."
        height: ""
        delay: 1000
      $("cursor-#{data.socket_id}").remove()

    @socket.on "code:saved", (data) =>
      $(".code_title").text data.title
      $.pnotify
        title: false
        text: "Save."
        height: ""
        delay: 1000

    #### sync code ####
    @edit_flag = true

    @cm.on "change", (cm, change) =>
      if @edit_flag
        @update()
        @socket.emit "code:edit", {change: change, body: @body}

    @socket.on "code:edited", (change) =>
      @edit_flag = false
      @cm.replaceRange change.text, change.from, change.to
      if change.next
        @cm.replaceRange change.next.text, change.next.from

      @edit_flag = true

    ### sync cursor ###
    @cm.on "cursorActivity", (cm) =>
      @socket.emit "code:move", @cm.cursorCoords(true, "local")


    @socket.on "code:moved", (data) =>
      if $(".cursor-#{data.socket_id}").length is 0
        cursor = $("<div/>")
        .addClass("CodeMirror-cursor cursor-#{data.socket_id}")
        .append("&nbsp;")
        .css
          "position": "absolute"
          "top": data.cursor.top-4
          "left": data.cursor.left
          "height": 16
        $(".CodeMirror-secondarycursor").after cursor
      else
        $(".cursor-#{data.socket_id}").css
          top: data.cursor.top-4
          left: data.cursor.left


    # 閉じる前に確認 ---------
    # ページ遷移
    # $(window).on "beforeunload", =>
    #   @update()
    #   if @body isnt @saved_body
    #     return "文章が保存されていません。編集は破棄されます。"

  update: =>
    @cm.save() # textareaに保存するだけなので注意
    @body = @deleteTrailingSpace @cm.getValue()

  render: =>
    @update()
    @marked_body = @body

  save: =>
    @update()
    @socket.emit "code:save",
      id: @id
      title: $(".code_title").text()
      body: @body
    # $.ajax
    #   url: "https://api.github.com/gists"
    #   type: "post"

  deleteTrailingSpace: (text) ->
    text.replace(/\s*?\n/gi, "\n")

  shortcutHandler: (e) =>
    @isMod = true if e.keyCode is 18 # alt
    @isCtrl = true if e.keyCode is 17 # ctrl

    if @isCtrl is true and e.keyCode is 83 # ctrl + s
      e.preventDefault()
      @save()
      isCtrl = false

    if e.metaKey and e.keyCode is 83 # cmd + s
      e.preventDefault()
      @save()

  shortcutUpHandler: (e) =>
    @isMod = false if e.keyCode is 18
    @isCtrl = false if e.keyCode is 17


editor = new Editor $(".codemirror")

title_flag = false

$(document).on "click", ".code_title", ->
  title_flag = true
  div = $(this)
  input = $(".code_title_input")

  title = div.text()
  input.val title
  div.hide()
  input.show().focus()
  input[0].setSelectionRange(title.length, title.length);

.on "submit blur", ".code_title_form", (e) ->
  if title_flag
    e.preventDefault()
    div = $(".code_title")
    input = $(".code_title_input")
    title = input.val()
    div.text title
    input.hide()
    div.show()
    editor.save()
    title_flag = false
