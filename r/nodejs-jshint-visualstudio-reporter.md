2014

#Jshint Visual Studio Reporter

<!--- tags: javascript nodejs -->

A modified version of default console reporter for [jshint](http://www.jshint.com/) that prints the issues in a format suitable for VisualStudio output window.

To use the reporter install JsHint (`npm install -g jshint`) add a post-build step that calls jshint:

```
jshint --reporter $(ProjectDir)jshintvs.js $(ProjectDir)Scripts\App
```

If there are any issues you will get a build error and then all issues are listed in VisualStudio output window. **Double-clicking** a listed issue in VisualStudio output window will jump to the file and the line where the issue is reported.

jshint configuration file can be passed via --config option, or if you have a `packages.json` file in your project, add the configuration there as jshintConfig, for example:
```
"jshintConfig": {
  "laxbreak": true,
  "strict": true
}
```