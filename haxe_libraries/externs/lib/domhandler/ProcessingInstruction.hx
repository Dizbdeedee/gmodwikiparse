package domhandler;

/**
	Processing instructions, including doc types.
**/
@:jsRequire("domhandler", "ProcessingInstruction") extern class ProcessingInstruction extends DataNode {
	function new(name:String, data:String);
	var name : String;
	/**
		If this is a doctype, the document type name (parse5 only).
	**/
	@:optional
	@:native("x-name")
	var x_name : String;
	/**
		If this is a doctype, the document type public identifier (parse5 only).
	**/
	@:optional
	@:native("x-publicId")
	var x_publicId : String;
	/**
		If this is a doctype, the document type system identifier (parse5 only).
	**/
	@:optional
	@:native("x-systemId")
	var x_systemId : String;
	static var prototype : ProcessingInstruction;
}