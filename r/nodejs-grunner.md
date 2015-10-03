2016

#GRunner

<!--- tags: javascript nodejs -->

**[GRunner](https://www.npmjs.com/package/grunner)** is a task runner for [Node.js](https://nodejs.org/), inspired by and compatible with [Gulp](http://gulpjs.com/). Most Gulp plugins and Gulp streams, such as, `gulp.src`, can be used as they are with GRunner. Gulp 3 has some task limitations that are addressed in [Gulp 4](https://github.com/gulpjs/gulp/tree/4.0). GRunner task scheduler is based on [async](https://github.com/caolan/async) and it is *subjectively* better :). If you ever found Gulp task handling somehow limiting, you are at the right place. GRunner uses some ES2015 features, so it needs a recent version of Node.js. GRunner is handy if you enjoy automating things by writing Node.js code.

##Usage

Install globally for comfort:

```
npm install grunner -g
```

To install locally in your node project where the task file is:

```
npm i grunner -D
```

If installed locally, you can run GRunner as `npm run grunner` appending any arguments. If that does not work add the following to your `package.json`:

```
  "scripts": {
    "grunner": "grunner"
  }
```

And run it as `npm run grunner --`, appending any arguments after `--`.

Tasks are coded in Javascript files. Default task file name is `gfile.js`:

```javascript
'use strict';

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

GRunner does not use Gulp (other that for unit testing to check it can work with it). Using Gulp is not a requirement for using GRunner. GRunner can be used with own task logic that does not need anything from Gulp. And if you like to, you can use GRunner with most Gulp plugins, as well with `gulp.src`, and other Gulp stream based constructs, similarly, as you would use them inside Gulp tasks. 

##Command Line Reference

Specifying task files:

* `--gfile fileOrDiretoryPath` - process specified file as a `grunner` tasks file. If nothing is specified `gfile.js` is assumed. If a folder is specified, all JS files there are loaded (using `require`) recursively including sub folders. `--gfile` can be repeated more than once to specify one or more files and folders. Each file is loaded only once. The last task with a given name that is processed wins.

Specifying tasks to run:

* `--gtask taskName` - task name to run. If not set, `default` task name is assumed. `--gtask` can be repeated as needed - all tasks are run by default blocking in the given order (if you like them to be started non-blocking use `--P`).

Other options:

* `--T` - list all tasks and exit.
* `--D` - dry run tasks according to dependencies, but do not invoke task functions.
* `--P` - by default `--gtask` tasks run blocking one after the other. If `--P` is specified they are started non-blocking.
* `--C` - GRunner does circular dependency loop detection as it runs the tasks by default. If you do **not** need that functionality, turn it off by specifying this option.
* `--L timeInMinutes` - if set, the process will self terminate when the time in minutes is reached.
* `--env.KEY=VALUE` - this is a convenience option to set environment variables. It is same as calling `export KEY=VALUE` in `bash` shell, before calling `grunner`. This option helps to set environment variables without the need for some platform specific surrounding script (see also `g.env` API function). It can be repeated as needed.

##Task Dependencies

When you define a task (via `G.t`) you can pass optional task dependencies to be run before it as second argument. Dependencies can be a task name as string, or a array of task name strings. *Nested* arrays are supported and have special meaning.

* `G.t('t1')` - no dependencies.
* `G.t('t2', 't1')` - `t1` will be run before `t2`.
* `G.t('t3', ['t1', 't2'])` - sequential, `t1` will be run first then `t2`, and then `t3`.
* `G.t('t4', ['t1', ['t2', 't3'], 't1'])` - `t1` will be run first, then `t2` and `t3` will both start in parallel, then `t1` will run again after `t2` and `t3` are done, and then `t4` will run.
* `G.t('t3', [['t1', 't2'])` - `t1` and `t2` will start first in parallel, and then `t3` will run once `t1` and `t2` are both done.

*Parallel* here means execution will not block, *sequential* means the execution blocks until all tasks before finish. In general, if the task dependencies array is considered *level 1* and the first nested arrays as level 2, then the tasks in *even* levels of nested arrays are started in parallel and those in *odd* levels are started sequentially. Tasks started in parallel have pipe symbol `|` listed in console before their name. Run-time nesting depth of tasks is shown in console with dots `.` before the task name.

Circular task dependencies, such as, `G.t('t1', ['t2']); G.t('t2', ['t1']);`, direct or indirect, will result in failure.

##GRunner Instances

When you use `let G = require('grunner');` you get *same* process wide singleton instance `G` of `GRunner` class. This instance `G` is used by default, by all `gfile.js` tasks. If you want to use the `grunner` command-line, you should only use this process wide singleton object to define your tasks. 

For more advanced scenarios, you can create as many `GRunner` instances as needed using code such as:

```javascript
let G = require('grunner');
G.t('t1'); // G is the per process singleton instance

let g1 = new G.GRunner(); // new instance
let g2 = new G.GRunner(); // another new instance
g1.t('t1'); // a task on g1 instance
g2.t('t1'); // a task on g2 instance

g1.run('t1'); // run t1 on g1
g2.run('t1'); // run t1 on g2
```

Instances do not share any state, same task name in two different instances can be used to mean two different things. Methods documented in *Task API Reference* section can be called on any `GRunner` instance. The `new G.GRunner()` can be called only on the process singleton instance. The `run` method does not block. 

When using the `grunner` command-line tool, `G.run` is called for you automatically. Using `grunner` command-line tool is just a convenience. You can also use `.js` task files (that include others via `require`) that call `G.run` explicitly, and run those task files directly via `node`. For example, to debug your `gfile.js` you can start with something like this:

```javascript
let G = require('grunner');
require('./gfile.js');
G.run('default', err => {
  console.log('done');
});
```


##Invoking External Tools

GRunner tasks are non-blocking, but there is no direct *parallelism* involved. If you invoke external tools in the tasks, they will run in separate processes and achieve thus parallelism. Arbitrary Node.js code can be run similarly in a different process, if wished, by using `node` as an external tool (you cannot easy share process memory, but normally build and deploy tasks process and share files). As an example, lets use [GSpawn](https://www.npmjs.com/package/gspawn) library to run some arbitrary JS code found in an external file, in a separate process as part of a GRunner task function:

```javascript
...
let gspawn = require('gspawn');
...
let extern = (filePath, cmd) => {
    return cb => {
        gspawn({
           cmd: cmd || 'node',
           args: filePath,
           resolveCmd: true,
           logCall: true,
           log: (txt, src) => G.log(txt, !(src % 2), cb.ctx.taskName),
           expectedExitCode: 0
        }, cb);
    };
};

G.t('t1', extern('./t1.js'));
```

The console output (`log`) of the external task in the example is redirected to be printed via `G.log` for consistent formating.

##Watching for File Changes

Example of using [npm-watch](https://www.npmjs.com/package/npm-watch) with GRunner. Modify your `package.json` to add:

```
  "watch": {
    "mywatch": "app/*.js"
  },
  "scripts": {
    "mywatch": "grunner --gfile gfile.js --gtask myWatchTask",
    "watch": "npm-watch"
  }
```

And start watching using:

```
npm run watch
```

See [npm-watch](https://www.npmjs.com/package/npm-watch) documentation for more information.

##Task API Reference

In the sections that follow `g` represents a `GRunner` instance object.

###API: Tasks

* `GRunner([options])` - constructor, you can pass an optional `options` object. Options can be accessed also via `g.options`. Options can be changed at any time before calling `g.run()`. Available options are:
    * `log = fn(msg, isError, taskName)` - replaces the internal log function which logs in `console`.
    * `name` - if set, instance name is used by default log function and printed in console.
    * `exec = fn(doneCb)` - gives an option to wrap each `taskFun` call. Basically, `fn` could be implemented as:
        ```javascript 
        if(!ctx.task.cb) { doneCb(); return; }
        return ctx.task.cb(doneCb);
        ```
    * `dryRun` - if `true`, same as `--D` command-line option.
    * `beforeTaskRun = fn(ctx)` - called before taskFun is run (see `g.t` for `ctx`). This method and the next are intended for extra logging and testing. For more advanced wrapping use the `exec` option.
    * `afterTaskRun = fn(ctx)` - called after `taskFun` is run (see `g.t` for `ctx`).
    * `noLoopDetection` - if `true`, same `--C` command-line option. 

* `g.t(...)` - adds a task and has several forms:

    ```javascript
      g.t(taskName) 
      g.t(taskName, taskFun)
      g.t(taskName, taskDependecies, taskFun)
      g.t(taskName, taskFun, userData)
      g.t(taskName, taskDependecies, taskFun, userData)
    ```
  Tasks are added as keys (`taskName`) to `g.tasks` object. Adding a task with same `taskName` as a previous one, replaces it. While you can add tasks directly to `g.tasks` (and sometimes this can be useful), using `g.t` is recommended. The arguments of `g.t(...)` are:
    * `taskName` - string (valid JS object key name).
    * `taskDependecies` - optional string, or array of strings of task names to be run before.
    * `taskFun(cb)` - optional body of the task. The optional `ct.ctx` object contains information about the task `ctx = {taskName, task, runner}` , where `runner` is the GRunner instance. Normally, `cb.ctx` should be treated as read-only information, but you can modify the custom `userData` passed to `g.t`. There are several valid ways to denote that you are done within `taskFun` code:
        * Call `cb();` on success, or `cb(error);` on error. If your code calls `cb`, it must be called once.
        * Return a JS *promise*. Any promise object that supports `then` is supported. In this case you should **not** call `cb()`.
        * Return a `stream`, such as `return gulp.src(...).pipe(...);`. In this case you should **not** call `cb()`.
        * A bit more advanced, instead of returning a stream or promise, call `cb.onDone(streamOrPromise, [cbFn]);` on a stream or promise. You may never need this, but if you ever feel like you need it, it can come handy. In this case you should **not** call `cb()`. You should also **not** `return` anything in this case from `taskFun`. `cb.onDone(null);` is same as calling `cb();` directly. The optional `[cbFn]` parameter enables wrapping the `taskFun` `cb()` call in your own function. If you do that, call `cb()` on your own within it.

        You can also exit a task using errors:

        * Emit an error in a returned `stream`. In this case, you should **not** call `cb()`.
        * In a returned *promise* `throw` an error, or fail. In this case you should **not** call `cb()`.
        * `throw` a JS error. This works only directly within `taskFun`. If you `throw` inside a `pipe` stream, or `setTimeout`, and similar async functions, Node.js will stop execution. Use `try / catch` and callbacks to report errors in such cases.
        
        The `taskFun` callback `cb` contains the following properties:

        * `cb.ctx` - described above. Example:
          ```javascript
          g.t('tt', cb => {
            console.log(cb.ctx.task.userData);
            cb();
            });
          ```

        * `cb.onDone(streamOrPromise, [cbFn])` - described above. Example:
          ```javascript
          g.t('tt', cb => {
            let s = gulp.src(...).pipe(g.pipeThrough(...));
            cb.onDone(s, () => {
              console.log('done');
              cb();
              });
            });
          ```
          
    * `userData` - can be any object, accessible via `cb.ctx.task.userData` within `taskFun`.

* `g.addTask` - this is a synonym for `g.t`.

* `g.tasks` - array of tasks. Use `g.t` to add tasks to `g.tasks`. The minimal task object is `{dep: [], cb: null, userData: null}`. You can modify `g.tasks` as needed in advanced scenarios. `dep` is a javascript array and it is easy to manipulate.

* `g.run(taskName, cb)` - is used to run a task. When used via command-line this function is called for you for each `--gtask` task. `g.run` does not block - use `cb(error)` to be notified when done. If a task has any dependencies, then those tasks will be run before (*recursively*). `g.run()` only reads options and tasks, so you can invoke `g.run()` more than once on same instance without waiting for previous invocation to finish (as long as you do not modify options and tasks in between).

* `g.log(msg, [isError], [taskName])` - writes `msg` string in `console.log`, or if `isError=true` in `console.error`. You can replace this function with your own, by using `g.options.log`. If `g.options.name` is set, the default logger prints the name before each log statement. If you call `g.log` in your own tasks, it is a good idea to pass the `taskName` parameter, so that parallel tasks logs can be distinguished.

* `g.dumpTasks([logger])` - dump the current list of tasks using `console.log` (can be changed by supplying your own `logger(str)` function). Used by `--T` command-line option.

###API: Helpers

The following helper functions are provided:

* `g.pipeStart([objectOrIterator])` - returns a starting object `stream` from one or more objects. If an array or iterator is given as argument, then there will be an element in stream per each array or iterator element. For example:
   ```javascript
   g.t('tt', () => {
   return g.pipeStart(['a', 'b', 'c'])
   .pipe(g.pipeThrough(o, _cb) => {
     console.log(o); // o is 'a' on first call
     _cb.push(o);
     _cb(); // or _cb(null, o);
   }));
   });
  ```

* `g.pipeThrough([eachFn], [flushFn])` - this is a wrapper around [through2](https://www.npmjs.com/package/through2) object streams. `eachFn(o, cbFn)` is called for every stream object. `flushFn(cbFn)`, if specified, is called when the stream ends. The callback `cbFn` must be called within these function's code. For `eachFn`, the callback is `cbFn([error], [object])` and it can be used to return an optional `object` in the successive stream. For `flushFn`, the callback is `cbFn([error])`. Both `cnFn` functions have a `cbFn.push(object)` function property to introduce additional objects in successive stream. See `g.pipeStart` above for an example.

* `g.setProcessMaxLifeTime(timeInMinutes, [cb])` - if set to a `timeInMinutes > 0`, then the process will terminate when that time is reached. To reset the timer, call same function with a new value. `0` cancels any existing timer. The timer is per GRunner instance, but the process is killed, no matter what instance timer expires first. The optional callback `cb` is called if set, in place of `process.exit(1)`. The `--L` command-line option calls this function on global ` G` instance.

* `g.env(key)` - returns `process.env[key]`. Additionally, this function knows to process nested environment variables in values using the special `[[KEY]]` syntax. For example, if `K1=V1` and `K2=V2[[K1]]`, then `g.env('K2')` will return `V2V1`. Environment variable nesting and replacement is platform specific (both syntax and behavior). This function offers a way to handle environment variable nesting using own platform agnostic syntax, if needed. Non found variables are replaced with empty values.

* `g.envValue(value)` - this is similar to `g.env(key)`, but operates on a `process.env[key]` returned value (and not `key` name). 

###API: Files

Some simple low level file manipulation functions are provided. You can either use these (you can call them on any GRunner instance), or `gulp.src`, or other similar libraries.

* `g.fileReadBin(file, [throwErr])` - (synchronous) reads a file as a buffer. By default if file is not found or in case of error `null` is returned. Passing `true` for `throwErr` will raise an error instead of retuning `null`.

* `g.fileReadTxt(file, [throwErr])` - (synchronous) reads a file as UTF8 text taking care to remove BOM if present. Same semantics as `g.fileReadBin` for errors.

* `g.fileReadJson(file, [throwErr])` - (synchronous) returns an object from a JSON file. Same semantics as `g.fileReadBin` for errors.

* `g.fileWriteBin(file, data)` - (synchronous) write data to file. If the folder of file does not exist it is created.

* `g.fileWriteTxt(file, data)` - (synchronous) write data to file as UTF8. If the folder of file does not exist it is created.

* `g.fileWriteJson(file, data)` - (synchronous) write data object to file. If the folder of file does not exist it is created.

* `g.files(dir, [recursive], [filter])` - normally you would use `gulp.src` to get a stream of files, or the `glob` module. I have found `glob` module to be not very reliable with [UNC](https://en.wikipedia.org/wiki/Universal_Naming_Convention) paths, so this function offers a simple alternative. It will return all files in a given folder specified by `dir`. If `recursive` is `true` then all files in all subfolder are returned. `filter` is an optional function of form `fn(fileObject)` that can be used to filter which files are included by returning `true` (or `false` not to include them). The `fileObject` is of form: `{dir, file, name, ext}` - where `dir` is the path passed to `g.files`, `file` is the absolute path of file, `name` is the filename with extension and `ext` is the file extension together with the dot. `g.files` returns *immediately* a `stream` of `fileObject`s. Assuming you have imported `gulp` `File` class, you can interface the file data provided by the stream returned by `g.files` function to the `gulp` one, by using code similar to the following:

  ```javascript
  g.t('tt', () => {
    return g.files('./src', true, obj => (/^\.js$/i).test(obj.ext))
      .pipe(g.pipeThrough((o, _cb) => {
        _cb(null, new File({ base: '', cwd: '', path: o.file }));
      }))
      .pipe(gulp.dest(...));  
  });
  ```
* `g.rm(dirOrFile)` - (synchronous) will delete `dirOrFile` completely if it exists or do nothing if it does not exist. This function retries internally several times on folders to avoid possible timing issues before giving up.

