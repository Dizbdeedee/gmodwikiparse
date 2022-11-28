package domhandler;

/**
	An element within the DOM.
**/
@:jsRequire("domhandler", "Element") extern class Element extends NodeWithChildren {
	function new(name:String, attribs:haxe.DynamicAccess<String>, ?children:Array<ChildNode>, ?type:String);
	var name : String;
	var attribs : haxe.DynamicAccess<String>;
	/**
		Same as {@link name}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var tagName : String;
	final attributes : Array<Attribute>;
	/**
		Element namespace (parse5 only).
	**/
	@:optional
	var namespace : String;
	/**
		Element attribute namespaces (parse5 only).
	**/
	@:optional
	@:native("x-attribsNamespace")
	var x_attribsNamespace : haxe.DynamicAccess<String>;
	/**
		Element attribute namespace-related prefixes (parse5 only).
	**/
	@:optional
	@:native("x-attribsPrefix")
	var x_attribsPrefix : haxe.DynamicAccess<String>;
	static var prototype : Element;
}