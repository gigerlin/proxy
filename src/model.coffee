###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

json = require 'circular-json'
io_client = require 'socket.io-client'

class Emitter extends require('events').EventEmitter
  log: (text) -> console.log if text.length < 128 then text else text.substring(0, 127) + ' ...'

class Wrapper
  constructor: (@socket, @tag = 'rpc') ->
  emit: (tag, msg, ack_cb) -> @socket.emit tag, msg, (rst, err) -> ack_cb rst, err

exports.Remote = class Remote
  constructor: (socket, methods...) ->
    count = 0
    uid = (Math.random() + '').substring 2, 8
    tag = socket.tag or 'rpc'
    ( (method) => @[method] = -> 
      args = Array.prototype.slice.call arguments # transform arguments into array
      cb = args.pop() if typeof args[args.length-1] is 'function' 
      msg = method:method, args:args, id:"#{uid}-#{++count}"
      console.log "rpc #{msg.id}: out rpc #{message = json.stringify msg}"
      if socket then socket.emit tag, message, (rst, err) -> cb rst, err if cb 
    ) method for method in methods

exports.Local = class Local extends Emitter
  use: (@impl) -> @
  setAsync: (@async...) -> 
  remote: (methods...) -> new Remote @socket, methods

  constructor: (socket, tag = 'rpc') ->
    if socket 
      @socket = new Wrapper socket, tag
      socket.on tag, (message, ack_cb) => 
        msg = json.parse message
        @log "rpc #{msg.id}: in  #{tag} #{message}"  

        if @impl and @impl[msg.method]
          try
            args = msg.args or []
            args.push => ack_cb.apply @, arguments
            @log "rpc #{msg.id}: executing local #{msg.method}"
            if @async and msg.method in @async then @impl[msg.method] args... else ack_cb @impl[msg.method] args...
          catch e
            @log args = "error in #{msg.method}: #{e}"
            ack_cb null, args
        else
          @log args = "error: method #{msg.method} is unknown"
          ack_cb null, args

exports.Server = class Server extends Emitter
  constructor: (url, Class) ->
    socket = io_client "#{url}/proxy", transports:['websocket', 'polling']
    socket.on 'connect_error', (msg) => @emit 'error', msg
    socket.on 'handshake', (classes, ack_cb) =>
      @log "proxy classes available: #{classes}"
      service = Class.name
      if service in classes
        @log err = "error: class #{service} already registered"
        socket.disconnect()
        @emit 'error', err
      else
        methods = []
        methods.push method for method of Class.prototype when typeof Class.prototype[method] is 'function' and method.charAt(0) isnt '_' # discard private methods
        @log "#{service} methods: #{methods}"
        ack_cb Class:service, methods:methods
        socket.on 'new', (ID) => @emit 'new', new Local socket, ID

exports.RemoteClass = class RemoteClass extends Emitter
  constructor: (url) ->
    @socket = io_client url, transports:['websocket', 'polling']
    @socket.on 'interface', (methods) => 
      @log "remote methods: #{methods}"
      @emit 'connect', new Remote @socket, methods...
  export: (impl) -> 
    local = new Local @socket
    local.use impl
