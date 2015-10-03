#WebWorker Connection Patterns

2016-03-03

<!--- tags: javascript architecture -->

[WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) are a HTML5 JavaScript [API](https://html.spec.whatwg.org/multipage/workers.html) enabling multi-threaded client side code. Dedicated workers are created per page, whereas shared workers are shared across windows. Workers can be combined in different ways. Three representative communication patterns of communication between workers and the DOM window thread are shown next to help with getting started chaining web workers in custom topologies.

##Dedicated Workers Pool

A configurable pool of dedicated workers can be used to load balance data  processing. The pool of *dedicated* workers (DW) shown in this example are randomly load balanced to process data coming from the window (W).

![@noround@](blog/images/ww1.svg)

Setting up the pool:

```javascript
var workersPoolMax = 2; //window.navigator.hardwareConcurrency;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    workers.push({w: w}); // {w} ES6
}

// ...
var idx = Math.floor(Math.random() * workersPoolMax);
// input from application 
workers[idx].w.postMessage({cmd: 'process'});
```

Worker `worker.js` code:

```javascript
onmessage = function(e) {
    switch(e.data.cmd) {
        case 'process':
            // send result back to window
            var res = data;
            self.postMessage(res);
            break;
    }
};
```


##Nested Dedicated Workers

Nesting workers is interesting for sharing work between worker threads without having the main window deal with cross worker communication. There are some places in the Internet that will tell you that workers can be created within workers. In my understanding, creating workers within workers is not part of workers scope API and Chrome, where I tried these examples out, conforms to that. We need to create all workers in the window thread, but we can chain their messaging channels so that workers communicate directly without going through the window.

![@noround@](blog/images/ww2.svg)

I have modified the previous example to add two nested *dedicated* web workers, one per each previous load balanced worker:

```javascript
var workersPoolMax = 2;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    var n = new Worker('nestedWorker.js');
    var channel = new MessageChannel();
    w.postMessage({cmd: 'connect'}, [channel.port1]);
    n.postMessage({cmd: 'connect'}, [channel.port2]);
    workers.push({w: w, n: n});
}

var idx = Math.floor(Math.random() * workersPoolMax);
workers[idx].w.postMessage({cmd: 'process'}); 
```

We can use `MessageChannel` to establish a bidirectional communication pipe through workers. Currently, `MessageChannel` does [not](https://bugs.chromium.org/p/chromium/issues/detail?id=334408) support transferable types in Chrome, which can be a drawback for this kind of topology, depending on the data you have. However, understanding how this is done is still useful (given data copy is done on a worker this is still not affecting the window thread). The updated code of the `worker.js` is shown next. Using `cmd` as shown is just a convention. You can use any convention of choice to manage your data flow protocol.

```javascript
var nestedPort;
var me = self;

onmessage = function (e) {
    switch(e.data.cmd) {
        case 'connect':
            var nestedPort = e.ports[0];
            port.onmessage = function(event) {
                // data from nested worker comes here
                var res = event.data;
                me.postMessage(res); // send result back to window 
            };
            break;
        case 'process':
            // process and forward data to nested worker
            // no transferables in Chrome :( atm
            var res = data;
            nestedPort.postMessage(res); 
            break;
    }
};
```

Nested worker `nestedWorker.js` code:

```javascript
var parentPort;

onmessage = function(e) {
    var data = e.data;
    switch(data.cmd) {
        case 'connect':
            parentPort = e.ports[0];
            parentPort.onmessage = function(event) {
                // data from parent comes here
                // process and send back to parent
                var res = event.data;
                parentPort.postMessage(res);
            };
            break;
    }
};
```

##Nested Shared Worker

This example is similar to the previous one, but uses a nested *shared* worker (SW). SharedWorkers are shared across windows and you get access to same worker (different port) when creating instances. I use the shared worker in this example to make a diamond shaped topology, where the nested shared worker is shared between the pool workers.

![@noround@](blog/images/ww3.svg)

Similar to above, we need to setup all code in the window, but the communication will still be direct between workers, without having the window deal with it.

```javascript
var workersPoolMax = 2;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    var n = new SharedWorker('sharedWorker.js');
    n.port.start();
    w.postMessage({cmd: 'sharedConnect'}, [n.port]);
    workers.push({w: w});
}

var idx = Math.floor(Math.random() * workersPoolMax);
workers[idx].w.postMessage({cmd: 'process'});
```

The code passes the port of the shared worker to its parent worker, whose  `worker.js` is shown next. The nested shared worker `n` handles data `process` message same as before. Additionally, the shared worker also broadcasts some event of interest to all parents if needed.

```javascript
var nestedPort;
var me = self;

onmessage = function (e) {
    switch(e.data.cmd) {
        case 'connect':
            var nestedPort = e.ports[0];
            port.onmessage = function(event) {
                // data from nested shared worker comes here
                switch(event.data.cmd) {
                    case 'process':
                        // send result back to window
                        var res = event.data;
                        me.postMessage(res);  
                        break;
                    case 'broadcast':
                        // if needed
                        break;    
                }   
            };
            break;
        case 'process':
            // process and forward data to nested worker
            var res = data;
            nestedPort.postMessage(res); 
            break;
    }
};
```

Finally, `sharedWorker.js` implementation:

```javascript
var parents = [];
var totalMessageCount = 0; // state

onconnect = function(e) {
    var parentPort = e.ports[0];
    parents.push(port);
    parentPort.onmessage = function(event) {
        // data from parent comes here
        // process and send back to same parent
        var res = event.data;
        parentPort.postMessage(res);

        //optional, we can broadcast to all parents too
        totalMessageCount++;
        parents.forEach(function(p) {
            p.postMessage({cmd: 'broadcast', 
              count: totalMessageCount}); 
        });
    };
};
```

The shared worker sends the result back to the same parent. We can keep track of connected parent ports (*clients*) in order to be able broadcast to them. In this example, the clients are additive (do not go away way over time). If clients were to be removed over time, we could use `broadcast` message, for example, (along some client response protocol) to *ping* alive clients and update the clients list.

<ins class='nfooter'><a id='fprev' href='#blog/2016/2016-04-07-Web-Noise.md'>Web Noise</a> <a id='fnext' href='#blog/2016/2016-02-24-Key-Derivation-Functions.md'>Key Derivation Functions</a></ins>
