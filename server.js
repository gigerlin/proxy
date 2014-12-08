// Generated by CoffeeScript 1.8.0
(function() {
  var Server, User, inf, io_client, srv;

  Server = require('avs-proxy').Server;

  srv = new Server("http://localhost:" + process.argv[2], 'ns', function(rpc, err) {
    var remote;
    if (err) {
      return console.log(err);
    } else {
      rpc.implement(new User('test', 345));
      remote = rpc.remote('echo');
      return setTimeout((function() {
        console.log("sending echo");
        return remote.echo(34, function(rst, err) {
          return console.log(err ? err : "echo: " + rst);
        });
      }), 2000);
    }
  });

  User = (function() {
    function User(name, age) {
      this.name = name;
      this.age = age;
    }

    User.prototype.getAge = function(a1, a2) {
      console.log("a1:" + a1);
      console.log("a2:" + a2);
      return this.age;
    };

    return User;

  })();

  io_client = require('socket.io-client');

  inf = io_client("http://localhost:" + process.argv[2] + "/proxy/info", {
    transports: ['websocket', 'polling']
  });

  inf.on('info', function(domains) {
    return console.log("domains: " + domains);
  });

}).call(this);
