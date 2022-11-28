package cheerio.lib.cheerio;

@:jsRequire("cheerio/lib/cheerio", "Cheerio") extern class Cheerio<T> {
	/**
		Instance of cheerio. Methods are specified in the modules. Usage of this
		constructor is not recommended. Please use `$.load` instead.
	**/
	function new(elements:Null<js.lib.ArrayLike<T>>, root:Null<Cheerio<js.html.Document>>, options:Dynamic);
	var length : Float;
	var options : Dynamic;
	/**
		The root of the document. Can be set by using the `root` argument of the constructor.
	**/
	var _root : Null<Cheerio<js.html.Document>>;
	var prevObject : Null<Cheerio<Dynamic>>;
	/**
		Make a cheerio object.
	**/
	function _make<T>(dom:ts.AnyOf3<String, js.lib.ArrayLike<T>, T>, ?context:Dynamic):Cheerio<T>;
	/**
		Parses some content.
	**/
	function _parse(content:Dynamic, options:Dynamic, isDocument:Bool, context:Null<js.html.ParentNode>):js.html.Document;
	/**
		Render an element or a set of elements.
	**/
	function _render(dom:Dynamic):String;
	var cheerio : String;
	dynamic function splice(?start:Float, ?end:Float):Array<Dynamic>;
	/**
		Method for getting attributes. Gets the attribute value for only the first
		element in the matched set.
		
		Method for getting all attributes and their values of the first element in
		the matched set.
		
		Method for setting attributes. Sets the attribute value for only the first
		element in the matched set. If you set an attribute's value to `null`, you
		remove that attribute. You may also pass a `map` and `function`.
		
		Method for setting multiple attributes at once. Sets the attribute value for
		only the first element in the matched set. If you set an attribute's value to
		`null`, you remove that attribute.
	**/
	@:overload(function<T>():Null<haxe.DynamicAccess<String>> { })
	@:overload(function<T>(name:String, ?value:ts.AnyOf2<String, (i:Float, attrib:String) -> Null<String>>):Dynamic { })
	@:overload(function<T>(values:haxe.DynamicAccess<Null<String>>):Dynamic { })
	function attr<T>(name:String):Null<String>;
	/**
		Method for getting and setting properties. Gets the property value for only
		the first element in the matched set.
		
		Get a parsed CSS style object.
		
		Resolve `href` or `src` of supported elements. Requires the `baseURI` option
		to be set, and a global `URL` object to be part of the environment.
		
		Get a property of an element.
		
		Set a property of an element.
	**/
	@:overload(function<T>(name:String):Null<String> { })
	@:overload(function<T>(name:String):Null<cheerio.StyleProp> { })
	@:overload(function<T>(name:String):Null<String> { })
	@:overload(function<T, K>(name:K):Dynamic { })
	@:overload(function<T, K>(name:K, value:ts.AnyOf2<(i:Float, prop:K) -> Null<ts.AnyOf75<String, Float, Bool, js.html.Document, js.html.Node, js.html.DOMElement, js.html.ChildNode, js.html.SlotElement, js.html.Element, js.html.NamedNodeMap, js.html.DOMTokenList, (ev:js.html.Event) -> Dynamic, js.html.ShadowRoot, (init:js.html.ShadowRootInit) -> js.html.ShadowRoot, { /** Returns the first (starting at element) inclusive ancestor that matches selectors, and null otherwise. **/ @:overload(function<K>(selector:K):Null<Dynamic> { }) @:overload(function<E>(selector:String):Null<E> { }) @:selfCall function call<K>(selector:K):Null<Dynamic>; }, (qualifiedName:String) -> Null<String>, (namespace:Null<String>, localName:String) -> Null<String>, () -> Array<String>, (name:String) -> Null<js.html.Attr>, (namespaceURI:String, localName:String) -> Null<js.html.Attr>, () -> js.html.DOMRect, () -> js.html.DOMRectList, (classNames:String) -> js.html.HTMLCollectionOf<js.html.DOMElement>, { @:overload(function<K>(qualifiedName:K):js.html.HTMLCollectionOf<Dynamic> { }) @:overload(function(qualifiedName:String):js.html.HTMLCollectionOf<js.html.DOMElement> { }) @:selfCall function call<K>(qualifiedName:K):js.html.HTMLCollectionOf<Dynamic>; }, { @:overload(function(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.svg.Element> { }) @:overload(function(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.DOMElement> { }) @:selfCall function call(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.Element>; }, (qualifiedName:String) -> Bool, (namespace:Null<String>, localName:String) -> Bool, () -> Bool, (pointerId:Float) -> Bool, (position:js.html.InsertPosition, insertedElement:js.html.DOMElement) -> Null<js.html.DOMElement>, (where:js.html.InsertPosition, html:String) -> Void, (where:js.html.InsertPosition, text:String) -> Void, (selectors:String) -> Bool, () -> Dynamic, (pointerId:Float) -> Void, (qualifiedName:String) -> Void, (namespace:Null<String>, localName:String) -> Void, (attr:js.html.Attr) -> js.html.Attr, () -> js.lib.Promise<ts.Undefined>, (options:js.html.FullscreenOptions) -> js.lib.Promise<ts.Undefined>, () -> Void, { @:overload(function(x:Float, y:Float):Void { }) @:selfCall function call(?options:js.html.ScrollToOptions):Void; }, () -> Void, (arg:ts.AnyOf2<Bool, js.html.ScrollIntoViewOptions>) -> Void, (qualifiedName:String, value:String) -> Void, (namespace:Null<String>, qualifiedName:String, value:String) -> Void, (attr:js.html.Attr) -> Null<js.html.Attr>, (qualifiedName:String) -> Bool, (qualifiedName:String, force:Bool) -> Bool, { /** Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture. **/ @:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void { }) @:selfCall function call<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void; }, { /** Removes the event listener in target's event listener list with the same type, callback, and options. **/ @:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void { }) @:selfCall function call<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void; }, js.html.NodeListOf<js.html.ChildNode>, js.html.INode & js.html.ParentNode, (newChild:Any) -> Any, () -> js.html.Node, (deep:Bool) -> js.html.Node, (other:js.html.Node) -> Float, (other:Null<js.html.Node>) -> Bool, () -> js.html.Node, (options:js.html.GetRootNodeOptions) -> js.html.Node, (newChild:Any, refChild:Null<js.html.Node>) -> Any, (namespace:Null<String>) -> Bool, (otherNode:Null<js.html.Node>) -> Bool, (prefix:Null<String>) -> Null<String>, (namespace:Null<String>) -> Null<String>, (oldChild:Any) -> Any, (newChild:js.html.Node, oldChild:Any) -> Any, (event:js.html.Event) -> Bool, (keyframes:Null<ts.AnyOf2<Array<js.html.Keyframe>, js.html.PropertyIndexedKeyframes>>) -> js.html.Animation, (keyframes:Null<ts.AnyOf2<Array<js.html.Keyframe>, js.html.PropertyIndexedKeyframes>>, options:ts.AnyOf2<Float, js.html.KeyframeAnimationOptions>) -> js.html.Animation, () -> Array<js.html.Animation>, (nodes:haxe.extern.Rest<ts.AnyOf2<String, js.html.Node>>) -> Void, js.html.HTMLCollection, { /** Returns the first element that is a descendant of node that matches selectors. **/ @:overload(function<K>(selectors:K):Null<Dynamic> { }) @:overload(function<E>(selectors:String):Null<E> { }) @:selfCall function call<K>(selectors:K):Null<Dynamic>; }, { /** Returns all element descendants of node that match selectors. **/ @:overload(function<K>(selectors:K):js.html.NodeListOf<Dynamic> { }) @:overload(function<E>(selectors:String):js.html.NodeListOf<E> { }) @:selfCall function call<K>(selectors:K):js.html.NodeListOf<Dynamic>; }>>, Dynamic>):Dynamic { })
	@:overload(function<T>(name:haxe.DynamicAccess<Null<ts.AnyOf75<String, Float, Bool, js.html.Document, js.html.Node, js.html.DOMElement, js.html.ChildNode, js.html.SlotElement, js.html.Element, js.html.NamedNodeMap, js.html.DOMTokenList, (ev:js.html.Event) -> Dynamic, js.html.ShadowRoot, (init:js.html.ShadowRootInit) -> js.html.ShadowRoot, { /** Returns the first (starting at element) inclusive ancestor that matches selectors, and null otherwise. **/ @:overload(function<K>(selector:K):Null<Dynamic> { }) @:overload(function<E>(selector:String):Null<E> { }) @:selfCall function call<K>(selector:K):Null<Dynamic>; }, (qualifiedName:String) -> Null<String>, (namespace:Null<String>, localName:String) -> Null<String>, () -> Array<String>, (name:String) -> Null<js.html.Attr>, (namespaceURI:String, localName:String) -> Null<js.html.Attr>, () -> js.html.DOMRect, () -> js.html.DOMRectList, (classNames:String) -> js.html.HTMLCollectionOf<js.html.DOMElement>, { @:overload(function<K>(qualifiedName:K):js.html.HTMLCollectionOf<Dynamic> { }) @:overload(function(qualifiedName:String):js.html.HTMLCollectionOf<js.html.DOMElement> { }) @:selfCall function call<K>(qualifiedName:K):js.html.HTMLCollectionOf<Dynamic>; }, { @:overload(function(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.svg.Element> { }) @:overload(function(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.DOMElement> { }) @:selfCall function call(namespaceURI:String, localName:String):js.html.HTMLCollectionOf<js.html.Element>; }, (qualifiedName:String) -> Bool, (namespace:Null<String>, localName:String) -> Bool, () -> Bool, (pointerId:Float) -> Bool, (position:js.html.InsertPosition, insertedElement:js.html.DOMElement) -> Null<js.html.DOMElement>, (where:js.html.InsertPosition, html:String) -> Void, (where:js.html.InsertPosition, text:String) -> Void, (selectors:String) -> Bool, () -> Dynamic, (pointerId:Float) -> Void, (qualifiedName:String) -> Void, (namespace:Null<String>, localName:String) -> Void, (attr:js.html.Attr) -> js.html.Attr, () -> js.lib.Promise<ts.Undefined>, (options:js.html.FullscreenOptions) -> js.lib.Promise<ts.Undefined>, () -> Void, { @:overload(function(x:Float, y:Float):Void { }) @:selfCall function call(?options:js.html.ScrollToOptions):Void; }, () -> Void, (arg:ts.AnyOf2<Bool, js.html.ScrollIntoViewOptions>) -> Void, (qualifiedName:String, value:String) -> Void, (namespace:Null<String>, qualifiedName:String, value:String) -> Void, (attr:js.html.Attr) -> Null<js.html.Attr>, (qualifiedName:String) -> Bool, (qualifiedName:String, force:Bool) -> Bool, { /** Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture. **/ @:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void { }) @:selfCall function call<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void; }, { /** Removes the event listener in target's event listener list with the same type, callback, and options. **/ @:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void { }) @:selfCall function call<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void; }, js.html.NodeListOf<js.html.ChildNode>, js.html.INode & js.html.ParentNode, (newChild:Any) -> Any, () -> js.html.Node, (deep:Bool) -> js.html.Node, (other:js.html.Node) -> Float, (other:Null<js.html.Node>) -> Bool, () -> js.html.Node, (options:js.html.GetRootNodeOptions) -> js.html.Node, (newChild:Any, refChild:Null<js.html.Node>) -> Any, (namespace:Null<String>) -> Bool, (otherNode:Null<js.html.Node>) -> Bool, (prefix:Null<String>) -> Null<String>, (namespace:Null<String>) -> Null<String>, (oldChild:Any) -> Any, (newChild:js.html.Node, oldChild:Any) -> Any, (event:js.html.Event) -> Bool, (keyframes:Null<ts.AnyOf2<Array<js.html.Keyframe>, js.html.PropertyIndexedKeyframes>>) -> js.html.Animation, (keyframes:Null<ts.AnyOf2<Array<js.html.Keyframe>, js.html.PropertyIndexedKeyframes>>, options:ts.AnyOf2<Float, js.html.KeyframeAnimationOptions>) -> js.html.Animation, () -> Array<js.html.Animation>, (nodes:haxe.extern.Rest<ts.AnyOf2<String, js.html.Node>>) -> Void, js.html.HTMLCollection, { /** Returns the first element that is a descendant of node that matches selectors. **/ @:overload(function<K>(selectors:K):Null<Dynamic> { }) @:overload(function<E>(selectors:String):Null<E> { }) @:selfCall function call<K>(selectors:K):Null<Dynamic>; }, { /** Returns all element descendants of node that match selectors. **/ @:overload(function<K>(selectors:K):js.html.NodeListOf<Dynamic> { }) @:overload(function<E>(selectors:String):js.html.NodeListOf<E> { }) @:selfCall function call<K>(selectors:K):js.html.NodeListOf<Dynamic>; }>>>):Dynamic { })
	@:overload(function<T>(name:String, value:Null<ts.AnyOf3<String, Bool, (i:Float, prop:String) -> ts.AnyOf2<String, Bool>>>):Dynamic { })
	@:overload(function<T>(name:String):String { })
	function prop<T>(name:String):Dynamic;
	/**
		Method for getting data attributes, for only the first element in the matched set.
		
		Method for getting all of an element's data attributes, for only the first
		element in the matched set.
		
		Method for setting data attributes, for only the first element in the matched set.
		
		Method for setting multiple data attributes at once, for only the first
		element in the matched set.
	**/
	@:overload(function<T>():haxe.DynamicAccess<Any> { })
	@:overload(function<T>(name:String, value:Any):Dynamic { })
	@:overload(function<T>(values:haxe.DynamicAccess<Any>):Dynamic { })
	function data<T>(name:String):Any;
	/**
		Method for getting the value of input, select, and textarea. Note: Support
		for `map`, and `function` has not been added yet.
		
		Method for setting the value of input, select, and textarea. Note: Support
		for `map`, and `function` has not been added yet.
	**/
	@:overload(function<T>(value:ts.AnyOf2<String, Array<String>>):Dynamic { })
	function val<T>():Null<ts.AnyOf2<String, Array<String>>>;
	/**
		Method for removing attributes by `name`.
	**/
	function removeAttr<T>(name:String):Dynamic;
	/**
		Check to see if _any_ of the matched elements have the given `className`.
	**/
	function hasClass<T>(className:String):Bool;
	/**
		Adds class(es) to all of the matched elements. Also accepts a `function`.
	**/
	function addClass<T, R>(?value:ts.AnyOf2<String, (i:Float, className:String) -> Null<String>>):R;
	/**
		Removes one or more space-separated classes from the selected elements. If no
		`className` is defined, all classes will be removed. Also accepts a `function`.
	**/
	function removeClass<T, R>(?name:ts.AnyOf2<String, (i:Float, className:String) -> Null<String>>):R;
	/**
		Add or remove class(es) from the matched elements, depending on either the
		class's presence or the value of the switch argument. Also accepts a `function`.
	**/
	function toggleClass<T, R>(?value:ts.AnyOf3<String, (i:Float, className:String) -> String, (i:Float, className:String, stateVal:Bool) -> String>, ?stateVal:Bool):R;
	/**
		Get the descendants of each element in the current set of matched elements,
		filtered by a selector, jQuery object, or element.
	**/
	function find<T>(?selectorOrHaystack:Dynamic):Dynamic;
	/**
		For each element in the set, get the first element that matches the selector
		by testing the element itself and traversing up through its ancestors in the DOM tree.
	**/
	function closest<T>(?selector:Dynamic):Dynamic;
	/**
		Gets the children of each element in the set of matched elements, including
		text and comment nodes.
	**/
	function contents<T>():Dynamic;
	/**
		Iterates over a cheerio object, executing a function for each matched
		element. When the callback is fired, the function is fired in the context of
		the DOM element, so `this` refers to the current element, which is equivalent
		to the function parameter `element`. To break out of the `each` loop early,
		return with `false`.
	**/
	function each<T>(fn:(i:Float, el:T) -> ts.AnyOf2<Bool, ts.Undefined>):Dynamic;
	/**
		Pass each element in the current matched set through a function, producing a
		new Cheerio object containing the return values. The function can return an
		individual data item or an array of data items to be inserted into the
		resulting set. If an array is returned, the elements inside the array are
		inserted into the set. If the function returns null or undefined, no element
		will be inserted.
	**/
	function map<T, M>(fn:(i:Float, el:T) -> Null<ts.AnyOf2<Array<M>, M>>):Dynamic;
	/**
		Iterates over a cheerio object, reducing the set of selector elements to
		those that match the selector or pass the function's test.
		
		This is the definition for using type guards; have a look below for other
		ways to invoke this method. The function is executed in the context of the
		selected element, so `this` refers to the current element.
		
		Iterates over a cheerio object, reducing the set of selector elements to
		those that match the selector or pass the function's test.
		
		- When a Cheerio selection is specified, return only the elements contained in
		   that selection.
		- When an element is specified, return only that element (if it is contained in
		   the original selection).
		- If using the function method, the function is executed in the context of the
		   selected element, so `this` refers to the current element.
	**/
	@:overload(function<T, S>(match:S):Dynamic { })
	function filter<T, S>(match:(index:Float, value:T) -> Bool):Dynamic;
	function filterArray<T>(nodes:Array<T>, match:Dynamic, ?xmlMode:Bool, ?root:domhandler.Document):ts.AnyOf2<Array<T>, Array<domhandler.Element>>;
	/**
		Checks the current list of elements and returns `true` if _any_ of the
		elements match the selector. If using an element or Cheerio selection,
		returns `true` if _any_ of the elements match. If using a predicate function,
		the function is executed in the context of the selected element, so `this`
		refers to the current element.
	**/
	function is<T>(?selector:Dynamic):Bool;
	/**
		Remove elements from the set of matched elements. Given a Cheerio object that
		represents a set of DOM elements, the `.not()` method constructs a new
		Cheerio object from a subset of the matching elements. The supplied selector
		is tested against each element; the elements that don't match the selector
		will be included in the result.
		
		The `.not()` method can take a function as its argument in the same way that
		`.filter()` does. Elements for which the function returns `true` are excluded
		from the filtered set; all other elements are included.
	**/
	function not<T>(match:Dynamic):Dynamic;
	/**
		Filters the set of matched elements to only those which have the given DOM
		element as a descendant or which have a descendant that matches the given
		selector. Equivalent to `.filter(':has(selector)')`.
	**/
	function has(selectorOrHaystack:Dynamic):Dynamic;
	/**
		Will select the first element of a cheerio object.
	**/
	function first<T>():Dynamic;
	/**
		Will select the last element of a cheerio object.
	**/
	function last<T>():Dynamic;
	/**
		Reduce the set of matched elements to the one at the specified index. Use
		`.eq(-i)` to count backwards from the last selected element.
	**/
	function eq<T>(i:Float):Dynamic;
	/**
		Retrieve one of the elements matched by the Cheerio object, at the `i`th position.
		
		Retrieve all elements matched by the Cheerio object, as an array.
	**/
	@:overload(function<T>():Array<T> { })
	function get<T>(i:Float):Null<T>;
	/**
		Retrieve all the DOM elements contained in the jQuery set as an array.
	**/
	function toArray<T>():Array<T>;
	/**
		Search for a given element from among the matched elements.
	**/
	function index<T>(?selectorOrNeedle:Dynamic):Float;
	/**
		Gets the elements matching the specified range (0-based position).
	**/
	function slice<T>(?start:Float, ?end:Float):Dynamic;
	/**
		End the most recent filtering operation in the current chain and return the
		set of matched elements to its previous state.
	**/
	function end<T>():Dynamic;
	/**
		Add elements to the set of matched elements.
	**/
	function add<S, T>(other:Dynamic, ?context:Dynamic):Dynamic;
	/**
		Add the previous set of elements on the stack to the current set, optionally
		filtered by a selector.
	**/
	function addBack<T>(?selector:String):Dynamic;
	/**
		Get the parent of each element in the current set of matched elements,
		optionally filtered by a selector.
	**/
	function parent<T>(?selector:Dynamic):Dynamic;
	/**
		Get a set of parents filtered by `selector` of each element in the current
		set of match elements.
	**/
	function parents<T>(?selector:Dynamic):Dynamic;
	/**
		Get the ancestors of each element in the current set of matched elements, up
		to but not including the element matched by the selector, DOM node, or cheerio object.
	**/
	function parentsUntil<T>(?selector:Dynamic, ?filterSelector:Dynamic):Dynamic;
	/**
		Gets the next sibling of the first selected element, optionally filtered by a selector.
	**/
	function next<T>(?selector:Dynamic):Dynamic;
	/**
		Gets all the following siblings of the first selected element, optionally
		filtered by a selector.
	**/
	function nextAll<T>(?selector:Dynamic):Dynamic;
	/**
		Gets all the following siblings up to but not including the element matched
		by the selector, optionally filtered by another selector.
	**/
	function nextUntil<T>(?selector:Dynamic, ?filterSelector:Dynamic):Dynamic;
	/**
		Gets the previous sibling of the first selected element optionally filtered
		by a selector.
	**/
	function prev<T>(?selector:Dynamic):Dynamic;
	/**
		Gets all the preceding siblings of the first selected element, optionally
		filtered by a selector.
	**/
	function prevAll<T>(?selector:Dynamic):Dynamic;
	/**
		Gets all the preceding siblings up to but not including the element matched
		by the selector, optionally filtered by another selector.
	**/
	function prevUntil<T>(?selector:Dynamic, ?filterSelector:Dynamic):Dynamic;
	/**
		Get the siblings of each element (excluding the element) in the set of
		matched elements, optionally filtered by a selector.
	**/
	function siblings<T>(?selector:Dynamic):Dynamic;
	/**
		Gets the element children of each element in the set of matched elements.
	**/
	function children<T>(?selector:Dynamic):Dynamic;
	/**
		Create an array of nodes, recursing into arrays and parsing strings if necessary.
	**/
	function _makeDomArray<T>(?elem:Dynamic, ?clone:Bool):Array<domhandler.ChildNode>;
	/**
		Insert every element in the set of matched elements to the end of the target.
	**/
	function appendTo<T>(target:Dynamic):Dynamic;
	/**
		Insert every element in the set of matched elements to the beginning of the target.
	**/
	function prependTo<T>(target:Dynamic):Dynamic;
	/**
		The .unwrap() function, removes the parents of the set of matched elements
		from the DOM, leaving the matched elements in their place.
	**/
	function unwrap<T>(?selector:String):Dynamic;
	/**
		The .wrapAll() function can take any string or object that could be passed to
		the $() function to specify a DOM structure. This structure may be nested
		several levels deep, but should contain only one inmost element. The
		structure will be wrapped around all of the elements in the set of matched
		elements, as a single group.
	**/
	function wrapAll<T>(wrapper:Dynamic):Dynamic;
	/**
		Insert content next to each element in the set of matched elements.
	**/
	function after<T>(elems:haxe.extern.Rest<Any>):Dynamic;
	/**
		Insert every element in the set of matched elements after the target.
	**/
	function insertAfter<T>(target:Dynamic):Dynamic;
	/**
		Insert content previous to each element in the set of matched elements.
	**/
	function before<T>(elems:haxe.extern.Rest<Any>):Dynamic;
	/**
		Insert every element in the set of matched elements before the target.
	**/
	function insertBefore<T>(target:Dynamic):Dynamic;
	/**
		Removes the set of matched elements from the DOM and all their children.
		`selector` filters the set of matched elements to be removed.
	**/
	function remove<T>(?selector:String):Dynamic;
	/**
		Replaces matched elements with `content`.
	**/
	function replaceWith<T>(content:Dynamic):Dynamic;
	/**
		Empties an element, removing all its children.
	**/
	function empty<T>():Dynamic;
	/**
		Gets an HTML content string from the first selected element.
		
		Replaces each selected element's content with the specified content.
	**/
	@:overload(function<T>(str:Dynamic):Dynamic { })
	function html<T>():Null<String>;
	/**
		Turns the collection to a string. Alias for `.html()`.
	**/
	function toString<T>():String;
	/**
		Get the combined text contents of each element in the set of matched
		elements, including their descendants.
		
		Set the content of each element in the set of matched elements to the specified text.
	**/
	@:overload(function<T>(str:ts.AnyOf2<String, (i:Float, text:String) -> String>):Dynamic { })
	function text<T>():String;
	/**
		Clone the cheerio object.
	**/
	function clone<T>():Dynamic;
	/**
		Inserts content as the _last_ child of each of the selected elements.
	**/
	function append<T>(elems:haxe.extern.Rest<Any>):Dynamic;
	/**
		Inserts content as the _first_ child of each of the selected elements.
	**/
	function prepend<T>(elems:haxe.extern.Rest<Any>):Dynamic;
	/**
		The .wrap() function can take any string or object that could be passed to
		the $() factory function to specify a DOM structure. This structure may be
		nested several levels deep, but should contain only one inmost element. A
		copy of this structure will be wrapped around each of the elements in the set
		of matched elements. This method returns the original set of elements for
		chaining purposes.
	**/
	function wrap<T>(wrapper:Dynamic):Dynamic;
	/**
		The .wrapInner() function can take any string or object that could be passed
		to the $() factory function to specify a DOM structure. This structure may be
		nested several levels deep, but should contain only one inmost element. The
		structure will be wrapped around the content of each of the elements in the
		set of matched elements.
	**/
	function wrapInner<T>(wrapper:Dynamic):Dynamic;
	/**
		Get the value of a style property for the first element in the set of matched elements.
		
		Get the value of a style property for the first element in the set of matched elements.
		
		Set one CSS property for every matched element.
		
		Set multiple CSS properties for every matched element.
	**/
	@:overload(function<T>(name:String):Null<String> { })
	@:overload(function<T>(prop:String, val:ts.AnyOf2<String, (i:Float, style:String) -> Null<String>>):Dynamic { })
	@:overload(function<T>(map:haxe.DynamicAccess<String>):Dynamic { })
	function css<T>(?names:Array<String>):Null<haxe.DynamicAccess<String>>;
	/**
		Encode a set of form elements as a string for submission.
	**/
	function serialize<T>():String;
	/**
		Encode a set of form elements as an array of names and values.
	**/
	function serializeArray<T>():Array<cheerio.SerializedField>;
	static var prototype : Cheerio<Dynamic>;
}