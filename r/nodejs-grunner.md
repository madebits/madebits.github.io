2016

#GRunner

<!--- tags: javascript nodejs -->

**[GRunner](https://www.npmjs.com/package/grunner)** is a task runner for [Node.js](https://nodejs.org/), inspired by [Gulp](http://gulpjs.com/) and compatible with Gulp. Most Gulp plugins and Gulp streams, such as, `gulp.src`, can be used as they are with GRunner. Gulp 3 has some task limitations that are addressed in Gulp 4. GRunner task scheduler is based on [async](https://github.com/caolan/async) and it is *subjectively* better :) than Gulp's task scheduler (thought GRunner may need some more stack). GRunner uses some ES2015 features, so it needs a recent version of Node.js.

##Usage

Install globally for comfort:

```
npm install grunner -g
```

And install locally in your node project where the task file is:

```
npm i grunner -D
```

Tasks are coded in Javascript, in one or more files, the default task file name is `gfile.js`:

```
"use strict";

let G = require('grunner')
    , gulp = require('gulp');

G.t('t1', cb => {
    return gulp.src('*.js')...;
    });

G.t('t2', cb => {
        cb();
    });

G.t('default', ['t1', 't2']);
```

Run a task via:

```
grunner --gfile gfile.js --gtask default
```

If `--gfile` and / or `--gtask` are missing defaults with values as shown above are used.

##Command Line Reference

Specifying task files:

* `--gdir dirPath` - process all `*.js` files in dirPath as grunner files. 
* `--gdirrec dirPath` - same as `--gdir` but recursively process sub folders too.
* `--gfile filePath` - process specified file as grunner file. If not specified `gfile.js` is assumed.

All these options can be repeated more than once to specify one or more files and folders. The options are processed in the order given, in groups: first group to process is `--gdirrec`, second is `--gdir`, and last processed group is `--gfile`. If a file is loaded once as part of a given group, it is not loaded anymore as part of the later groups. The last task with a given name that is processed wins.

Specifying task to run:

* `--gtask taskName` - task name to run. This option can be repeated as needed - all tasks are run (non-blocking!) in the given order. If not set, `default` task name is assumed.

Other options:

* `--T` - list all tasks and exit.
* `--D` - dry run, run tasks according to dependencies, but do not invoke task functions.

##Task Dependencies

When you define a task (via `G.t`) you can pass optional task dependencies to be run before it as second argument. The dependencies can be one task as string, or a array of strings. Nested arrays are supported and have special meaning.

* `G.t('t1')` - no dependencies.
* `G.t('t2', 't1')` - t1 will be run before t2.
* `G.t('t3', ['t1', 't2'])` - sequential t1 will be run first than t2, and then t3.
* `G.t('t4', ['t1', ['t2', 't3'], 't1'])` - t1 will be run first, then t2 and t3 will both start in parallel, then t1 will run again after t2 and t3 are done, and then t4 will run.

*Parallel* means execution will not block, *sequential* means the execution blocks until all before finish. In general, if the dependencies array is considered *level 0* and the first nested arrays as level 1, then the tasks in all *odd* level nested arrays are started in parallel and those if *even* levels sequentially. Task started in parallel have pipe symbol `|` listed in console before their name. Nesting level of tasks is shown in console with dots `.` before the task name.

Circular task dependencies, such as `G.t('t1', ['t2']); G.t('t2', ['t1'])`, direct or indirect will result in failure.

##GRunner Instances

When you use `let G = require('grunner');` you get *same* per process singleton instance `G` of `GRunner` class. This instance `G` is used by default, by all `gfile.js` tasks. If you want to use the `grunner` command-line, you should only use this process singleton object to define your tasks. 

For more advanced scenarios, you can create as many `GRunner` instances as needed using code like:

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

Instances do not share any state, same task name in two different instances can be used to mean different things. The methods documented in *Code Reference* section can be called on any `GRunner` instance. The `new G.GRunner()` can be called only on the process singleton instance. The `run` method does not block. When use the grunner command-line `G.run` is called for you automatically.

##Task API Reference

Here `g` represents a `GRunner` instance object.

* `GRunner([options])` - constructor, you can pass an optional `options` object. the options can be accessed also via `g.options`. Options can be changed at any time before calling `g.run()`. Options you can use are:
    * `log = fn(msg, isError)` - replaces the internal log function which logs in `console`.
    * `exec = fn(doneCb, info)` - given you an option to wrap each `taskFun` call. Basically `fn` can be implemented as:
        ``` 
        if(!info.task.cb) { doneCb(); return; }
        return info.task.cb(doneCb)
        ```
    * `dryRun` - if true, same as `--D` command-line option.
    * `beforeTaskRun = fn(info)` - called before taskFun is run (see g.t).
    * `afterTaskRun = fn(info)` - called after taskFun is run (see g.t).

* `g.t(taskName)` | `g.t(taskName, taskFun)` | `g.t(taskName, taskDependecies, taskFun)` |  `g.t(taskName, taskFun, userData)` | `g.t(taskName, taskDependecies, taskFun, userData)` - adds a task. Tasks are added as keys to `g.tasks` object, so `taskName` must be a valid JS object key name. Adding a task with same name a previous one, replaces it.
    * `taskName` - string (valid JS object key name)
    * `taskDependecies` - optional string, or array of strings of task names to be run before
    * `taskFun(cb, info)` - optional body of the task. The optional `info` object contains information about the task `{taskName, task, runner}`. Normally, this should be treated as read-only information, but you can modify any custom `userData` passed to `g.t`. There are several valid ways to denote that you are done within the taskFun:
        * Call `cb();` on success, or `cb(error);` on error. If your code calls `cb` it must be called once.
        * Return a JS promise. Any promise object that supports `then` is supported. In this case you should **not** call `cb()`.
        * Return a `Stream`, such as `return gulp.src(...).pipe(...);`. In this case you should **not** call `cb()`.
        * Emit an error is a returned stream. In this case you should **not** call `cb()`.
        * In a returned promise `throw` an error, or fail. In this case you should **not** call `cb()`.
        * `throw` a JS error. This works only directly within taskFun. If you throw in a pipe, or setTimeout, and similar async functions, node.js will stop execution. Use callbacks in such cases.
    * `userData` can be any object, accessible via info.task.userData within `taskFun`

* `g.addTask` - this is a synonym for `g.t`. While you can add tasks directly to `g.tasks`, using `g.t` is recommended.

* `g.run(taskName, cb)` - is used to run a task. When used via command-line this function is called for you with `--gtask` tasks. This function does not block, use `cb(error)` to be notified when done. If a task has any dependencies, then those task will be run before (recursively). `g.run()` only reads options and tasks, so you can invoke `g.run()` more than once on same instance without waiting for previous invocation to finish (as long as you do not modify options in between).

* `g.log(msg, isError)` - writes `msg` string in `console.log`, or if `isError=true` in `console.error`.


