###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io = require 'socket.io'

class Proxy
  count: 0
  constructor: (@port) ->
    proxy = io @port
    @log "Starting Proxy on #{@port}"
    @sockets = []

    proxy.on 'connection', (socket) =>
      @log "NEW connection #{++@count}"

      socket.on 'disconnect', (msg) =>
        for domain of @sockets
          if @sockets[domain] is socket
            @log "removing domain #{domain}"
            delete @sockets[domain]

      domains = []; domains.push domain for domain of @sockets
      socket.emit 'handshake', domains, (data) =>
        if data.type is 'server'
          for domain in data.domains
            @log if @sockets[domain] then "updating domain #{domain}" else "new domain #{domain}"
            @sockets[domain] = socket 
        else # if data.type is 'client'
          for domain in data.domains
            if @sockets[domain]
              ID = (Math.random() + '').replace '0.', ''
              @log "pairing rpc.#{domain} with #{ID}"
              socket.on "rpc.#{domain}", (msg, ack_cb) =>
                @sockets[domain].emit "#{ID}", msg, -> ack_cb.apply @, arguments
              @sockets[domain].on "#{ID}", (msg, ack_cb) ->
                socket.emit "rpc.#{domain}", msg, -> ack_cb.apply @, arguments

              @sockets[domain].emit "new.#{domain}", ID
            else
              @log error = "error: domain #{domain} is not available"
              socket.on "rpc.#{domain}", (msg, ack_cb) => ack_cb null, error

  log: (text) -> console.log text

new Proxy process.argv[2]
