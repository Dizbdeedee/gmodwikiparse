package cheerio.lib.options;

/**
	Options accepted by Cheerio.
	
	Please note that parser-specific options are _only recognized_ if the
	relevant parser is used.
**/
typedef CheerioOptions = {
	/**
		Recommended way of configuring htmlparser2 when wanting to parse XML.
	**/
	@:optional
	var xml : ts.AnyOf2<Bool, HTMLParser2Options>;
	/**
		The base URI for the document. Used for the `href` and `src` props.
	**/
	@:optional
	var baseURI : ts.AnyOf2<String, js.html.URL>;
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