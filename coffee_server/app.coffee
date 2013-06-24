express = require 'express'
routes = require './routes.js'
haml = require 'hamljs'
io = require 'socket.io'
cons = require 'consolidate'
http = require 'http'
moment = require 'the_time.js'
partials = require 'express-partials'
app = express()

app.use partials()

app.configure ->
  app.set 'port', process.env.PORT || 4000
  app.set 'views', __dirname + '/views'

  # HAML
  app.engine 'haml', cons.haml
  app.set 'view engine', 'haml'

  # JADE
  #app.set 'view engine', 'jade'

  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use express.errorHandler()

# ROUTES
app.get '/', routes.index
app.get '/new', routes.new

app.get '/:id', routes.code

# START
http = http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

mongoose = require 'mongoose'
model = require "./model.js"
Code = model.Code

bodies = {}
counts = {}

io = io.listen http, {'leg level': 1}

io.sockets.on 'connection', (socket) ->
  console.log "connection ---------------------- #{socket.id}"
  socket.emit "connected"

  socket.on "code:join", (data) ->
    room = data.id
    socket.set "room", room
    socket.set "user", data.user
    data.socket_id = socket.id
    io.sockets.in(room).emit "user:enter", data
    socket.join room
    if counts[room]
      counts[room] = counts[room] + 1
      socket.emit "code:joined", bodies[room]
    else
      counts[room] = 1
      bodies[room] = data.body


  socket.on "code:edit", (data) ->
    room = ""
    socket.get "room", (err, _room) -> room = _room
    bodies[room] = data.body
    console.log bodies
    socket.broadcast.to(room).emit "code:edited", data.change

  socket.on "code:move", (cursor) ->
    room = ""
    socket.get "room", (err, _room) -> room = _room
    socket.broadcast.to(room).emit "code:moved",
      socket_id: socket.id
      cursor: cursor

  socket.on "code:save", (data) ->
    room = ""
    socket.get "room", (err, _room) -> room = _room
    Code.findById data.id, (err, code) ->
      console.log code
      return if err
      code.title = data.title
      code.body = data.body
      code.save (err) ->
        io.sockets.in(room).emit "code:saved", data

  socket.on "disconnect", ->
    room = ""
    socket.get "room", (err, _room) -> room = _room
    user = ""
    socket.get "user", (err, _user) -> user = _user
    counts[room] = counts[room] - 1
    if counts[room] < 1
      delete counts[room]
      delete bodies[room]
    socket.broadcast.to(room).emit "user:exit",
      socket_id: socket.id
      user: user
