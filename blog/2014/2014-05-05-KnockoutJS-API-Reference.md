#KnockoutJS API Reference

2014-05-05

<!--- tags: javascript -->

[KnockoutJS](http://knockoutjs.com/) is data-binding Javascript library with nice documentation, but it lacks a full API reference. To get started, I dumped the main object properties and methods of **ko** object, looked in the code to see what they do and commented below some of them:

* applyBindingAccessorsToNode: function (node, bindings, viewModelOrBindingContext) - does not interpret data-bind attributes, not recursive, bindings is an object with each property being a binding name and value on object with values needed for the binding
* applyBindings: function (viewModelOrBindingContext, rootNode) - interprets data-bind attributes, recursive
* applyBindingsToDescendants: function (viewModelOrBindingContext, rootNode)
* applyBindingsToNode: function (node, bindings, viewModelOrBindingContext) - deprecated, use * applyBindingAccessorsToNode
* bindingContext: function (dataItemOrAccessor, parentContext, dataItemAlias, extendCallback)
* createChildContext: function (dataItemOrAccessor, dataItemAlias, extendCallback) - create a new child context usually from dataItemOrAccessor = bindingContext.$rawData
	* extend: function (properties) - extend current context with new data
	* $data: Object - viewmodel in current context (unwrapped viewmodel - note unwrap only works on top level)
	* $parent: Object - the parent $data (if any)
	* $parentContext: Object - the parent bindingContext (if any)
	* $parents: Array - 0: parent context, 1: grandparent context, ...
	* $rawData: Object - same as $data but without any unwrap on top level, for use with extend
	* $root: Object - top level viewmodel (same be same as $data) if no parents
* bindingHandlers: Object - custom handlers can be added
	* attr: Object
		* update: function (element, valueAccessor, allBindings)
	* checked: Object
		* after: Array[2] 0: "value" 1: "attr"
		* init: function (element, valueAccessor, allBindings)
	* checkedValue: Object
		* update: function (element, valueAccessor, allBindings)
	* click: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* css: Object
		* update: function (element, valueAccessor)
	* disable: Object
		* update: function (element, valueAccessor)
	* enable: Object
		* update: function (element, valueAccessor)
	* event: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* foreach: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
		* makeTemplateValueAccessor: function (valueAccessor)
		* update: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* hasFocus: Object
		* init: function (element, valueAccessor, allBindings)
		* update: function (element, valueAccessor)
	* hasfocus: Object - (deprecated, use hasFocus)
		* init: function (element, valueAccessor, allBindings)
		* update: function (element, valueAccessor)
	* html: Object
		* init: function ()
		* update: function (element, valueAccessor)
	* if: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* ifnot: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* options: Object
		* init: function (element)
		* optionValueDomDataKey: string
		* update: function (element, valueAccessor, allBindings)
	* selectedOptions: Object
		* after: Array[2] 0: "options" 1: "foreach"
		* init: function (element, valueAccessor, allBindings)
		* update: function (element, valueAccessor)
	* style: Object
		* update: function (element, valueAccessor)
	* submit: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* template: Object
		* init: function (element, valueAccessor)
		* update: function (element, valueAccessor, allBindings, viewModel, bindingContext)
	* text: Object
		* init: function ()
		* update: function (element, valueAccessor)
	* uniqueName: Object
		* currentIndex: integer
		* init: function (element, valueAccessor)
	* value: Object
		* after: Array[2] 0: "options" 1: "foreach"
		* init: function (element, valueAccessor, allBindings)
		* update: function (element, valueAccessor, allBindings)
	* visible: Object
		* update: function (element, valueAccessor)
	* with: Object
		* init: function (element, valueAccessor, allBindings, viewModel, bindingContext)
* bindingProvider: function () - can be customized or replaced
	* instance: ko.bindingProvider
		* bindingCache: Object
		* getBindingAccessors: function (node, bindingContext)
		* getBindings: function (node, bindingContext)
		* getBindingsString: function (node, bindingContext)
		* nodeHasBindings: function (node)
		* parseBindingsString: function (bindingsString, bindingContext, node, options)
* getBindingAccessors: function (node, bindingContext) - get bindings applied to node (see bindingProvider)
* getBindings: function (node, bindingContext) - deprecated, use getBindingAccessors
* getBindingsString: function (node, bindingContext) - internal use only
* nodeHasBindings: function (node) - true if node has bindings
* parseBindingsString: function (bindingsString, bindingContext, node, options) - internal use only
* cleanNode: function (node) - internal use only, clean up ko internal data related to the node
* computed: function (evaluatorFunctionOrOptions, evaluatorFunctionTarget, options)
	* fn: Function
		* equalityComparer: function valuesArePrimitiveAndEqual (a, b)
* computedContext: Object - for use within ko.computed
	* begin: function begin(options)
	* end: function end()
	* getDependenciesCount: function () - number of detected observable dependencies
	* ignore: function (callback, callbackTarget, callbackArgs)
	* isInitial: function () - true if first evaluation
	* registerDependency: function (subscribable)
* contextFor: function (node) - binding context of node
* dataFor: function (node) - binding context $data of node
* dependencyDetection: Object - internal use
	* begin: function begin(options)
	* end: function end()
	* getDependenciesCount: function ()
	* ignore: function (callback, callbackTarget, callbackArgs)
	* isInitial: function ()
	* registerDependency: function (subscribable)
* dependentObservable: function (evaluatorFunctionOrOptions, evaluatorFunctionTarget, options)
* exportProperty: function (owner, publicName, object) - owner[publicName] = object
* exportSymbol: function (koPath, object) - inner usage
* expressionRewriting: Object - internal use
	* bindingRewriteValidators: Array[0]
	* insertPropertyAccessorsIntoJson: function preProcessBindings (bindingsStringOrKeyValueArray, bindingOptions)
	* keyValueArrayContainsKey: function (keyValueArray, key)
	* parseObjectLiteral: function parseObjectLiteral (objectLiteralString)
	* preProcessBindings: function preProcessBindings (bindingsStringOrKeyValueArray, bindingOptions)
	* twoWayBindings: Object
	* writeValueToProperty: function (property, allBindings, key, value, checkIfDifferent)
* extenders: Object - return a modified observable, custom ones can be added
	* notify: function (target, notifyWhen)
	* rateLimit: function (target, options)
	* throttle: function (target, timeout)
	* trackArrayChanges: function (target)
* getBindingHandler: function (bindingKey)
* hasPrototype: function (instance, prototype) - recursive lookup whether instance has a given prototype
* isComputed: function (instance)
* isObservable: function (instance)
* isSubscribable: function (instance)
* isWriteableObservable: function (instance)
* jqueryTmplTemplateEngine: function () - see setTemplateEngine
* jsonExpressionRewriting: Object - same as expressionRewriting
	* bindingRewriteValidators: Array[0]
	* insertPropertyAccessorsIntoJson: function preProcessBindings (bindingsStringOrKeyValueArray, bindingOptions)
	* keyValueArrayContainsKey: function (keyValueArray, key)
	* parseObjectLiteral: function parseObjectLiteral (objectLiteralString)
	* preProcessBindings: function preProcessBindings (bindingsStringOrKeyValueArray, bindingOptions)
	* twoWayBindings: Object
	* writeValueToProperty: function (property, allBindings, key, value, checkIfDifferent)
* memoization: Object - internal use
	* memoize: function (callback)
	* parseMemoText: function (memoText)
	* unmemoize: function (memoId, callbackParams)
	* unmemoizeDomNodeAndDescendants: function (domNode, extraCallbackParamsArray)
* nativeTemplateEngine: function () - see setTemplateEngine
* observable: function (initialValue)
	* fn: Function
		* equalityComparer: function valuesArePrimitiveAndEqual (a, b)
* observableArray: function (initialValues)
	* fn: Object[0]
		* destroy: function (valueOrPredicate)
		* destroyAll: function (arrayOfValues)
		* indexOf: function (item)
		* pop: function ()
		* push: function ()
		* remove: function (valueOrPredicate)
		* removeAll: function (arrayOfValues)
		* replace: function (oldItem, newItem)
		* reverse: function ()
		* shift: function ()
		* slice: function ()
		* sort: function ()
		* splice: function ()
		* unshift: function ()
* removeNode: function (node) - removes a DOM node from its parent
* renderTemplate: function (template, dataOrBindingContext, options, targetNodeOrNodeArray, renderMode)
* renderTemplateForEach: function (template, arrayOrObservableArray, options, targetNode, parentBindingContext)
* selectExtensions: Object - selectExtensions provides SELECTs/OPTIONs to have arbitrary object values (not only 'string')
	* readValue: function (element)
	* writeValue: function (element, value, allowUnset)
* setTemplateEngine: function (templateEngine) - template engine to use
* storedBindingContextForNode: function (node, bindingContext) - internal use, use contextFor
* subscribable: function ()
	* fn: Function
		* extend: function applyExtenders (requestedExtenders)
		* getSubscriptionsCount: function ()
		* hasSubscriptionsForEvent: function (event)
		* isDifferent: function (oldValue, newValue)
		* limit: function (limitFunction)
		* notifySubscribers: function (valueToNotify, event)
		* subscribe: function (callback, callbackTarget, event)
* subscription: function (target, callback, disposeCallback)
* templateEngine: function () - base class for templateEngines
* templateRewriting: Object - helper class for templateEngines
	* applyMemoizedBindingsToNextSibling: function (bindings, nodeName)
	* ensureTemplateIsRewritten: function (template, templateEngine, templateDocument)
	* memoizeBindingAttributeSyntax: function (htmlString, templateEngine)
* templateSources: Object - helper class for templateEngines, a read / write way of accessing a template, example:  https://github.com/rniemeyer/SamplePresentation/blob/master/js/stringTemplateEngine.js
	* anonymousTemplate: function (element) - uses ko.utils.domData to read / write text *associated* with the DOM element, without reading/writing the actual element text content (it will be overwritten with the rendered template output)
	* domElement: function (element) - reads / writes the text content of an arbitrary DOM element
* toJS: function (rootObject) - to javascript objects
* toJSON: function (rootObject, replacer, space) - utils.stringifyJson( toJS(rootObject))
* unwrap: function (value) - same as utils.unwrapObservable
* utils: Object
	* addOrRemoveItem: function (array, value, included) - adds value if included=true (and not alerady in array), otherwise removes it (if present)
	* anyDomNodeIsAttachedToDocument: function (nodes)
	* arrayFilter: function (array, predicate) - return a new array with only element for which predicate(item, index) it true
	* arrayFirst: function (array, predicate, predicateOwner) - return first item of array for which predicate(item, index) === true, predicateOwner set the this pointer for predicate
	* arrayForEach: function (array, action) - applied action(item, index) to every element of array, returns nothing
	* arrayGetDistinctValues: function (array) - return unique values of the array using arrayIndexOf to find them preservign order, in O(N^2) time
	* arrayIndexOf: function (array, item) - linear search in array for item using ===, in O(N) time
	* arrayMap: function (array, mapping) - return a new array, applying mapping(item, index) to array
	* arrayPushAll: function (array, valuesToPush) - appends valuesToPush to array
	* arrayRemoveItem: function (array, itemToRemove) - removes itemToRemove if found via arrayIndexOf
	* canSetPrototype: true - if __proto__ can be set, internal use
	* cloneNodes: function (nodesArray, shouldCleanNodes) - clone nodes in a new arry, calling ko.cleanNode on each if shouldCleanNodes
	* compareArrays: function compareArrays (oldArray, newArray, options)
	* domData: Object
		* clear: function (node)
		* get: function (node, key)
		* nextKey: function ()
		* set: function (node, key, value)
	* domNodeDisposal: Object
		* addDisposeCallback: function (node, callback)
		* cleanExternalData: function (node)
		* cleanNode: function (node)
		* removeDisposeCallback: function (node, callback)
		* removeNode: function (node)
	* domNodeIsAttachedToDocument: function (node)
	* domNodeIsContainedBy: function (node, containedByNode)
	* emptyDomNode: function (domNode) - removed all children from domNode
	* ensureSelectElementIsRenderedCorrectly: function (selectElement) - IE specific handling
	* extend: function extend(target, source) - extend target with source properties (replacing any existing)
	* fieldsIncludedWithJsonPost: Array[2]
	* findMovesInArrayComparison: function (left, right, limitFailedCompares)
	* fixUpContinuousNodeArray: function (continuousNodeArray, parentNode)
	* forceRefresh: function (node) - special IE 6/7 refresh, for other browsers this does nothing
	* getFormFields: function (form, fieldName)
	* ieVersion: undefined - set if using IE
	* isIe6: false
	* isIe7: false
	* makeArray: function (arrayLikeObject) - arrayLikeObject must have length and [index], return an array with all elements
	* moveCleanedNodesToContainerElement: function (nodes)
	* objectForEach: function objectForEach(obj, action) - applies action(key, value) to every property of obj
	* objectMap: function (source, mapping) - return a new object where object[prop] = mapping(source[prop], prop, source)
	* parseHtmlFragment: function (html)
	* parseJson: function (jsonString)
	* peekObservable: function (value)
	* postJson: function (urlOrForm, data, options)
	* range: function (min, max) - return an array with [mix, ... ,max]
	* registerEventHandler: function (element, eventType, handler)
	* replaceDomNodes: function (nodeToReplaceOrNodeArray, newNodesArray)
	* setDomNodeChildren: function (domNode, childNodes)
	* setDomNodeChildrenFromArrayMapping: function (domNode, array, mapping, options, callbackAfterAddingNodes)
	* setElementName: function (element, name) - set dom element name (with IE workaround)
	* setHtml: function (node, html)
	* setOptionNodeSelectionState: function (optionNode, isSelected)
	* setPrototypeOf: function setPrototypeOf(obj, proto) - obj.__proto__ = proto, returns obj
	* setPrototypeOfOrExtend: function setPrototypeOf(obj, proto) - canSetPrototype ? setPrototypeOf : extend
	* setTextContent: function (element, textContent) - sets dom element innerText
	* stringStartsWith: function (string, startsWith)
	* stringTokenize: function (string, delimiter) - return an array with non-empty stringTrim(part)
	* stringTrim: function (string)
	* stringifyJson: function (data, replacer, space) - use ko.toJSON
	* tagNameLower: function (element) - tagName.toLowerCase()
	* toggleDomNodeCssClass: function (node, classNames, shouldHaveClass)
	* triggerEvent: function (element, eventType)
	* unwrapObservable: function (value) - raw value, unwraps as needed an observable (nested observables, if any, remain as they are)
* version: "3.1.0"
* virtualElements: Object
	* allowedBindings: Object
	* foreach: true
	* if: true
	* ifnot: true
	* template: true
	* text: true
	* with: true
* childNodes: function (node)
* emptyNode: function (node)
* firstChild: function (node)
* hasBindingValue: function isStartComment(node)
* insertAfter: function (containerNode, nodeToInsert, insertAfterNode)
* nextSibling: function (node)
* normaliseVirtualElementDomStructure: function (elementVerified)
* prepend: function (containerNode, nodeToPrepend)
* setDomNodeChildren: function (node, childNodes)
* virtualNodeBindingValue: function (node)
 
This gives an idea of what is there in total. Most of functions / methods and their parameters are undocumented in Knockout web site and in source code. In order to use Knockout for more than simple samples you need to figure out what some of these methods do.

In a nutshell, to use Knockout:

* Decorate DOM nodes with bindings (bindingHandlers), either declaratively using data-bind attribute in HTML, or in code via `ko.applyBindingAccessorsToNode`.
* During decoration with bindings you refer to data from `bindingContext`, that contains the unwrapped `viewModel` data.
* Create a `viewModel` (vm) object that contains the data you need to refer from the bindings via `bindingContex`. The `viewModel` data can be plain data, plain functions, or `ko.observable`, or `ko.observableArray`, or `ko.computed`. The last three work on both ways, and fire events (when changed, etc).
* `viewModel` is set as binding context is set in code via `ko.applyBindings`, or `ko.applyBindingAccessorsToNode`, or `ko.applyBindingsToDescendants`.
* A binding can control DOM descendants binding on its own, by returning `{ controlsDescendantBindings: true }` from its `init()` function.
* A binding that controls DOM descendants binding on its own can extend its `bindingContext` (using `bindingContext.extend`) and apply the extended one via `ko.applyBindingAccessorsToNode`, or it can create a new child binding context, using bindingContext.createChildContext and apply it via `ko.applyBindingsToDescendants`.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-05-15-Disable-Send-Error-Reports-to-Canonical-in-Lubuntu.md'>Disable Send Error Reports to Canonical in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2014/2014-05-01-Disable-HTML5-Video-in-Chromium.md'>Disable HTML5 Video in Chromium</a></ins>
