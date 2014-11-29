proxy
=====

Proxy for avs-rpc.

The proxy connects clients and servers through ioRpc (cf. [avs-rpc](https://www.npmjs.org/package/avs-rpc)). This allows servers to be distributed on various machines without clients having to know their location. It is usefull when servers are behind routers (NAT).

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

A proxy server publishes one or more domains (services). For each domain, a rpc object will be instantiated upon client connection. This rpc object implement methods so they are available to the client through the avs-rpc mechanism. 

```js
proxy = require('avs-proxy');

function getUserProfile(name) { return {name:'test', age:32}; }
var local = {};
local.getUserProfile = getUserProfile;

server = new proxy.Server("http://localhost:4241", ['dom1', 'dom2'], function(domain, rpc) {
    rpc.implement(local); 
}
```

## proxy client ##

A proxy client connects to the proxy and indicates the domains it needs to subscribe to. Once connected, the client can use any of the remote methods published in the domains subscribed.

```js
proxy = require('avs-proxy');

rpc = new proxy.Client("http://localhost:4241", 'dom1');
remote = rpc.remote('dom1', 'getUserProfile');
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
rpc = new proxy.Client('http://localhost:4241', 'dom1');
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
