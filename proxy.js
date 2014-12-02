// Generated by CoffeeScript 1.8.0

/*
  @author Gilles Gerlinger
  Copyright 2014. All rights reserved.
 */

(function() {
  var Proxy, io;

  io = require('socket.io');

  exports.Proxy = Proxy = (function() {
    function Proxy(port) {
      var nsp, proxy;
      this.port = port;
      this.domains = [];
      proxy = io(this.port);
      this.log("Starting Proxy on " + port);
      nsp = proxy.of('/proxy');
      nsp.on('connection', (function(_this) {
        return function(server) {
          _this.log('NEW connection');
          return server.emit('handshake', Object.keys(_this.domains), function(data) {
            var domain;
            if (_this.domains[data.domain]) {
              return _this.log("warning: domain " + data.domain + " already registered");
            } else {
              _this.log("registering domain: " + data.domain);
              domain = proxy.of("/" + data.domain);
              _this.domains[data.domain] = domain;
              server.on('disconnect', function() {
                return delete _this.domains[data.domain];
              });
              return domain.on('connection', function(client) {
                var ID;
                ID = (Math.random() + '').replace('0.', '');
                _this.log("new connection " + ID + " for " + data.domain);
                client.on('rpc', function(msg, ack_cb) {
                  return server.emit("" + ID, msg, function(msg, err) {
                    return ack_cb(msg, err);
                  });
                });
                server.on("" + ID, function(msg, ack_cb) {
                  return client.emit('rpc', msg, function(msg, err) {
                    return ack_cb(msg, err);
                  });
                });
                return server.emit('new', ID);
              });
            }
          });
        };
      })(this));
    }

    Proxy.prototype.log = function(text) {
      return console.log(text);
    };

    return Proxy;

  })();

  new Proxy(process.argv[2]);

}).call(this);
