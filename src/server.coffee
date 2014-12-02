Server = require('avs-proxy').Server

srv = new Server "http://localhost:#{process.argv[2]}", 'ns', (rpc, err) ->
  if err then console.log err
  else
    rpc.implement new User 'test', 345
    remote = rpc.remote 'echo'
    setTimeout (->
      console.log "sending echo"
      remote.echo 34, (rst, err) -> console.log if err then err else "echo: #{rst}"
    ), 2000  

class User
  constructor: (@name, @age) ->
  getAge: -> @age