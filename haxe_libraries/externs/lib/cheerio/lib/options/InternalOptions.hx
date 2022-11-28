package cheerio.lib.options;

/**
	Internal options for Cheerio.
**/
typedef InternalOptions = {
	/**
		Whether to use htmlparser2.
		
		This is set to true if `xml` is set to true.
	**/
	@:optional
	var _useHtmlParser2 : Bool;
	/**
		Is the document in quirks mode?
		
		This will lead to `.className` and `#id` being case-insensitive.
	**/
	@:optional
	var quirksMode : Dynamic;
	/**
		Extension point for pseudo-classes.
		
		Maps from names to either strings of functions.
		
		- A string value is a selector that the element must match to be selected.
		- A function is called with the element as its first argument, and optional
		   parameters second. If it returns true, the element is selected.
	**/
	@:optional
	var pseudos : Dynamic;
	/**
		The base URI for the document. Used for the `href` and `src` props.
	**/
	@:optional
	var baseURI : ts.AnyOf2<String, js.html.URL>;
	/**
		Disable scripting in parse5, so noscript tags would be parsed.
	**/
	@:optional
	var scriptingEnabled : Bool;
	/**
		Enable location support for parse5.
	**/
	@:optional
	var sourceCodeLocationInfo : Bool;
};