#Clustering Express Node Servers

2017-10-05

<!--- tags: nodejs express -->

Following code, assembled from looking at various places, enables process clustering for Node.js [Express](https://expressjs.com/) applications. The actual Express server code is loaded via `require('./server')`. Rest of code is generic and can be reused with any server.

```javascript
'use strict';

var cluster = require('cluster');
if(cluster.isMaster) {
	var isShutdown = false;
	var workers = [];
	var cpuCount = require('os').cpus().length;
	console.log('$ Starting cluster...#', cpuCount);
	for (var i = 0; i < cpuCount; i += 1) {
		workers.push(cluster.fork());
	}
	cluster.on('exit', function (worker) {
		console.log('$ Worker died :(', worker.id);
		if(isShutdown) return;
		var idx = workers.findIndex(function(_) { 
			return (_.id === worker.id);
		});
		console.log('$ Replacing worker @', idx);
		workers[idx] = cluster.fork();
	});
	var deadWorkers = 0;
	var shutdown = function() {
		isShutdown = true;
		workers.forEach(function(_) {
			_.on('exit', function() {
				if(++deadWorkers === workers.length) {
					console.log('$ Workers exited');
					process.exit(0);
				}
			});
			_.send('shutdown');
		});
	};
	process.on('SIGTERM', shutdown);
	process.on('SIGINT', shutdown);
}
else {
	console.log('$ Worker:', process.pid);
	process.on('message', function(msg){
		switch(msg) {
			case 'shutdown': {
				process.exit(0);
			}
			break;
		}
	});

	require('./server');
}
```

Code takes care of a few common cases:

* It creates as many workers as logical CPUs per machine.
* If a worker dies, a new one is created
* If master is killed, all workers are killed first

The only weak point of clustering is when master dies. If master dies, there is nothing to do via Node.js itself. Restarting master process in such cases has to be handled externally.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-10-08-VSCode-Extensions.md'>VSCode Extensions</a> <a rel='next' id='fnext' href='#blog/2017/2017-10-03-iptables-for-OpenVpn.md'>iptables for OpenVpn</a></ins>
