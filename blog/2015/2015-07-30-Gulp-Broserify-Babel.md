#Gulp, Broserify, Babel

2015-07-30

<!--- tags: javascript deployment nodejs -->

I wanted a simple [Gulp](http://gulpjs.com/) script to get started with client-side [Babel](https://babeljs.io/) projects. Starting with a [Gist](https://gist.github.com/danharper/3ca2273125f500429945), and scanning various resources, I come up with the following:

```javascript
var gulp = require('gulp');
var babelify = require('babelify');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var del = require('del');
var clc = require('cli-color');

var path = { 
    src: './app/', 
    dst: './dist/',
    s: function(p) { return this.src + p; },
    d: function(p) { return this.dst + p; },
};

var staticFiles = [path.s('index.html'), path.s('index.css')];

function compile(watch) {
    gulp.src(staticFiles)
    .pipe(gulp.dest(path.dst));

    var b = browserify(path.s('app.js'))
    .transform(babelify)
    .bundle();

    if(watch){
        b = b.on('error', function(err){ 
            console.log(clc.red('### Babel Parsing Error ###'));
            console.log(err.message); 
            console.log(err.filename + ' @' + err.loc); 
            console.log(err.codeFrame);
            });
    }

    b.pipe(source('app.js'))
    .pipe(gulp.dest(path.dst));
}

gulp.task('clear', function(cb) { 
    del(path.dst, cb);
    //cb(null);
});
gulp.task('build', ['clear'], function(cb) { 
    compile(); 
    cb(null);
});
gulp.task('build-no-error', ['clear'], function(cb) { 
    compile(true); 
    cb(null);
});
gulp.task('watch', function(cb) {
    compile(true); 
    gulp.watch([
        path.s('**/*.js'),
        path.s('**/*.html'),
        path.s('**/*.css')
        ], ['build-no-error'])
});
gulp.task('default', ['build']);
```

In `packages.json`, I can have then something like:

```javascript
  "scripts": {
    "build": "node node_modules/gulp/bin/gulp.js build",
    "watch": "node node_modules/gulp/bin/gulp.js watch"
  },
```

The Gulp script assumes the application has the following structure:

```
.
├── app
├── dist
└── node_modules
 gulpfile.js
 package.json
```

Source files are in `./app` and distribution destination is in `./dist`. In Gulp script `staticFiles` can contain files and folders to be copied verbatim. `*.js` files are run though Babel and then Broserify. The compile part normally fails on Babel errors. However, on *watch* case for continuous building on file save, I do not want to kill the Gulp build script, so I just print the Babel error in color and continue. Modify the script as needed for full projects.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-08-22-Strange-visudo-Error.md'>Strange visudo Error</a> <a id='fnext' href='#blog/2015/2015-07-21-Pure-UI-In-Javascript.md'>Pure UI In Javascript</a></ins>
