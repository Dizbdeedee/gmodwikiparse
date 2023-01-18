package domhandler;

@:jsRequire("domhandler", "DomHandler") extern class DomHandler {
	function new(?callback:Callback, ?options:DomHandlerOptions, ?elementCB:ElementCallback);
	/**
		The elements of the DOM
	**/
	var dom : Array<ChildNode>;
	/**
		The root element for the DOM
	**/
	var root : Document;
	/**
		Called once parsing has completed.
	**/
	private final callback : Dynamic;
	/**
		Settings for the handler.
	**/
	private final options : Dynamic;
	/**
		Callback whenever a tag is closed.
	**/
	private final elementCB : Dynamic;
	/**
		Indicated whether parsing has been completed.
	**/
	private var done : Dynamic;
	/**
		Stack of open tags.
	**/
	private var tagStack : Array<ParentNode>;
	/**
		A data node that is still being written to.
	**/
	private var lastNode : Null<DataNode>;
	/**
		Reference to the parser instance. Used for location information.
	**/
	private var parser : Dynamic;
	function onparserinit(parser:ParserInterface):Void;
	function onreset():Void;
	function onend():Void;
	function onerror(error:js.lib.Error):Void;
	function onclosetag():Void;
	function onopentag(name:String, attribs:haxe.DynamicAccess<String>):Void;
	function ontext(data:String):Void;
	function oncomment(data:String):Void;
	function oncommentend():Void;
	function oncdatastart():Void;
	function oncdataend():Void;
	function onprocessinginstruction(name:String, data:String):Void;
	private function handleCallback(error:Null<js.lib.Error>):Void;
	private function addNode(node:ChildNode):Void;
	static var prototype : DomHandler;
}