###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

json = require 'circular-json'
io_client = require 'socket.io-client'

verbose = true

class Emitter extends require('events').EventEmitter
  log: (text) -> if verbose then console.log if text.length < 128 then text else text.substring(0, 127) + ' ...'

class Wrapper
  constructor: (@socket, @tag = 'rpc') ->
  emit: (tag, msg, ack_cb) -> @socket.emit tag, msg, (rst, err) -> ack_cb rst, err
  on: (event, cb) -> @socket.on event, cb()

exports.Remote = class Remote
  constructor: (socket, methods...) ->
    if socket
      count = 0
      uid = (Math.random() + '').substring 2, 8
      tag = socket.tag or 'rpc'
      ( (method) => @[method] = -> 
        args = Array.prototype.slice.call arguments # transform arguments into array
        cb = args.pop() if typeof args[args.length-1] is 'function' 
        message = json.stringify msg = method:method, args:args, id:"#{uid}-#{++count}"
        if verbose then console.log "rpc #{msg.id}: out rpc #{message}"
        socket.emit tag, message, (rst, err) -> cb rst, err if cb 
      ) method for method in methods

exports.Local = class Local extends Emitter
  use: (@impl) -> @
  remote: (methods...) -> new Remote @socket, methods...
  setSync: (methods...) -> @sync = methods

  constructor: (socket, tag = 'rpc') ->
    if socket 
      @socket = new Wrapper socket, tag
      socket.on tag, (message, ack_cb) => 
        msg = json.parse message
        @log "rpc #{msg.id}: in  #{tag} #{message}"  

        if @impl and @impl[msg.method]
          try
            args = msg.args or []
            if @sync then async = true unless msg.method in @sync
            # try to determine asynchronism from the expected number of arguments
            else if args.length < @impl[msg.method].length then async = true # risk is caller forgets a parameter or signature is like m(p1, p2=3)
            if async then args.push => ack_cb.apply @, arguments
            @log "rpc #{msg.id}: executing #{if async then 'async ' else ''}#{msg.method}"
            if async then @impl[msg.method] args... else ack_cb @impl[msg.method] args...
          catch e
            @log args = "error in #{msg.method}: #{e}"
            ack_cb null, args
        else
          @log args = "error: method #{msg.method} is unknown"
          ack_cb null, args

exports.Server = class Server extends Emitter
  constructor: (url, Class) ->
    methods = []
    methods.push method for method of Class.prototype when typeof Class.prototype[method] is 'function' and method.charAt(0) isnt '_' # discard private methods

    socket = io_client "#{url}/proxy", transports:['websocket', 'polling']
    socket.on 'connect_error', (err) => @emit 'error', err
    socket.on 'connect', => 
      socket.emit 'register', { Class:Class.name, methods:methods }, (err) =>
        unless err then socket.on 'new', (ID, dom) => @emit 'new', new Local socket, ID if dom is Class.name
        else
          @log err 
          socket.disconnect()
          @emit 'error', err

exports.RemoteClass = class RemoteClass extends Emitter
  export: (impl) -> new Local(@socket).use impl
  constructor: (url) ->
    @socket = io_client url, transports:['websocket', 'polling']
    @socket.on 'connect_error', (err) => @emit 'error', err
    @socket.on 'handshake', (methods) => 
      @log "remote methods: #{methods}"
      @emit 'connect', new Remote @socket, methods...
