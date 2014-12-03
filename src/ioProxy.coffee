###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io_client = require 'socket.io-client'
avsRpc = require 'avs-rpc'

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

connect = (url, cb) ->
  socket = io_client url, transports:['websocket', 'polling']
  socket.on 'connect_error', (msg) -> cb null, msg

exports.Server = class Server
  constructor: (url, service, cb) ->
    socket = connect "#{url}/proxy", cb
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
    socket = connect url, cb
    socket.on 'connect', -> cb new avsRpc.ioRpc socket
