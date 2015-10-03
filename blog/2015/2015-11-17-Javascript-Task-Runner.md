#Javascript Task Runner

2015-11-17

<!--- tags: javascript deployment nodejs -->

**Update:** There is a node.js module [grunner](#r/nodejs-grunner.md), I wrote based on this idea. This post is a bit outdated.

---

This is a take on [Gulp](http://gulpjs.com/). The code below shows how you can implement the Gulp task runner fully on your. Gulp 3 does not support serial tasks, only parallel ones and serial ones will be only available on Gulp 4. The task runner shown here supports both serial and parallel tasks. 

I use syntax inspired by [run-sequence](https://www.npmjs.com/package/run-sequence) for dependencies (but a bit different). For the task runner below task dependencies are specified as an array where flat nested arrays denote tasks that can be run in parallel (further nested arrays make no sense as we specify dependencies on each task, not globally - but the code may work on these too - not tested). 

The whole task runner logic is below:

```javascript
var __ = require('async');

var runTask = function(task, cb) {
    var t = tasks[task];
    var serFun = [];
    if(t.dep) {
        var depFun = t.dep.map(function(d) {
            if(Array.isArray(d)) {
                return function (__cb) {
                    var f = d.map(function(pd){
                        return function(__cb) {
                            runTask(pd, __cb);
                        };
                    });
                    __.parallel(f, __cb);
                };
            }
            return function (__cb) {
                runTask(d, __cb)
            };
        });
        Array.prototype.push.apply(serFun, depFun);
    }
    if(t.cb) {
        serFun.push(function(__cb) {
            t.cb(__cb);
        });
    }
    __.series(serFun, cb);
};
```

There is not much error handling (todo on your own :), but it works and it will fail is something is wrong (just like Gulp :). This how tasks are defined:

```javascript
var tasks = {};

tasks['t1'] = { cb: function(cb) { console.log('t1'); cb(); } };
tasks['t2'] = { cb: function(cb) { console.log('t2'); cb(); } };
tasks['t3'] = { dep: [ 't1', 't2' ], cb: function(cb) { console.log('t3'); cb(); } };
tasks['t4'] = { dep: [ 't3', ['t2', 't1'], ['t1'] ], cb: function(cb) { console.log('t3'); cb(); } };

// and this how we run them
runTask('t4', function(err){ console.log('done'); })
```


A task has a name, e.g. `t3`, and it is added as a `task['t3']` object with a optional dependencies array `dep` and an optional callback `cb`. Tasks support asynchronous code only with callbacks, but it is trivial to extend the code to support other mechanisms, such as, promises or `pipe`s. The code will run `t4`, but by running first `t3` (and before it `t1` and `t2`) then `t2` || `t1` and then again `t1`. The code does not detect dependency loops upfront, so if you have loops in dependencies, then you will get stack overflow at some point.

As it is now, the code run synchronously because our task's `cb` functions are synchronous. If you want to try the code with asynchronous tasks, replace above `console.log('t1'); cb();` with `asyncPrint('t1', cb);` on each task callback. Where `asyncPrint` can be something like the following for testing:

```javascript
var asyncPrint = function(m, cb) {
    setTimeout(function(){
        console.log(m);
        cb();
    }, 6000);
};
```

This is all you need to implement a Gulp task runner on your own. Gulp provides also an adapter on system files that works using own `File` objects with node.js streams (`pipe`). You can use `gulp.src` and `gulp.dest` with the above task runner if you like, or implement your own ones (maybe I will write how that can be done in few lines of code in a future post). Given most Gulp examples `return gulp.src(...).pipe(...);` from tasks, you may wonder how to do that with my task runner. The following workaround may help (or just register on `pipe` `finish` event):

```javascript

var through = require('through2');

var onPipeEnd = function(onDone) {
    return through.obj(
        function(file, enc, cb) { cb(); }
        , function(cb) { onDone(); cb(); });
};

// onPipeEnd can be used as follows in a task callback `cb` function:
function(cb) { 
    gulp.src(...).pipe(...).pipe(onPipeEnd(cb));
}
```

We wait for the `pipe` to finish, and call `cb` there. Similar code can be used to improve handling of any possible task `cb` return values in `runTask` code.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-12-10-WebEx-On-Ubuntu.md'>WebEx On Ubuntu</a> <a rel='next' id='fnext' href='#blog/2015/2015-11-02-Lean-Process-Certified.md'>Lean Process Certified</a></ins>
