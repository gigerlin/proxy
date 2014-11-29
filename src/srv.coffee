
class User
  constructor: (@name, @age) ->
  getAge: -> @age

proxy = require 'avs-proxy'

server = new proxy.Server "http://localhost:#{process.argv[2]}", ['ns', 'truc'], (domain, rpc) ->
  rpc.implement new User 'gg', 32
  remote = rpc.remote 'echo'
  
  setTimeout (->
    console.log "sending echo"
    remote.echo (rst) -> console.log "echo: #{rst}"
  ),5000  


