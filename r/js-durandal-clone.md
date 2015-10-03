2014

#My Durandal.js Clone

<!--- tags: javascript -->

I wanted to understand how [Durandal.js](http://durandaljs.com/) works, so I decided to build a similar minimal clone using more or less same set of components on my own. The components I use are:

* [require.js](http://requirejs.org/) - to organize and load JavaScript code
* [knockout.js](http://knockoutjs.com/) - to organize view models and views
* [jquery](http://jquery.com/) - for DOM manipulation
* [sammy.js](http://sammyjs.org/) - to manage client routing
* 
Apart of sammy.js, Durandal.js uses also the same components.

<div id='toc'></div>

##Application Structure

My application folders and files structure will look as follows:

```
.
├── index.html
├── app
│   ├── main.js
│   ├── models
│   │   ├── view1.js
│   │   └── view2.js
│   ├── viewengine.js
│   └── views
│       ├── view1.html
│       └── view2.html
└── lib
    ├── jquery.js
    ├── knockout.js
    ├── require.js
    └── sammy.js
```

I downloaded all third-party helper JavaScript libraries in the lib/ folder and renamed the files as shown above.

##Entry Page

'index.html' is a plain HTML file with a standard 'require.js' script include and a 'div' with 'id=viewHost' that will contain the actual views. I will keep a static title in the example.

```html
<html>
    <head>
        <title>Test</title>
    </head>
  <body>
    <div id="viewHost"></div>
    <script src="lib/require.js" data-main="app/main"></script>
  </body>
</html>
```

##Application Routing

Similar on Durandal, my 'app/main.js' file looks as follows:

```javascript
requirejs.config({
 paths: {
  'knockout': '../lib/knockout',
  'jquery': '../lib/jquery',
  'router': '../lib/sammy',
  'engine': 'viewengine'
    }
});

define(function (require) {
 var viewEngine = require('engine');
 var router = require('router');
 var app = router(function() {

  this.get('#/app/:name', function() {
   viewEngine.showViewByConvention('viewHost', this.params['name']);
  });
  // add more paths here as needed
 });
 
 app.run('#/app/view1');  
});
```

I have configured my known components in require.js part first. Apart of **viewengine**, that I will implement later on my own, the rest are the third-party components I am using.

In my require.js define function, I use sammy.js router to add a client-side route of form '#/app/:name', where the URL name parameter will be, for me, either view1 or view2. When such a link is activated, I call my viewEngine to show the view based on name URL parameter.

I start my application by telling the router component to navigate to my first view '#/app/view1'. This will trigger the code inside router get method when the page loads.

##Views

Before I write my view engine, I will show how my 'view1.html' looks like:

```html
<h1>View 1</h1>

<p>Data <span data-bind="text: someData"></span></p>

<p><a href="#/app/view2">Go to View 2</a></p>
```

So my views are HTML chunks, that contain optional knockout.js model bindings (data-bind) and optional links as expected by my router.

##Models

The corresponding model of the above view1.html is view1.js:

```javascript
define(function () {

 var myViewModel = {
  someData: 'for view 1'
 };
 return {
  model: myViewModel
 };
});
```

The model is required per convention to return the actual model in the `model` property. This example model does nothing other that define some static data, but one can use any knockout.js observables in my models as needed.

##View Engine

I have now everything ready, so I can write my view engine. The view engine will connect together my views with models and show them on page when asked. The router calls (as shown above) in main.js:

```javascript
viewEngine.showViewByConvention('viewHost', this.params['name']);
```

This is how I implemented this method of the viewEngine:

```javascript
function showViewByConvention(viewHostId, viewName){
 var modelName = 'models/' + viewName;
 require([modelName], function(model){
  showView(viewHostId, 'app/views/' + viewName + '.html', model.model);
 });
}
```

I expect the model and view to be named same apart of suffix. I also expect views to end in .html and models in .js. I load first the model via require.js and when it is loaded I combine it with the view in my showView method. The showView code is a bit longer:

```javascript
function showView(viewHostId, viewUrl, koModel){
 var viewHost = $('#' + viewHostId);
 $.ajax({
   url : viewUrl,
   dataType: 'text',
   success : function (data) {
    viewHost.html(data);
    if(koModel) {
     if(koIsBound(viewHost[0])){
      ko.cleanNode(viewHost[0]);
     }
     ko.applyBindings(koModel, viewHost[0]);
    }
   }
  });
}
```

I get first the DOM object for the given viewHostId using jquery. Then I do an jquery AJAX call to load the view data. Once I have the view data, I set them as HTML in the viewHostId and apply any knockout.js bindings.

##Summary

I have now my clone view-viewmodel client-side framework, that shows two views with data and can route between them. My clone fulfills its *raison d'être*, but it lacks a lot of other things such as, proper error handling, configuration, caching, and so on. I have tested the code to work in Chrome browser. To run the application you need to access it via a web-server because Chrome does not allow JavaScript access for local file resources.