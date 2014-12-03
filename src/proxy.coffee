###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io = require 'socket.io'

exports.Proxy = class Proxy
  constructor: (@port) ->
    @domains = []
    proxy = io @port
    @log "Starting Proxy on #{port}"
    nsp = proxy.of '/proxy'
    nsp.on 'connection', (server) => 
      @log 'NEW connection'
      server.emit 'handshake', (Object.keys @domains), (data) =>
        if @domains[data.domain] then @log "warning: domain #{data.domain} already registered"
        else
          @log "registering domain: #{data.domain}"
          domain = proxy.of "/#{data.domain}"
          @domains[data.domain] = domain
          server.on 'disconnect', =>
            console.log "removing domain: #{data.domain}" 
            delete @domains[data.domain]
          domain.on 'connection', (client) =>
            ID = (Math.random() + '').replace '0.', ''
            @log "new connection #{ID} for #{data.domain}"
            client.on 'rpc', (msg, ack_cb) -> server.emit  "#{ID}", msg, (msg, err) -> ack_cb msg, err
            server.on  "#{ID}", (msg, ack_cb) -> client.emit 'rpc', msg, (msg, err) -> ack_cb msg, err
            server.emit 'new', ID

  log: (text) -> console.log text

new Proxy process.argv[2]