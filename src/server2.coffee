
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

class User
  constructor: (@name, @age) ->
  getAge: (a1, a2) -> 
    @log "a1:#{a1}"
    #console.log "a2:#{a2}"
    @age
  log: (text) -> console.log text  

UserServer = new (require './model').Server "http://localhost:8787", User
UserServer.on 'error', (err) -> console.log err
UserServer.on 'new', (local) ->
    local.use new User 'test', 564
    r = local.remote 'echo'
    setTimeout (->
      r.echo 34, (rst, err) -> console.log if err then err else "echo: #{rst}"
    ), 2000  

