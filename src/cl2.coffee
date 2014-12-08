
RemoteUser = new (require './model').RemoteClass "http://localhost:8787/User"
RemoteUser.on 'error', (err) ->console.log err
RemoteUser.on 'connect', (user) ->
  user.getAge 'titi', (age) -> console.log "age:#{age}"
  user.async 3, (rst) -> console.log "rst: #{rst}"
  RemoteUser.export echo: -> "ok" #find better name for export

RemoteAccount = new (require './model').RemoteClass "http://localhost:8787/Account"
RemoteAccount.on 'error', (err) ->console.log err
RemoteAccount.on 'connect', (account) ->
  account.total 3, (tot) -> console.log "total: #{tot}"
