###
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
###

io_client = require 'socket.io-client'
rpc = require 'avs-rpc'

class ioProxy
  constructor: (@url, @domains, type) -> 
    @socket = io_client @url
    @log "Starting #{type} for #{@domains}"
    if typeof @domains is 'string' then @domains = [@domains]
    @socket.on 'handshake', (@ready, ack_cb) => ack_cb type:type, domains:@domains

  log: (text) -> console.log text

exports.Server = class Server extends ioProxy
  constructor: (url, domains, cb) ->
    super url, domains, 'server'
    for domain in @domains
      @socket.on "new.#{domain}", (id) =>
        cb domain, new rpc.ioRpc @socket, id if cb

exports.Client = class Client extends ioProxy
  constructor: (url, domains) ->
    super url, domains, 'client'
    @rpc = []; @rpc[domain] = new rpc.ioRpc @socket, "rpc.#{domain}" for domain in @domains

  # shortcuts
  remote: (domain, methods...) -> @rpc[domain].remote methods... if @rpc[domain]
  implement: (domain, local, methods...) -> @rpc[domain].implement local, methods... if @rpc[domain]
  implementAsync: (domain, local, methods...) -> @rpc[domain].implementAsync local, methods... if @rpc[domain]
