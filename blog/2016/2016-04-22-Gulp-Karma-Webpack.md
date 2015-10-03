#Gulp with Karma and Webpack

2016-04-22

<!--- tags: javascript architecture -->

[Webpack](https://webpack.github.io/) is a cool tool that helps bundle Javascript applications. I had to port an existing Angular 1.x application from a Grunt based build to Webpack and decided for maximum control to trigger Webpack and [Karma](https://karma-runner.github.io) via [Gulp](http://gulpjs.com/) task runner. 

<div id='toc'></div>

##Gulpfile

Gulp configuration file is below, with explanation to follow:

```javascript
'use strict';

var gulp = require('gulp')
    , args = require('yargs').argv
    , path = require('path')
    , gutil = require('gulp-util')
    , del = require('del')
    , webpack = require('webpack')
    , WebpackDevServer = require("webpack-dev-server")
    , KarmaServer = require('karma').Server
    , fs = require('fs')
    , wpConfigMaker = require(path.join(__dirname,'./webpack.make.js'))
    ;

//env
if(args && args.env) {
    Object.keys(args.env).forEach(function(envKey){
        var ov = process.env[envKey] ? ' (overwritten)' : '';
        gutil.log('Environment: ' + envKey + '=' + args.env[envKey] + ov);
        process.env[envKey] = args.env[envKey];
    });
}

var wpCreate = function(ctx, modifyConfigFn) {
    var config = wpConfigMaker(ctx);
    if(modifyConfigFn) {
        config = modifyConfigFn(config);
    }
    return webpack(config);
};

var wpPrintStats = function (stats, modifyConfigFn) {
    if(stats) {
        var config = {
            colors: true
            , chunks: false
            , modules: false
            , errorDetails: true
        };
        if(modifyConfigFn) config = modifyConfigFn(config);
        gutil.log(gutil.colors.green.bold('[WebPack]'), stats.toString(config));

        if(!!process.env.BL_WP_STATS) {
            fs.writeFileSync(
                path.join(__dirname, './webpack.stats.json')
                , JSON.stringify(stats.toJson({
                    context: path.resolve(__dirname)
                    , source: false
                    , chunkModules: true
                }), null, '\t'));
        }
    }
};

var wpRun = function(wp, cb) {
    wp.run(function (err, stats) {
        wpPrintStats(stats);
        if(!err && stats && stats.hasErrors()) {
            err = new Error('Build Failed!');
        }
        if(!err && stats && stats.hasWarnings()) {
            var data = stats.toJson({
                context: path.resolve(__dirname)
                , source: false
            });
            data.warnings.forEach(function (w) {
                if (err) return;
                var parts = w.split('\n');
                if ((parts.length > 0) && parts[0].toLowerCase().endsWith('.html'))
                    && (w.indexOf('Parse Error') >= 0)) {
                    err = new Error('Build Failed! (' + parts[0] + ')');
                }
            });
        }
        if(err) console.error(err);
        if(cb) cb(err);
    });
};

var wpWatch = function(wp, cb) {
    return wp.watch({}, function (err, stats) {
        wpPrintStats(stats, function (config) {
            config.assets = false;
            return config;
        });
        gutil.log(gutil.colors.magenta('Done!'));
        if(err) console.error(err);
        if(cb) cb(err);
    });
};

var wpCreateAndRun = function (ctx, cb) {
    wpRun(wpCreate(ctx), cb);
};

var wpRunServer = function(options) {
    options = options || {};
    options.hot = true;
    var serverConfig;
    var wp = wpCreate(options, function(config) {
        serverConfig = config.devServer;
        return config;
    });
    gutil.log('webpack-dev-server: ' + serverConfig.host + ':' + serverConfig.port + ' Press Ctrl+C to stop!');
    new WebpackDevServer(wp, serverConfig).listen(serverConfig.port, serverConfig.host, function(err) {
        if(err) throw new gutil.PluginError('webpack-dev-server', err);
    });
};

var runTests = function(cb, modifyConfigFn) {
    if(!cb) cb = function() { };
    var config = {
        configFile: path.join(__dirname, './karma.conf.js'),
        singleRun: true
    };
    if(modifyConfigFn) {
        config = modifyConfigFn(config);
    }
    new KarmaServer(config, function(exitCode){
        cb();
        process.exit(exitCode);
    }).start();
};

var runTestWatch = function(cb, modifyConfigFn) {
    runTests(cb, function(config){
        config.singleRun = false;
        config.autoWatch = true;
        if(modifyConfigFn) {
            config = modifyConfigFn(config);
        }
        return config;
    });
};

gulp.task('unlink', function() {
    return del([
        path.join(__dirname, './dist/**/*')
        , path.join(__dirname, './testresults/**/*')
        , path.join(__dirname, 'webpack.stats.json')
    ]);
});

gulp.task('clean', ['unlink'], function() {
    return gulp.src([
        'bower_components/angular/angular.min.js'
        , 'bower_component/jquery/dist/jquery.min.js'
    ].map(function(p){
        return path.join(__dirname, p);
    })).pipe(gulp.dest(path.join(__dirname, 'static/assets/lib')));
});

gulp.task('build-release', ['clean'], function(cb) { wpCreateAndRun({ optimize: true }, cb); });

gulp.task('build-debug', ['clean'], function(cb) { wpCreateAndRun(null, cb); });

gulp.task('build-watch', ['clean'], function(cb) {
    wpWatch(wpCreate());
});

///////////////////////////////////////////////////////////////////////////////

gulp.task('build-watch-test', ['clean'], function(cb) {
    runTestWatch(null, function(config) {
        config.reporters = [ 'progress' ];
        return config;
    });
    var wp = wpCreate();
    wpWatch(wp);
});

gulp.task('start', ['clean'], function() {
    wpRunServer();
});

//gulp.task('start-auto', ['clean'], function() {
//    wpRunServer({ auto: true });
//});

gulp.task('start-test', ['clean'], function() {
    runTestWatch(null, function(config) {
        config.reporters = [ 'progress' ];
        return config;
    });
    wpRunServer();
});

///////////////////////////////////////////////////////////////////////////////

gulp.task('test-release', function(cb) {
    process.env.BL_NDEBUG = 1;
    runTests(cb, function(config) {
        config.reporters = [ 'mocha', 'html', 'coverage' ];
        return config;
    });
});

gulp.task('test-debug', function(cb) {
    runTests(cb, function(config){
        var browser = process.env.BL_KARMA_BROWSER || 'Chrome';
        config.browsers = [ browser ];
        config.reporters = [ 'progress' ];
        return config;
    });
});

gulp.task('test-watch', function(cb) {
    runTestWatch(null, function(config) {
        var browser = process.env.BL_KARMA_BROWSER || 'PhantomJS';
        config.browsers = [ browser ];
        return config;
    });
});

///////////////////////////////////////////////////////////////////////////////

```

Webpack Node API documentation is quite good, but I had to look occasionally at source code to figure out the best way to connected tools together. Some of the advanced combinations (watch / build / test) are handled a bit differently from what Webpack documentation and wiki suggest. I think the way I did it, is better. I do not use the Gulp tasks directly, rather via `npm` script commands in `package.json`:

```javascript
...
"scripts": {
    "gulp": "gulp",
    "build-release": "npm run gulp -- build-release",
    "build-debug": "npm run gulp -- build-debug",
    "build-watch": "npm run gulp -- build-watch",
    "build-watch-test": "npm run gulp -- build-watch-test",
    "start": "npm run gulp -- start",
    "start-test": "npm run gulp -- start-test",
    "test-release": "npm run gulp -- test-release",
    "test-debug": "npm run gulp -- test-debug",
    "test-watch": "npm run gulp -- test-watch"
  },
...
```

Usually, only `npm run start` and `npm run build-release` are used.

##Programmatically Loading Webpack Configuration

The trick is to organize webpack configuration in two files, with `webpack.config.js` being a one-liner:

```javascript
module.exports = require('./webpack.make')();
```

And the actual `webpack.make.js`, so that I could pass any option I needed from Gulp as JS object and not via environment variables:

```javascript
...
module.exports = function(options) {
    ...
    return config;
};
```

Loading Webpack configuration from a single parameterized Javascript file has the advantage of having only one file to maintain for different build context. I choose to parameterize by features I turn off and on, and not based on build type. This simplifies the code inside `webpack.make.js`.

##Using Webpack with Karma

In a similar way, in `karma.conf.js`, I can load the Webpack configuration with parameters, to denote the test-like context:

```javascript
var path = require('path');

module.exports = function(config) {

    var webpackConfig = require(path.join(__dirname,'./webpack.make.js'))({ test: true });

    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',

        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: ['jasmine'],

        plugins: [
            'karma-chrome-launcher',
            'karma-jasmine',
            'karma-sourcemap-loader',
            'karma-webpack',
            'karma-phantomjs-launcher',
            'karma-mocha-reporter',
            'karma-html-reporter',
            'karma-coverage'
        ],

        // list of files / patterns to load in the browser
        files: [
            './app/third.js',
            'test.bundle.js'
        ],

        // list of files to exclude
        exclude: [
        ],

        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: {
            './app/third.js': ['webpack', 'sourcemap'],
            'test.bundle.js': ['webpack', 'sourcemap']
        },


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['mocha'], //['progress'],

        coverageReporter: {
          dir: 'testresults/coverage/',
          reporters: [
              {type: 'text-summary'},
              {type: 'html'}
          ]
        },

        htmlReporter: {
            outputDir: 'testresults/Reports/'
            , namedFiles: true
            , reportName: 'jstest-1'
            , pageTitle: 'JsTest'
        },

        // web server port
        port: 9876,

        // enable / disable colors in the output (reporters and logs)
        colors: true,

        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,

        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: false,

        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['PhantomJS'], //['Chrome'],

        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: true,

        // Concurrency level
        // how many browser should be started simultaneous
        concurrency: Infinity,

        //webpack
        webpack: webpackConfig,

        webpackMiddleware: {
            noInfo: 'errors-only'
        }

    });

};
```

Where `test.bundle.js` is based on [angular-tips](http://angular-tips.com/blog/2015/06/using-angular-1-dot-x-with-es6-and-webpack/):

```javascript
import 'angular-mocks';

let context = require.context('./app', true, /.+\.spec\.js$/);
context.keys().forEach(context);
module.exports = context;
```

I found out that making use of `require.context` was also useful to load all existing views, directives, and controller in the application (they were in their own folders), to avoid having to `require` all of the explicitly.

##Webpack Configuration

Webpack is straightforward once you manage to get it run :). Until you reach that point, there is a learning curve. There are tens of Webpack loaders and plugins and it non-trivial to find how to connected all of them together based on documentation alone, including searching Google. I found *loaders* to work better than *plugins*. Several out of box Webpack plugins do not work with Babel, because they generate ES5 code closures before first ES6 `import` which confuses Babel. Given I had an existing application that was not Webpack aware, I had to resolve to some more tricks (like skip some of the static checks I added for existing code at first).

```javascript
'use strict';

var path = require('path')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , CleanWebpackPlugin = require('clean-webpack-plugin')
    , ExtractTextPlugin = require('extract-text-webpack-plugin')
    , UpdateHook = require('webpack-bundle-update-hook-plugin')
    , CopyWebpackPlugin = require('copy-webpack-plugin')
    , autoprefixer = require('autoprefixer')
    , NpmInstallPlugin = require('npm-install-webpack-plugin')
    , util = require('util')
//    , SassLintPlugin = require('sasslint-webpack-plugin')
    ;

module.exports = function(options) {

    var isSet = function(v) {
        if(!v) return false;
        return ((v === true) || (v == "1"));
    };

    options = options || {};
    options.hot = !!options.hot;
    options.optimize = !!options.optimize;
    options.test = !!options.test;
    options.auto = !!options.auto;
    options.verbose = !!options.verbose || isSet(process.env.BL_VERBOSE);
    options.ddebug = !options.optimize && !isSet(process.env.BL_NDEBUG);

    var basePath = process.env.BL_HOST_BASE;

    console.log('WebPack: ' + JSON.stringify(options));

    var toPath = function(p, resolve) {
        p = path.join(__dirname, p);
        return (resolve) ? path.resolve(p) : p;
    };

    var sortedChunkNames = [ 'third', 'vendor', 'app', 'test' ];
    var chunkSorter = function(a, b) {
        var an = a.names[0];
        var bn = b.names[0];
        var ai = sortedChunkNames.indexOf(an);
        var bi = sortedChunkNames.indexOf(bn);
        if(ai > bi) return 1;
        if(ai < bi) return -1;
        if (an[0] > bn[0]) return 1;
        if (an[0] < bn[0]) return -1;
        return 0;
    };

    var server = {
        host: options.host || process.env.HOST || '127.0.0.1'
        , port: options.port || process.env.PORT || '8778'
    };

    var paths = {
        app: toPath('app', true)
        , dist: toPath('dist', true)
        , static: toPath('static', true)
        , testBundle: toPath('test.bundle.js', true)
        , es5: toPath('app/scripts', true)
        , third: toPath('app/third.js', true)
    };

    var includes = [
        paths.app
        , paths.testBundle
    ];

    var includesAll = includes.concat([
        toPath('node_modules', true)
        , toPath('bower_components', true)
    ]);

    var addHotEntries = function (base) {
        if(!options.hot) return base;
        return ['webpack/hot/dev-server', 'webpack-dev-server/client?http://' + server.host + ':' + server.port, base];
    };

    var cssMap =  isSet(process.env.BL_WP_CSSMAP);
    var outName = options.optimize ? '[name]-[hash]' : '[name]';
    var config = {
        //progress: !(options.optimize || options.hot || options.test),
        plugins: [
            new CopyWebpackPlugin([{
                from: path.join(paths.static, 'assets')
            }])
            , new ExtractTextPlugin(outName + '.css', { allChunks: true, disable: options.test || cssMap }) //!options.optimize
            , new webpack.DefinePlugin({ DEBUG: options.ddebug })
            //, new SassLintPlugin({
            //    config: path.join(__dirname, '.sass-lint.yml')
            //    //, glob: '**/*.s?(a|c)ss'
            //    , failOnError: false
            //    , ignorePlugins: [ 'extract-text-webpack-plugin', 'html-webpack-plugin' ]
            //})
            //, new webpack.ResolverPlugin(
            //    new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin(".bower.json", ["main"])
            //)
            //, new webpack.ProvidePlugin({
            //    $: "jquery",
            //    jQuery: "jquery",
            //    "window.jQuery": "jquery",
            //    angular: "angular",
            //    "window.angular": "angular",
            //    "Sortable": "Sortable"
            //})
        ]
        , eslint: {
            configFile: path.join(__dirname, './.eslintrc')
            , parser: 'babel-eslint'
            //, formatter: require('eslint-friendly-formatter')
            , formatter: require('eslint/lib/formatters/visualstudio')
            , failOnError: options.optimize
        }
        , jscs: {
            failOnHint: false,
            reporter: function(errors) {
                var _this = this;
                if(errors.isEmpty()) return;
                var msg = '';
                errors.getErrorList().forEach(function(error) {
                    msg += _this.resourcePath + '(' + error.line + ',' + (error.column + 1) + '): jscs ' + error.rule + ' : ' + error.message + '\n';
                });
                _this.emitWarning(msg);
            }
        }
        , htmlLoader: {

        }
        , resolve: {
            extensions: ['', '.js', '.ts']
                    , modulesDirectories: ['bower_components', 'node_modules']
                    , alias: {
                        'angular-ui-router$': 'angular-ui-router/release/angular-ui-router'
                        , 'sinon$': 'sinon/pkg/sinon.js'
                    }
                }
        , postcss: [ autoprefixer({browsers: ['last 2 versions', 'ie > 8']}) ]
        , devServer: {
            contentBase: paths.dist
            , historyApiFallback: true
            , hot: true
            , inline: true
            , progress: true
            , stats: 'errors-only'
            , host: server.host
            , port: server.port
        }
        , module: {
            noParse: [
                /\/angular\.js/
                , /\/jquery\.js/
            ],
            preLoaders: [
                {
                    test: /\.js$/
                    , include: includes
                    , exclude: [ (options.test ? paths.testBundle : /.+\.spec\.js$/), paths.es5 ]
                    , loaders: [ 'eslint-loader' + (options.test ? '?{ "rules": { "no-undef": 0 } }' : ''), 'jscs-loader' ]
                }
            ],
            loaders: [
                { test: /angular-wizard\.js$/, loader: 'exports?"mgo-angular-wizard"' }
                , { test: /ng-file-upload\.js$/, loader: 'exports?"ngFileUpload"' }
                , { test: /main\.js$/, loader: 'imports?this=>window' }
                , { test: /sinon.js$/, loader: "imports?define=>false,require=>false" }
                , {
                    test: /\.js$/
                    , include: includes
                    , loaders: ['ng-annotate', 'babel?presets[]=es2015']
                }
                , {
                    test: /\.js$/
                    , include: includes
                    , exclude: [paths.third, path.join(paths.app, 'scripts')]
                    , loaders: ['imports?$=jquery,jQuery=jquery,angular']
                }
                //, {
                //    test: /\.ts$/,
                //    loaders: [ 'ng-annotate', 'webpack-typescript?target=ES5', 'imports?jquery,$=jquery,angular' ]
                //}
                //, {
                //    test: /\.ts$/,
                //    include: includes,
                //    loader: 'webpack-append',
                //    query: 'declare var require: any'
                //},
                , {
                    test: /\.(woff|woff2|eot|ttf|svg)(\?.*)?$/
                    , include: includesAll
                    , loader: 'url-loader?limit=8192&name=i/[hash].[ext]'
                }
                , {
                    test: /\.(jpe?g|png|gif)$/i
                    , include: includesAll
                    , loader: 'file?name=i/[path][hash].[ext]'
                }
                , {
                    test: /\.htm$/
                    , include: includesAll
                    , loader: 'html-loader!htmlhint'
                }
                , {
                    test: /\.html$/
                    , include: includesAll
                    , exclude: /\.htm$/
                    , loader: 'ngtemplate-loader?relativeTo=' + paths.app + '/' + '!html-loader!htmlhint'
                }
                , {
                    test: /\.css$/
                    , include: includesAll
                    , loader: cssMap
                        ? 'style!css-loader?sourceMap!postcss-loader'
                        : ExtractTextPlugin.extract('style', 'css-loader?sourceMap!postcss-loader')
                }
                , {
                    test: /\.less$/
                    , include: includesAll
                    , loader: cssMap
                        ? 'style!css-loader?sourceMap!postcss-loader!less-loader?sourceMap'
                        : ExtractTextPlugin.extract('style', 'css-loader?sourceMap!postcss-loader!less-loader?sourceMap')
                }
                , {
                    test: /\.scss$/
                    , include: includesAll
                    , loader: cssMap
                        ? 'style!css-loader?sourceMap!postcss-loader!sass-loader?sourceMap'
                        : ExtractTextPlugin.extract('style', 'css-loader?sourceMap!postcss-loader!sass-loader?sourceMap')
                }
            ]
        }
    };

    if(options.test) {
        config.module.preLoaders.unshift(
            {
                test: /\.js$/
                , include: includes
                , exclude: [ /\.spec\.js$/ ]
                , loader: 'isparta-instrumenter'
            }
        );
    }

    if(options.test) {
        config.entry = { };
        config.devtool = 'inline-source-map'; //'source-map';
    }
    else {
        config.context = paths.app;
        config.cache = !options.optimize;
        config.debug = !options.optimize;
        config.entry = {
            third: './third.js'
            , app: addHotEntries('./index.js')
            , vendor: [
                'angular-cookies'
                , 'angular-translate/angular-translate'
                , 'angular-messages'
                , 'angular-resource'
                , 'angular-animate'
                , 'angular-sanitize'
                , 'Sortable'
                , 'angular-ui-router'
                , 'angular-wizard/dist/angular-wizard'
                , 'angular-touch'
                , 'angular-formly'
                , 'angular-formly-templates-bootstrap'
                , 'angular-ui-mask'
            ]
            //, part2: addHotEntries('./part2.js')
        };
        config.output = {
            path: paths.dist
            , filename: outName + '.js'
        };
        if(!!basePath) config.output.publicPath = basePath;
        config.devtool = options.optimize ? false : 'source-map';
    }

    config.externals = {
        'angular': 'angular'
        , 'jquery': 'jQuery'
    };

    if(!options.test) {

        config.plugins.push(new UpdateHook(),
            new HtmlWebpackPlugin({
                template: 'html!' + path.join(paths.static, 'index.html')
                , filename: 'index.html'
                , inject: 'body'
                , hash: false
                , favicon: path.join(__dirname, 'static/assets/favicon.png')
                , excludeChunks: ['test'] //'part2',
                , chunksSortMode: chunkSorter
            })
            //,
            //new HtmlWebpackPlugin({
            //    template: 'html!' + path.join(paths.static, 'template.html'),
            //    filename: 'part2.html',
            //    inject: 'body',
            //    hash: false,
            //    excludeChunks: ['app', 'test']
            //})
        );

        if(options.optimize) {
            config.plugins.push(
                new webpack.optimize.CommonsChunkPlugin({
                    name: 'vendor'
                    , filename: 'vendor-[hash].js'
                    , chunks: [ 'vendor', 'app' ]
                    , minChunks: Infinity
                })
                , new CleanWebpackPlugin(['dist'], {
                    root: __dirname
                    , verbose: true
                    , dry: false
                })
                , new webpack.NoErrorsPlugin()
                , new webpack.optimize.DedupePlugin()
                , new webpack.optimize.OccurenceOrderPlugin()
                , new webpack.optimize.UglifyJsPlugin({
                    compress: {
                        warnings: false
                    }
                    , mangle: {
                        except: ['$super', '$', 'exports', 'require', 'angular']
                    }
                })
            );
        }

        if(options.hot) {
            config.plugins.push(new webpack.HotModuleReplacementPlugin());
            if(options.auto) {
                config.plugins.push(new NpmInstallPlugin({
                    save: true // --save
                }));
            }
        }
    }

    if(options.dump) {
        console.log(util.inspect(config, { depth: 6, colors: true }));
    }
    if(options.verbose) {
        var lastPercent = 0;
        config.plugins.push(new webpack.ProgressPlugin(function(percentage, msg) {
            var p = Math.floor(percentage * 100);
            if(p != lastPercent) {
                lastPercent = p;
                process.stdout.write('  ' + p + '% ' + msg + '\x1b[0G');
            }
        }));
    }

    if(!options.optimize && !options.test) {
        config.entry.test = addHotEntries('../test.bundle.js');
        config.plugins.push(
            new HtmlWebpackPlugin({
                template: 'html!' + path.join(paths.static, 'test.html')
                , filename: 'test.html'
                , inject: 'body'
                , hash: false
                , chunks: ['third', 'test']
                , chunksSortMode: chunkSorter
            })
        );
    }

    return config;
};

```

Given the existing application used a lot of `bower` libraries, I supported module look up in both `bower` and `npm` folders. Some third-party libraries used work fine with Webpack loading, as they try to detect `module.exports`. However, a lot of third-party libraries written from browser expect to be loaded in browser and need some `import-loader` and `script-loader` tricks to get them work. Other third-party libraries do work with WebPack out of the box, but only if you get the `bower` version and they assume the `npm` one is to be used to build them. The situation with third-party libraries is not so clear for Webpack applications. Nothing that cannot be fixed with some trial and error, but often it packages do not work out of the box.

##Running Unit Tests in HMR Web Server

Running tests with Karma is nice for build server, but during development, I configured unit tests to be run as separate entry point in the hot reload web server (`npm run start` has to entry points one for the application and one `test.html` for the unit tests via [Jasmine](http://jasmine.github.io/) in browser). The `static/test.html` template makes use of a static copy of Jasmine intended for direct browser usage:

```html
<!doctype html>
<html ng-app="app" lang="en">
<head>
    <meta charset="UTF-8">
    <title>Unit Tests</title>
    <link rel="stylesheet" href="jasmine/jasmine.css">
    <script src="jasmine/jasmine.js"></script>
    <script src="jasmine/jasmine-html.js"></script>
    <script src="jasmine/boot.js"></script>
</head>
<body>
</body>
</html>
```

This configuration enables developers to conveniently switch back and forth between the application and unit tests while they are using the hot module replacement web server that Webpack provides for development.

##References

* http://angular-tips.com/blog/2015/06/using-angular-1-dot-x-with-es6-and-webpack/
* https://github.com/AngularClass/NG6-starter
* http://survivejs.com/webpack_react/developing_with_webpack/
* https://github.com/petehunt/webpack-howto
* https://www.youtube.com/watch?v=RKqRj3VgR_c
* http://julienrenaux.fr/2015/03/30/introduction-to-webpack-with-practical-examples/#encode-files
* https://medium.com/@dtothefp/why-can-t-anyone-write-a-simple-webpack-tutorial-d0b075db35ed#.kn2vgewtn
* https://github.com/mvader/react-es6-webpack-karma-boilerplate

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-06-27-Agile-Development-Readings.md'>Agile Development Readings</a> <a rel='next' id='fnext' href='#blog/2016/2016-04-09-Statistical-Learning-Certification.md'>Statistical Learning Certification</a></ins>
