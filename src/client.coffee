Client = require('avs-proxy').Client

new Client "https://proxy.avansonic.com/ns", (rpc, err) -> 
  if err then console.log err 
  else
    console.log "cli connected!"
    rpc.implement new Test
    remotec = rpc.remote 'getAge'
    remotec.getAge (rst, err) -> console.log if err then err else "getAge: #{rst}"

class Test
  echo: -> "ok"

