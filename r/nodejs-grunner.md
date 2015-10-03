2016

#GRunner

<!--- tags: javascript nodejs -->

**[GRunner](https://www.npmjs.com/package/grunner)** is a task runner for [Node.js](https://nodejs.org/), inspired by and compatible with [Gulp](http://gulpjs.com/). Most Gulp plugins and Gulp streams, such as, `gulp.src`, can be used as they are with GRunner. Gulp 3 has some task limitations that are addressed in Gulp 4. GRunner task scheduler is based on [async](https://github.com/caolan/async) and it is *subjectively* better :). GRunner uses some ES2015 features, so it needs a recent version of Node.js.

##Usage

Install globally for comfort:

```
npm install grunner -g
```

To install locally in your node project where the task file is:

```
npm i grunner -D
```

If installed locally, you can run GRunner as `node node_modules/grunner/bin/grunner.js` appending any arguments.

Tasks are coded in Javascript, in one or more files, the default task file name is `gfile.js`:

```
"use strict";

let G = require('grunner')
    , gulp = require('gulp');

G.t('t1', () => {
    return gulp.src('*.js').pipe(...);
    });

G.t('t2', cb => {
        console.log('Hello World!');
        cb();
    });

G.t('default', ['t1', 't2']);
```

Tasks can be split in as many files you like. Use `require` to include them as needed.

Run a task via:

```
grunner --gfile gfile.js --gtask default
```

If `--gfile` and / or `--gtask` are missing defaults with values as shown above are used.

GRunner does not use Gulp (other that for unit testing to check it can work with it). Using Gulp is not a requirement for using GRunner. GRunner can be used with own task logic that does not use anything from Gulp. And if you like to, you can use GRunner with most Gulp plugins, as well with `gulp.src`, and other Gulp stream based constructs similarly as you use them inside Gulp tasks. 

##Command Line Reference

Specifying task files:

* `--gdir dirPath` - process all `*.js` files in dirPath as grunner files. 
* `--gdirrec dirPath` - same as `--gdir` but recursively process sub folders too.
* `--gfile filePath` - process specified file as grunner file. If not specified `gfile.js` is assumed.

All these options can be repeated more than once to specify one or more files and folders. The options are processed in the order given, in groups: first group to process is `--gdirrec`, second is `--gdir`, and last processed group is `--gfile`. If a file is loaded once as part of a given group, it is not loaded anymore as part of the later groups. The last task with a given name that is processed wins.

Specifying task to run:

* `--gtask taskName` - task name to run. This option can be repeated as needed - all tasks are run by default blocking in the given order (if you like them to be started non-blocking use `--P`). If not set, `default` task name is assumed.

Other options:

* `--T` - list all tasks and exit.
* `--D` - dry run, run tasks according to dependencies, but do not invoke task functions.
* `--P` - by default `--gtask` tasks run blocking one after the other. If `--P` is specified they are started non-blocking.
* `--C` - GRunner does circular dependency loop detection as it runs the tasks by default. If you do **not** need that functionality, turn it off by specifying this option.

##Task Dependencies

When you define a task (via `G.t`) you can pass optional task dependencies to be run before it as second argument. The dependencies can be one task as string, or a array of strings. Nested arrays are supported and have special meaning.

* `G.t('t1')` - no dependencies.
* `G.t('t2', 't1')` - t1 will be run before t2.
* `G.t('t3', ['t1', 't2'])` - sequential, t1 will be run first than t2, and then t3.
* `G.t('t4', ['t1', ['t2', 't3'], 't1'])` - t1 will be run first, then t2 and t3 will both start in parallel, then t1 will run again after t2 and t3 are done, and then t4 will run.

*Parallel* here means execution will not block, *sequential* means the execution blocks until all tasks before finish. In general, if the task dependencies array is considered *level 0* and the first nested arrays as level 1, then the tasks in *odd* levels of nested arrays are started in parallel and those in *even* levels are started sequentially. Tasks started in parallel have pipe symbol `|` listed in console before their name. Nesting level of tasks is shown in console with dots `.` before the task name.

Circular task dependencies, such as, `G.t('t1', ['t2']); G.t('t2', ['t1']);` direct or indirect, will result in failure.

##GRunner Instances

When you use `let G = require('grunner');` you get *same* per process singleton instance `G` of `GRunner` class. This instance `G` is used by default, by all `gfile.js` tasks. If you want to use the `grunner` command-line, you should only use this process singleton object to define your tasks. 

For more advanced scenarios, you can create as many `GRunner` instances as needed using code such as:

```
let G = require('grunner');
G.t('t1'); // G is the per process singleton instance

let g1 = new G.GRunner(); // new instance
let g2 = new G.GRunner(); // another new instance
g1.t('t1'); // a task on g1 instance
g2.t('t1'); // a task on g2 instance

g1.run('t1'); // run t1 on g1
g2.run('t1'); // run t1 on g2
```

Instances do not share any state, same task name in two different instances can be used to mean two different things. The methods documented in *Task API Reference* section can be called on any `GRunner` instance. The `new G.GRunner()` can be called only on the process singleton instance. The `run` method does not block. When using the `grunner` in command-line, `G.run` is called for you automatically.

##Task API Reference

Here `g` represents a `GRunner` instance object.

* `GRunner([options])` - constructor, you can pass an optional `options` object. Options can be accessed also via `g.options`. Options can be changed at any time before calling `g.run()`. Options are:
    * `log = fn(msg, isError)` - replaces the internal log function which logs in `console`.
    * `exec = fn(doneCb)` - gives an option to wrap each `taskFun` call. Basically, `fn` could be implemented as:
        ``` 
        if(!ctx.task.cb) { doneCb(); return; }
        return ctx.task.cb(doneCb);
        ```
    * `dryRun` - if `true`, same as `--D` command-line option.
    * `beforeTaskRun = fn(ctx)` - called before taskFun is run (see `g.t` for `ctx`). This method and the next are intended for extra logging and testing. For more advanced wrapping use the `exec` option.
    * `afterTaskRun = fn(ctx)` - called after `taskFun` is run (see `g.t` for `ctx`).
    * `noLoopDetection` - if `true`, same `--C` command-line option. 

* `g.t(...)` - adds a task and has several forms:

    ```
      g.t(taskName) 
      g.t(taskName, taskFun)
      g.t(taskName, taskDependecies, taskFun)
      g.t(taskName, taskFun, userData)
      g.t(taskName, taskDependecies, taskFun, userData)
    ```
  Tasks are added as keys (`taskName`) to `g.tasks` object. Adding a task with same `taskName` as a previous one, replaces it. While you can add tasks directly to `g.tasks` (and sometimes this can be useful), using `g.t` is recommended. The arguments of `g.t(...)` are:
    * `taskName` - string (valid JS object key name).
    * `taskDependecies` - optional string, or array of strings of task names to be run before.
    * `taskFun(cb)` - optional body of the task. The optional `ct.ctx` object contains information about the task `ctx = {taskName, task, runner}`. Normally, `cb.ctx` should be treated as read-only information, but you can modify the custom `userData` passed to `g.t`. There are several valid ways to denote that you are done within `taskFun` code:
        * Call `cb();` on success, or `cb(error);` on error. If your code calls `cb`, it must be called once.
        * Return a JS *promise*. Any promise object that supports `then` is supported. In this case you should **not** call `cb()`.
        * Return a `Stream`, such as `return gulp.src(...).pipe(...);`. In this case you should **not** call `cb()`.
        * A bit more advanced, instead of returning a stream or promise, call `cb.onDone(streamOrPromise, [cb]);` on a stream or promise. You may never need this, but if you ever feel like you need it, it can come handy. In this case you should **not** call `cb()`. You should also **not** `return` anything in this case from `taskFun`. `cb.onDone(null);` is same as calling `cb();` directly. The optional `[cb]` parameter enables wrapping the `cb()` call in your own function. If you do that, call `cb()` on your own within it.

        You can also exit a task using errors:

        * Emit an error in a returned `Stream`. In this case, you should **not** call `cb()`.
        * In a returned *promise* `throw` an error, or fail. In this case you should **not** call `cb()`.
        * `throw` a JS error. This works only directly within `taskFun`. If you `throw` inside a `pipe` stream, or `setTimeout`, and similar async functions, Node.js will stop execution. Use `try / catch` and callbacks to report errors in such cases.
    * `userData` - can be any object, accessible via `cb.ctx.task.userData` within `taskFun`.

* `g.addTask` - this is a synonym for `g.t`.

* `g.tasks` - array of tasks. Use `g.t` to add tasks to `g.tasks`. The minimal task object is `{dep: [], cb: null, userData: null}`.

* `g.run(taskName, cb)` - is used to run a task. When used via command-line this function is called for you for each `--gtask` task. `g.run` does not block - use `cb(error)` to be notified when done. If a task has any dependencies, then those tasks will be run before (*recursively*). `g.run()` only reads options and tasks, so you can invoke `g.run()` more than once on same instance without waiting for previous invocation to finish (as long as you do not modify options and tasks in between).

* `g.log(msg, isError)` - writes `msg` string in `console.log`, or if `isError=true` in `console.error`. You can replace this function with your own using `options.log`.

