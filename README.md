proxy
=====

Proxy for avs-rpc.

The proxy connects clients and servers through ioRpc (cf. [avs-rpc](https://www.npmjs.org/package/avs-rpc)). This allows servers to be distributed on various machines without clients having to know their location. It is particularly useful when servers are behind routers (NAT).

Clients connect to the proxy and use the services published by the servers.

## Install ##

```
npm install avs-rpc
npm install avs-proxy
```

In browser:

```html
<script src=".../avs-proxy.min.js"></script>
```

## Start proxy ##

```
node proxy.js 4241
```

where 4241 is the server listening port 

## proxy server ##

A proxy server publishes one domain (service). For this domain, a rpc object will be instantiated upon client connection. This rpc object implements the methods that need to be available to the client through the avs-rpc mechanism. 

```js
proxy = require('avs-proxy');

function getUserProfile(name) { return {name:'test', age:32}; }
var local = {};
local.getUserProfile = getUserProfile;

server = new proxy.Server("http://localhost:4241", 'mydomain', function(rpc, err) {
    rpc.implement(local); 
}
```

An error is returned if the domain is already registered on the proxy.

## proxy client ##

A proxy client connects to the proxy indicating via the URL the domain it needs to subscribe to. Once connected, the client can use any of the remote methods published in the domain subscribed.

```js
proxy = require('avs-proxy');

rpc = new proxy.Client("http://localhost:4241/mydomain");
remote = rpc.remote('getUserProfile');
....
remote.getUserProfile(function(msg, err) {
      if (err) { console.log(err); } 
      else { console.log("getUserProfile: " + msg.age); }
    });
```

### Browser ###

The UMD bundle name of the minified library is *proxy*. The example below shows how to use a proxy client in the browser.

Example:

```js
rpc = new proxy.Client('http://localhost:4241/mydomain');
...
```

## License ##

The MIT License (MIT)

Copyright (c) 2014 gigerlin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
