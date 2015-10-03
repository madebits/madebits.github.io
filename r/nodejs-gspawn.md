2016

#GSpawn

<!--- tags: javascript nodejs -->

**[GSpawn](https://www.npmjs.com/package/gspawn)** is a library to invoke external tools for Node.js. `gspawn` wraps Node.js `child_process.spawn` to make it easier to invoke external tools. `gspawn` is similar to `child_process.exec`, but without some of `child_process.exec` limitations.

##Usage

To install:

```
npm install gspawn --save
```

Usage example:

```
var gspawn = require('gspawn');

gspawn({
    cmd: 'bash',
    args: ['-c', 'ls -l'],
    resolveCmd: true,
    collectStdout: true,
    logCall: true
    }, function(err, exitCode, signal, stdoutTxt, stderrTxt) {
    });
```

##Details

`gspawn(options, cb)` is the only exposed function. It returns the started `child_process` instance. This function is non-blocking. To be informed about the external stated process end (or of any possible errors), use the `cb` callback parameter. The callback `cb` is a function of form `fn(error, exitCode, signal, stdoutTxt, stderrTxt)`, where:
    
* `error` - not null in case of errors
* `exitCode` - exit code of spawned process
* `signal` - if known, signal use to close the process (may not be set)
* `stdoutTxt` - default null or empty, see `options.collectStdout`.
* `stderrTxt` - default null or empty, see `options.collectStderr`.

A summary of available `gspawn` `options` follows (*boolean* options are all by default `false`):

* `cmd`: the command to run. This can be a full system path, or a relative path if the command is inside the node package, or a command name (see `resolveCmd` option).

* `args`: optional command line arguments for `cmd`. This can be null, a string, or an array of string (one arry element per each option) (passed to `child_process.spawn` after checks).

* `resolveCmd`: if the `cmd` is a system program, such as, `bash`, specifying `resolveCmd: true` uses (which)[https://github.com/npm/node-which] library to find the whole path of the `cmd`.

* `options`: if set, are passed as are to `child_process.spawn`. See `child_process.spawn` documentation, to specify `options.options.env`, and `options.options.cwd`.

* `autoCwd`: if set to `true`, then `options.options.cwd` is set to folder of `cmd` executable.

* `timeout`: if set (in milliseconds - 1 second = 1000 mls) then the process will be killed if the specified timeout is reached. Check the `exitCode` in callback `cb` to detect a timeout occurred if needed.

* `expectedExitCode`: if set and `gspawn` process exit code is different, then an error is reported in `gspawn` callback. 

* `log`: by default, the `gspawn` logs any process console output in *stdout* / *stderr*, using `console.log` / `console.error`. You can customize logging, by passing a function to `log`. The `log` function has the form `fn(data, source, defaultLogFunction)`:
    * `data` - are the text data to log coming from process OR from `gspwan` call
    * `source` - can have one of these values: `1` data comes from stdout, `2` data comes from stderr, `3` data comes `gspwan` call printing `cmd` invocation (see `logCall` option), `4` data comes `gspawn` printing any possible `cmd` error.
    * `defaultLogFunction`: this the default log function used by `gspawn`. You can process `data` for example to remove any sensitive information (such as passwords) and then call `defaultLogFunction(data, source)` to continue printing.

* `logCall`: if set to `true`, then the command invocation (tool and arguments) and any errors will be also logged. See also `log` if you want to customize any of this further.

* `collectStdout`: if set to true, *stdout* output is collected into an array and delivered as string in `gspwan` callback `cb` when process ends. There is no limit on how many text is collected, so be careful. Using `log` option is a better way to look for pattern in longer text. If `false` (default), then in `gspwan` callback `cb` you get an empty or null string.

* `collectStderr`: same as `collectStdout`, but for *stderr*. 

##Examples

* Bash

    ```
    gspawn({
        cmd: 'bash',
        args: ['-c', 'ls -l'],
        resolveCmd: true,
        logCall: true,
        expectedExitCode: 0
    }, function(err, exitCode, signal, stdoutTxt, stderrTxt) {
    });    
    ```

* Node.js

    ```
    gspawn({
        cmd: 'node',
        args: ['./test.js'],
        resolveCmd: true,
        logCall: true,
        expectedExitCode: 0
    }, function(err, exitCode, signal, stdoutTxt, stderrTxt) {
    });
    ```

* npm run script:

    ```
    gspawn({
        cmd: 'npm',
        args: ['run', 'testCmd'],
        resolveCmd: true,
        logCall: true,
        expectedExitCode: 0
    }, function(err, exitCode, signal, stdoutTxt, stderrTxt) {
    });
    ```

