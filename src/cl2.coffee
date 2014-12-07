
RemoteUser = new (require './model').RemoteClass "http://localhost:8787/User"
RemoteUser.on 'connect', (user) ->
  user.getAge 'titi', (age) -> console.log "age:#{age}"
  RemoteUser.export echo: -> "ok" #find better name for export
