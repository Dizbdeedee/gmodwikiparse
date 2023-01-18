package cheerio.lib.load;

/**
	A querying function, bound to a document created from the provided markup.
	
	Also provides several helper methods for dealing with the document as a whole.
**/
typedef CheerioAPI = {
	/**
		This selector method is the starting point for traversing and manipulating
		the document. Like jQuery, it's the primary method for selecting elements
		in the document.
		
		`selector` searches within the `context` scope which searches within the
		`root` scope.
	**/
	@:selfCall
	function call<T, S>(?selector:Dynamic, ?context:Dynamic, ?root:Dynamic, ?options:cheerio.lib.options.CheerioOptions):cheerio.lib.cheerio.Cheerio<Dynamic>;
	/**
		The root the document was originally loaded with.
	**/
	var _root : js.html.Document;
	/**
		The options the document was originally loaded with.
	**/
	var _options : cheerio.lib.options.InternalOptions;
	/**
		Mimic jQuery's prototype alias for plugin authors.
	**/
	var fn : cheerio.lib.cheerio.Cheerio<Dynamic>;
	dynamic function load(content:Dynamic, ?options:cheerio.lib.options.CheerioOptions, ?isDocument:Bool):CheerioAPI;
	/**
		Renders the document.
		
		Renders the document.
	**/
	@:overload(function(?dom:Dynamic, ?options:cheerio.lib.options.CheerioOptions):String { })
	function html(?options:cheerio.lib.options.CheerioOptions):String;
	/**
		Render the document as XML.
	**/
	function xml(?dom:Dynamic):String;
	/**
		Render the document as text.
		
		This returns the `textContent` of the passed elements. The result will
		include the contents of `script` and `stype` elements. To avoid this, use
		`.prop('innerText')` instead.
	**/
	function text(?elements:js.lib.ArrayLike<Dynamic>):String;
	/**
		Parses a string into an array of DOM nodes. The `context` argument has no
		meaning for Cheerio, but it is maintained for API compatibility with jQuery.
	**/
	@:overload(function(?data:String):Dynamic { })
	function parseHTML(data:String, ?context:Any, ?keepScripts:Bool):Array<Dynamic>;
	/**
		Sometimes you need to work with the top-level root element. To query it, you
		can use `$.root()`.
	**/
	function root():Dynamic;
	/**
		Checks to see if the `contained` DOM element is a descendant of the
		`container` DOM element.
	**/
	function contains(container:Dynamic, contained:Dynamic):Bool;
	/**
		$.merge().
	**/
	function merge<T>(arr1:cheerio.WritableArrayLike<T>, arr2:js.lib.ArrayLike<T>):Null<js.lib.ArrayLike<T>>;
};