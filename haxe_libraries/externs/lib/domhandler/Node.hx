package domhandler;

/**
	This object will be used as the prototype for Nodes when creating a
	DOM-Level-1-compliant structure.
**/
@:jsRequire("domhandler", "Node") extern class Node {
	function new();
	/**
		The type of the node.
	**/
	final type : Dynamic;
	/**
		Parent of the node
	**/
	var parent : Null<ParentNode>;
	/**
		Previous sibling
	**/
	var prev : Null<ChildNode>;
	/**
		Next sibling
	**/
	var next : Null<ChildNode>;
	/**
		The start index of the node. Requires `withStartIndices` on the handler to be `true.
	**/
	var startIndex : Null<Float>;
	/**
		The end index of the node. Requires `withEndIndices` on the handler to be `true.
	**/
	var endIndex : Null<Float>;
	/**
		`parse5` source code location info.
		
		Available if parsing with parse5 and location info is enabled.
	**/
	@:optional
	var sourceCodeLocation : SourceCodeLocation;
	/**
		[DOM spec](https://dom.spec.whatwg.org/#dom-node-nodetype)-compatible
		node {@link type}.
	**/
	final nodeType : Float;
	/**
		Same as {@link parent}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var parentNode : Null<ParentNode>;
	/**
		Same as {@link prev}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var previousSibling : Null<ChildNode>;
	/**
		Same as {@link next}.
		[DOM spec](https://dom.spec.whatwg.org)-compatible alias.
	**/
	var nextSibling : Null<ChildNode>;
	/**
		Clone this node, and optionally its children.
	**/
	function cloneNode<T>(?recursive:Bool):T;
	static var prototype : Node;
}