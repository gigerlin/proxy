###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io = require 'socket.io'

exports.Proxy = class Proxy
  constructor: (@port) ->
    @Classes = []
    proxy = io @port, transports:['websocket', 'polling']
    @log "Starting Proxy on #{@port}"
    nsp = proxy.of '/proxy'
    nsp.on 'connection', (server) => 
      @log 'NEW connection'
      server.emit 'handshake', (Object.keys @Classes), (data) =>
        if @Classes[data.Class] then @log "warning: class #{data.Class} already registered"
        else
          @log "registering class: #{data.Class}"
          Class = proxy.of "/#{data.Class}"
          @Classes[data.Class] = Class
          server.on 'disconnect', =>
            console.log "removing class: #{data.Class}" 
            delete @Classes[data.Class]
            Class.removeAllListeners 'connection'
          Class.on 'connection', (client) =>
            ID = (Math.random() + '').replace '0.', ''
            @log "new connection #{ID} for #{data.Class}"
            client.on 'rpc', (msg, ack_cb) => server.emit  "#{ID}", msg, (msg, err) -> ack_cb msg, err
            server.on  "#{ID}", (msg, ack_cb) -> client.emit 'rpc', msg, (msg, err) -> ack_cb msg, err
            client.emit 'interface', data.methods
            server.emit 'new', ID

    info = proxy.of '/proxy/info'
    info.on 'connection', (server) => info.emit 'info', (Object.keys @Classes)

  log: (text) -> console.log text

new Proxy process.argv[2]
