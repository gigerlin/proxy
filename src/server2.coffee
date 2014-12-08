
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

class User
  constructor: (@name, @age) ->
  getAge: (a1, a2) -> 
    @log "a1:#{a1}"
    #console.log "a2:#{a2}"
    @age
  log: (text) -> console.log text  
  async: (t, cb) -> cb 33

class Account
  total: -> 46


UserServer = new (require './model').Server "http://localhost:#{process.argv[2]}", User
UserServer.on 'error', (err) -> console.log err
UserServer.on 'new', (local) ->
  local.use new User 'test', 564
  local.setSync 'getAge'
  r = local.remote 'echo'
  setTimeout (->
    r.echo 34, (rst, err) -> console.log if err then err else "echo: #{rst}"
  ), 2000  

acc = new Account
AccountServer = new (require './model').Server "http://localhost:#{process.argv[2]}", Account
AccountServer.on 'error', (err) -> console.log err
AccountServer.on 'new', (local) ->
  local.use acc

