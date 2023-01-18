package htmlparser2;

@:jsRequire("htmlparser2", "Parser") extern class Parser {
	function new(?cbs:{ @:optional dynamic function onparserinit(parser:Parser):Void; /** Resets the handler back to starting state **/ @:optional dynamic function onreset():Void; /** Signals the handler that parsing is done **/ @:optional dynamic function onend():Void; @:optional dynamic function onerror(error:js.lib.Error):Void; @:optional dynamic function onclosetag(name:String, isImplied:Bool):Void; @:optional dynamic function onopentagname(name:String):Void; @:optional dynamic function onattribute(name:String, value:String, ?quote:String):Void; @:optional dynamic function onopentag(name:String, attribs:haxe.DynamicAccess<String>, isImplied:Bool):Void; @:optional dynamic function ontext(data:String):Void; @:optional dynamic function oncomment(data:String):Void; @:optional dynamic function oncdatastart():Void; @:optional dynamic function oncdataend():Void; @:optional dynamic function oncommentend():Void; @:optional dynamic function onprocessinginstruction(name:String, data:String):Void; }, ?options:ParserOptions);
	private final options : Dynamic;
	/**
		The start index of the last event.
	**/
	var startIndex : Float;
	/**
		The end index of the last event.
	**/
	var endIndex : Float;
	/**
		Store the start index of the current open tag,
		so we can update the start index for attributes.
	**/
	private var openTagStart : Dynamic;
	private var tagname : Dynamic;
	private var attribname : Dynamic;
	private var attribvalue : Dynamic;
	private var attribs : Dynamic;
	private var stack : Dynamic;
	private final foreignContext : Dynamic;
	private final cbs : Dynamic;
	private final lowerCaseTagNames : Dynamic;
	private final lowerCaseAttributeNames : Dynamic;
	private final tokenizer : Dynamic;
	private final buffers : Dynamic;
	private var bufferOffset : Dynamic;
	/**
		The index of the last written buffer. Used when resuming after a `pause()`.
	**/
	private var writeIndex : Dynamic;
	/**
		Indicates whether the parser has finished running / `.end` has been called.
	**/
	private var ended : Dynamic;
	function ontext(start:Float, endIndex:Float):Void;
	function ontextentity(cp:Float):Void;
	private function isVoidElement(name:String):Bool;
	function onopentagname(start:Float, endIndex:Float):Void;
	private var emitOpenTag : Dynamic;
	private var endOpenTag : Dynamic;
	function onopentagend(endIndex:Float):Void;
	function onclosetag(start:Float, endIndex:Float):Void;
	function onselfclosingtag(endIndex:Float):Void;
	private var closeCurrentTag : Dynamic;
	function onattribname(start:Float, endIndex:Float):Void;
	function onattribdata(start:Float, endIndex:Float):Void;
	function onattribentity(cp:Float):Void;
	function onattribend(quote:htmlparser2.lib.tokenizer.QuoteType, endIndex:Float):Void;
	private var getInstructionName : Dynamic;
	function ondeclaration(start:Float, endIndex:Float):Void;
	function onprocessinginstruction(start:Float, endIndex:Float):Void;
	function oncomment(start:Float, endIndex:Float, offset:Float):Void;
	function oncdata(start:Float, endIndex:Float, offset:Float):Void;
	function onend():Void;
	/**
		Resets the parser to a blank state, ready to parse a new HTML document
	**/
	function reset():Void;
	/**
		Resets the parser, then parses a complete document and
		pushes it to the handler.
	**/
	function parseComplete(data:String):Void;
	private var getSlice : Dynamic;
	private var shiftBuffer : Dynamic;
	/**
		Parses a chunk of data and calls the corresponding callbacks.
	**/
	function write(chunk:String):Void;
	/**
		Parses the end of the buffer and clears the stack, calls onend.
	**/
	function end(?chunk:String):Void;
	/**
		Pauses parsing. The parser won't emit events until `resume` is called.
	**/
	function pause():Void;
	/**
		Resumes parsing after `pause` was called.
	**/
	function resume():Void;
	/**
		Alias of `write`, for backwards compatibility.
	**/
	function parseChunk(chunk:String):Void;
	/**
		Alias of `end`, for backwards compatibility.
	**/
	function done(?chunk:String):Void;
	static var prototype : Parser;
}