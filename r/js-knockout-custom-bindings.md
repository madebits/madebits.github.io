2014

#Custom [KnockoutJS](http://knockoutjs.com/) Bindings

<!--- tags: javascript -->

Require jQuery.

#1. vkGrid

A [Bootstrap](http://getbootstrap.com/) enabled paged grid. The grid structure can be described either in JavaScript (via the model), or in XML. All elements are decorated with classes to enable further external CSS styling.

```html
<div id="data" data-bind="vkGrid: gridModel">
  <script src="grid/data.xml" type="text/xml"></script>
</div>
```

JS KO model part is a bit evolved, but these are all supported options, and most of them have defaults. You can use either observables or plain objects in the grid model. If you use observables and they change, the whole grid is re-created.

```javascript
var model = {
 gridModel:
 {
  name: 'g1',
  columns: [ 
     { name: 'Nr', databind: 'vkGridRowIndex', cssclasshead: 'cih', cssclassbody: 'ci' }, 
     { name: 'c1', databind: 'key1', cssclasshead: 'c1' },
     { name: '<span style="color: red;">c2</span>', databind: 'key2', cssclasshead: 'c2' },
     { name: 'c3', databind: 'key3', cssclasshead: 'c3' },
     { name: 'c4', cssclasshead: 'c4', custombind: '<input type=checkbox data-bind="checked: $data.key4">' }
    ],
  pagerTop: true,
  pagerButtons: ko.observable(10),
  pageInfo: ko.observable({ total: 21, current: 3, pageSize: 5 }),
  onRowSelect : function(rowData, event) { 
   alert("ROW: " + ko.toJSON(rowData) + "\nEVENT: " + event.target);
   return true; 
  },
  onPageSelect: function(pageInfo, applyNewDataCallback, existingData) {
   // existingData.data, existingData.previousPage, existingData.token
   var data = [];
   for(var i = 0; i < pageInfo.pageSize; i++) {
    data.push({
     key1: pageInfo.current + '.1' + i, 
     keyOther: pageInfo.current + '.2' + i, 
     key3: '<a href="http://bing.com" target="_blank">Bing.com</a>',
     key4: ko.observable(i % 2 == 0) });
   }
   applyNewDataCallback(data.map(function(dataRow){ dataRow.key2 = dataRow.keyOther; return dataRow; }));
  },
  cssclass: { div: '', table: '', ul: '' },
  token: { } // any custom data set here, you receive in onPageSelect existingData.token
 }
};
```

###Columns

Grid model needs to contain the grid columns definitions as array. Each column has a name (caption) (bound as html). The column also defines how to bind the data. There are two ways to bind data:

* databind - set to the data property name to use. This uses html bind and will work for most textual or read-only HTML data. The special vkGridRowIndex name bounds to the row index.
* custombind - you can use any valid knockout (html) here. To refer to data item context use $data.

Value used in databind or in custombind bindings, must by a property of data array objects. For example, if the original data does not contain a key named key2, you can map it to one or more existing fields of data and add it, as done above with keyOther.

An optional class for head and body table cells can also be set. Normally you style a column using the its css class. I used in-line HTML for c2 in example just to show that HTML can be used as column name.

The above code shows how to define columns in Javascript as part of the model. This can be useful when you create columns dynamically. Most of the time, you want to define columns and their binding declaratively in HTML. To do so, do not set columns in Javascript, but instead define same content in HTML within the grid DIV as shown:

```html
<div data-bind="vkGrid: gridModel">
 <script type="text/xml">
  <columns>
   <col>
    <name>#</name>
    <cssclasshead>cih text-muted text-right</cssclasshead>
    <cssclassbody>ci text-muted text-right</cssclassbody>
    <databind>vkGridRowIndex</databind>
    <custombind></custombind>
   </col>
   <col>
    <name>c1</name>
    <cssclasshead>c1</cssclasshead>
    <cssclassbody></cssclassbody>
    <databind>key1</databind>
    <custombind></custombind>
   </col>
   <col>
    <name><![CDATA[<span style="color: red;">c2</span>]]></name>
    <cssclasshead>c2</cssclasshead>
    <cssclassbody></cssclassbody>
    <databind>key2</databind>
    <custombind></custombind>
   </col>
   <col>
    <name>c3</name>
    <cssclasshead>c3</cssclasshead>
    <cssclassbody></cssclassbody>
    <databind>key3</databind>
    <custombind></custombind>
   </col>
   <col>
    <name>c4</name>
    <cssclasshead>c4</cssclasshead>
    <cssclassbody></cssclassbody>
    <databind>key3</databind>
    <custombind><![CDATA[<input type=checkbox data-bind="checked: $data.key4">]]></custombind>
   </col>
  </columns>
 </script>
</div>
```
If you do not like inline XML, then define it in a separate file in server, e.g, gridcols.xml and then refer to it as shown next:

```html
<div data-bind="vkGrid: gridModel">
 <script src="gridcols.xml" type="text/xml"></script>
</div>
```

Here, `gridcols.xml` has same XML content as shown before within the SCRIPT tag.

###Paging

To specify current initial grid page and page information use `pageInfo`. It defines total items, page items size and start page (current). If `pageInfo` is an `ko.observable` it will be updated when user changes the pages (see also onPageSelect). If you do not specify a `pageInfo`, the default values are { total: 1, current: 1, pageSize: 25 }. Optionally, pass `refresh: true` to force grid to refresh.

###Data Input

In `vkGrid`, you do not specify the data directly, rather you specify a `onPageSelect` callback that is called when the page changes, either the very first time when the grid is shown, or when the user clicks on a new page. In `onPageSelect`, you get a `pageInfo` that contains the current page. I am using that information in the example to generate some dynamic sample data. The second parameter is a `applyNewDataCallback`. Once you have your data, you call `applyNewDataCallback` and pass the data back to the grid. This is useful in case you do AJAX requests. The third parameter contains the `existingData` before the page change (a shallow clone of the input data array), in case you need to process and store their changes. Using `onPageSelect` is preferred to using subscribe on `pageInfo`.

###Other Settings

You can give a name to the grid. It is used with [store.js](https://github.com/marcuswestin/store.js/) to store column head size data locally. If you have more than one grid in a page, it is good idea to given each one a different name.

`pagerTop` decides where the pager is located relative to the table. `pagerButtons` is the number of pager buttons.

If a table row is clicked you can handle it if needed with `onRowSelect`.

Have a look at the generated HTML for the CSS classes used.


#2. vkCompose

Page compose custom binding using JQuery, similar to AngularJS's ng-include, but a bit more evolved. In simplest form `vkCompose` is used as follows:

```html
<div id="content" data-bind="vkCompose: 'path/file.html'"></div>
```

URLs must be from the same host. The DIV will be filled with the content from specified the URL, applying any bindings. Empty or null URL results in empty DIV.

All current ko scope model bindings can be used in included HTML files. `vkCompose` can be used recursively, that is, `path/file.html` can contain itself other vkCompose bindings and so on (loops are not detected!). 

More advanced usage supports passing more parameters via an object:

```html
<div id="content" data-bind="vkCompose: { url: currentPage, onLoad: onPageLoad }"></div>
```

Supported parameters to use:

* url - 'url' or ko.observable('url')
* urlData - {} get data to pass to url (or ko.observable({})))
* cache - use ajax cache
* onLoad: function(data){} - called once loaded passing a thin copy of object properties, can be used to post-process the loaded HTML
* model: {} - if set, a new ko child scope with the passed object is created
* extendedModel: {} - if set, the ko scope is extended with the passed object; can be used with model: {} or alone