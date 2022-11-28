package domhandler;

/**
	The root node of the document.
**/
@:jsRequire("domhandler", "Document") extern class Document extends NodeWithChildren {
	/**
		[Document mode](https://dom.spec.whatwg.org/#concept-document-limited-quirks) (parse5 only).
	**/
	@:optional
	@:native("x-mode")
	var x_mode : String;
	static var prototype : Document;
}