package domhandler;

/**
	A node that contains some data.
**/
@:jsRequire("domhandler", "DataNode") extern class DataNode extends Node {
	function new(data:String);
	var data : String;
	/**
		Same as {@link data}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var nodeValue : String;
	static var prototype : DataNode;
}