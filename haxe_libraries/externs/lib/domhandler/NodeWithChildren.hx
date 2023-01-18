package domhandler;

/**
	A `Node` that can have children.
**/
@:jsRequire("domhandler", "NodeWithChildren") extern class NodeWithChildren extends Node {
	function new(children:Array<ChildNode>);
	var children : Array<ChildNode>;
	/**
		First child of the node.
	**/
	final firstChild : Null<ChildNode>;
	/**
		Last child of the node.
	**/
	final lastChild : Null<ChildNode>;
	/**
		Same as {@link children}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var childNodes : Array<ChildNode>;
	static var prototype : NodeWithChildren;
}