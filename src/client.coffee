Client = require('avs-proxy').Client

cli = new Client "http://localhost:#{process.argv[2]}/ns", (rpc) -> 
    console.log "cli connected!"
    rpc.implement new Test
    remotec = rpc.remote 'getAge'
    remotec.getAge (rst, err) -> console.log if err then err else "getAge: #{rst}"

class Test
  echo: -> "ok"

