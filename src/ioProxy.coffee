###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io_client = require 'socket.io-client'
avsRpc = require 'avs-rpc'

exports.Server = class Server
  constructor: (url, service, cb) ->
    socket = io_client "#{url}/proxy"
    socket.on 'handshake', (domains, ack_cb) ->
      console.log "proxy domains: #{domains}"
      if service in domains
        console.log err = "error: domain #{service} already registered"
        socket.disconnect()
        cb null, err
      else
        ack_cb domain:service
        socket.on 'new', (ID) -> cb new avsRpc.ioRpc socket, ID

exports.Client = class Client 
  constructor: (url, cb) ->
    socket = io_client url
    socket.on 'connect', -> cb new avsRpc.ioRpc socket
