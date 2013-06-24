!function(){var Editor,LS_KEY,editor,title_flag,__bind=function(fn,me){return function(){return fn.apply(me,arguments)}};LS_KEY="paircodr";this.localSetting=function(){var e,key,ls,tmp,value;ls={};if(localStorage[LS_KEY]){try{tmp=JSON.parse(localStorage[LS_KEY]);for(key in tmp){value=tmp[key];ls[key]=value}}catch(_error){e=_error;console.log(e.message)}}return{save:function(){return localStorage[LS_KEY]=JSON.stringify(ls)},get:function(key){if(key){return ls[key]}else{return false}},set:function(key,val){ls[key]=val;return localSetting.save()}}}();Editor=function(){function Editor(edit){var _this=this;this.edit=edit;this.shortcutUpHandler=__bind(this.shortcutUpHandler,this);this.shortcutHandler=__bind(this.shortcutHandler,this);this.save=__bind(this.save,this);this.render=__bind(this.render,this);this.update=__bind(this.update,this);this.socket=io.connect();this.id=this.edit.data("id");this.body="";this.cm=CodeMirror.fromTextArea(this.edit[0],{mode:"ruby",theme:"lesser-dark",lineNumbers:true,matchBrackets:true,autoCloseBrackets:true,styleActiveLine:true,onKeyEvent:function(cm,e){if(e.type==="keydown"){return _this.shortcutHandler(e)}else if(e.type==="keyup"){return _this.shortcutUpHandler(e)}}});$(".CodeMirror,.CodeMirror-gutters").css({height:"100%","-moz-box-sizing":"border-box","box-sizing":"border-box"});this.cm.focus();this.socket.on("connected",function(){return _this.socket.emit("code:join",{id:_this.id,user:"Anonymous",body:_this.edit.text(),cursor:_this.cm.cursorCoords(true,"local")})});this.socket.on("code:joined",function(data){_this.edit_flag=false;_this.cm.setValue(data);return _this.edit_flag=true});this.socket.on("user:enter",function(data){var cursor;$.pnotify({title:false,text:""+data.user+" comes.",height:"",delay:1e3});cursor=$("<div/>").addClass("CodeMirror-cursor cursor-"+data.socket_id).append("&nbsp;").css({position:"absolute",top:data.cursor.top-4,left:data.cursor.left,height:16});return $(".CodeMirror-secondarycursor").after(cursor)});this.socket.on("user:exit",function(data){$.pnotify({title:false,text:""+data.user+" exits.",height:"",delay:1e3});return $(".cursor-"+data.socket_id).remove()});this.socket.on("code:saved",function(data){$(".code_title").text(data.title);return $.pnotify({title:false,text:"Save.",height:"",delay:1e3})});this.edit_flag=true;this.cm.on("change",function(cm,change){if(_this.edit_flag){_this.update();return _this.socket.emit("code:edit",{change:change,body:_this.body})}});this.socket.on("code:edited",function(change){_this.edit_flag=false;_this.cm.replaceRange(change.text,change.from,change.to);if(change.next){_this.cm.replaceRange(change.next.text,change.next.from)}return _this.edit_flag=true});this.cm.on("cursorActivity",function(cm){return _this.socket.emit("code:move",_this.cm.cursorCoords(true,"local"))});this.socket.on("code:moved",function(data){var cursor;if($(".cursor-"+data.socket_id).length===0){cursor=$("<div/>").addClass("CodeMirror-cursor cursor-"+data.socket_id).append("&nbsp;").css({position:"absolute",top:data.cursor.top-4,left:data.cursor.left,height:16});return $(".CodeMirror-secondarycursor").after(cursor)}else{return $(".cursor-"+data.socket_id).css({top:data.cursor.top-4,left:data.cursor.left})}})}Editor.prototype.update=function(){this.cm.save();return this.body=this.deleteTrailingSpace(this.cm.getValue())};Editor.prototype.render=function(){this.update();return this.marked_body=this.body};Editor.prototype.save=function(){this.update();return this.socket.emit("code:save",{id:this.id,title:$(".code_title").text(),body:this.body})};Editor.prototype.deleteTrailingSpace=function(text){return text.replace(/\s*?\n/gi,"\n")};Editor.prototype.shortcutHandler=function(e){var isCtrl;if(e.keyCode===18){this.isMod=true}if(e.keyCode===17){this.isCtrl=true}if(this.isCtrl===true&&e.keyCode===83){e.preventDefault();this.save();isCtrl=false}if(e.metaKey&&e.keyCode===83){e.preventDefault();return this.save()}};Editor.prototype.shortcutUpHandler=function(e){if(e.keyCode===18){this.isMod=false}if(e.keyCode===17){return this.isCtrl=false}};return Editor}();editor=new Editor($(".codemirror"));title_flag=false;$(document).on("click",".code_title",function(){var div,input,title;title_flag=true;div=$(this);input=$(".code_title_input");title=div.text();input.val(title);div.hide();input.show().focus();return input[0].setSelectionRange(title.length,title.length)}).on("submit blur",".code_title_form",function(e){var div,input,title;if(title_flag){e.preventDefault();div=$(".code_title");input=$(".code_title_input");title=input.val();div.text(title);input.hide();div.show();editor.save();return title_flag=false}})}.call(this);