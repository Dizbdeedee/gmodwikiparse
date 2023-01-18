@:jsRequire("cheerio") @valueModuleOnly extern class Cheerio {
	/**
		Create a querying function, bound to a document created from the provided markup.
		
		Note that similar to web browser contexts, this operation may introduce
		`<html>`, `<head>`, and `<body>` elements; set `isDocument` to `false` to
		switch to fragment mode and disable this.
	**/
	static function load(content:ts.AnyOf9<String, domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>, global.Buffer>, ?options:cheerio.lib.options.CheerioOptions, ?isDocument:Bool):cheerio.lib.load.CheerioAPI;
	/**
		The default cheerio instance.
	**/
	@:native("default")
	static final default_ : cheerio.lib.load.CheerioAPI;
	/**
		Renders the document.
		
		Renders the document.
	**/
	@:overload(function(?dom:Dynamic, ?options:cheerio.lib.options.CheerioOptions):String { })
	static function html(?options:cheerio.lib.options.CheerioOptions):String;
	/**
		Render the document as XML.
	**/
	static function xml(?dom:Dynamic):String;
	/**
		Render the document as text.
		
		This returns the `textContent` of the passed elements. The result will
		include the contents of `script` and `stype` elements. To avoid this, use
		`.prop('innerText')` instead.
	**/
	static function text(?elements:js.lib.ArrayLike<Dynamic>):String;
	/**
		In order to promote consistency with the jQuery library, users are encouraged
		to instead use the static method of the same name.
	**/
	static function contains(container:Dynamic, contained:Dynamic):Bool;
	/**
		In order to promote consistency with the jQuery library, users are encouraged
		to instead use the static method of the same name.
	**/
	static function merge<T>(arr1:cheerio.WritableArrayLike<T>, arr2:js.lib.ArrayLike<T>):Null<js.lib.ArrayLike<T>>;
	/**
		In order to promote consistency with the jQuery library, users are encouraged
		to instead use the static method of the same name as it is defined on the
		"loaded" Cheerio factory function.
	**/
	@:overload(function(?data:String):Dynamic { })
	static function parseHTML(data:String, ?context:Any, ?keepScripts:Bool):Array<Dynamic>;
	/**
		Users seeking to access the top-level element of a parsed document should
		instead use the `root` static method of a "loaded" Cheerio function.
	**/
	static function root():Dynamic;
}