proxy = require 'avs-proxy'

rpc = new proxy.Client "http://localhost:#{process.argv[2]}", 'ns'

class Test
  echo: -> "ok"

remote = rpc.remote 'ns', 'getAge'
setTimeout (->
  console.log "sending getAge - avail: #{rpc.ready}"
  remote.getAge (msg, err)-> if err then console.log err else console.log "getAge: #{msg}"
  ),2000  

rpc.implement 'ns', new Test
