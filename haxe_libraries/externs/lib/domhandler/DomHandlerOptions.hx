package domhandler;

typedef DomHandlerOptions = {
	/**
		Add a `startIndex` property to nodes.
		When the parser is used in a non-streaming fashion, `startIndex` is an integer
		indicating the position of the start of the node in the document.
	**/
	@:optional
	var withStartIndices : Bool;
	/**
		Add an `endIndex` property to nodes.
		When the parser is used in a non-streaming fashion, `endIndex` is an integer
		indicating the position of the end of the node in the document.
	**/
	@:optional
	var withEndIndices : Bool;
	/**
		Treat the markup as XML.
	**/
	@:optional
	var xmlMode : Bool;
};