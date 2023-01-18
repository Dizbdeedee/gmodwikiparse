@:jsRequire("domutils") @valueModuleOnly extern class Domutils {
	static function isTag(node:domhandler.Node):Bool;
	static function isCDATA(node:domhandler.Node):Bool;
	static function isText(node:domhandler.Node):Bool;
	static function isComment(node:domhandler.Node):Bool;
	static function isDocument(node:domhandler.Node):Bool;
	static function hasChildren(node:domhandler.Node):Bool;
	static function getOuterHTML(node:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, js.lib.ArrayLike<domhandler.ChildNode>>, ?options:dom_serializer.DomSerializerOptions):String;
	static function getInnerHTML(node:domhandler.ChildNode, ?options:dom_serializer.DomSerializerOptions):String;
	/**
		Get a node's inner text. Same as `textContent`, but inserts newlines for `<br>` tags.
	**/
	static function getText(node:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>):String;
	/**
		Get a node's text content.
	**/
	static function textContent(node:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>):String;
	/**
		Get a node's inner text.
	**/
	static function innerText(node:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>):String;
	/**
		Get a node's children.
	**/
	static function getChildren(elem:domhandler.ChildNode):Array<domhandler.ChildNode>;
	static function getParent(elem:domhandler.ChildNode):Null<domhandler.ParentNode>;
	/**
		Gets an elements siblings, including the element itself.
		
		Attempts to get the children through the element's parent first. If we don't
		have a parent (the element is a root node), we walk the element's `prev` &
		`next` to get all remaining nodes.
	**/
	static function getSiblings(elem:domhandler.ChildNode):Array<domhandler.ChildNode>;
	/**
		Gets an attribute from an element.
	**/
	static function getAttributeValue(elem:domhandler.Element, name:String):Null<String>;
	/**
		Checks whether an element has an attribute.
	**/
	static function hasAttrib(elem:domhandler.Element, name:String):Bool;
	/**
		Get the tag name of an element.
	**/
	static function getName(elem:domhandler.Element):String;
	/**
		Returns the next element sibling of a node.
	**/
	static function nextElementSibling(elem:domhandler.ChildNode):Null<domhandler.Element>;
	/**
		Returns the previous element sibling of a node.
	**/
	static function prevElementSibling(elem:domhandler.ChildNode):Null<domhandler.Element>;
	/**
		Remove an element from the dom
	**/
	static function removeElement(elem:js.html.ChildNode):Void;
	/**
		Replace an element in the dom
	**/
	static function replaceElement(elem:js.html.ChildNode, replacement:js.html.ChildNode):Void;
	/**
		Append a child to an element.
	**/
	static function appendChild(elem:js.html.DOMElement, child:js.html.ChildNode):Void;
	/**
		Append an element after another.
	**/
	static function append(elem:js.html.ChildNode, next:js.html.ChildNode):Void;
	/**
		Prepend a child to an element.
	**/
	static function prependChild(elem:js.html.DOMElement, child:js.html.ChildNode):Void;
	/**
		Prepend an element before another.
	**/
	static function prepend(elem:js.html.ChildNode, prev:js.html.ChildNode):Void;
	/**
		Search a node and its children for nodes passing a test function.
	**/
	static function filter(test:(elem:domhandler.ChildNode) -> Bool, node:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>, ?recurse:Bool, ?limit:Float):Array<domhandler.ChildNode>;
	/**
		Search an array of node and its children for nodes passing a test function.
	**/
	static function find(test:(elem:domhandler.ChildNode) -> Bool, nodes:Array<domhandler.ChildNode>, recurse:Bool, limit:Float):Array<domhandler.ChildNode>;
	/**
		Finds the first element inside of an array that matches a test function.
	**/
	static function findOneChild<T>(test:(elem:T) -> Bool, nodes:Array<T>):Null<T>;
	/**
		Finds one element in a tree that passes a test.
	**/
	static function findOne(test:(elem:domhandler.Element) -> Bool, nodes:Array<domhandler.ChildNode>, ?recurse:Bool):Null<domhandler.Element>;
	static function existsOne(test:(elem:domhandler.Element) -> Bool, nodes:Array<domhandler.ChildNode>):Bool;
	/**
		Search and array of nodes and its children for elements passing a test function.
		
		Same as `find`, but limited to elements and with less options, leading to reduced complexity.
	**/
	static function findAll(test:(elem:domhandler.Element) -> Bool, nodes:Array<domhandler.ChildNode>):Array<domhandler.Element>;
	static function testElement(options:domutils.TestElementOpts, node:domhandler.ChildNode):Bool;
	static function getElements(options:domutils.TestElementOpts, nodes:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>, recurse:Bool, ?limit:Float):Array<domhandler.ChildNode>;
	static function getElementById(id:ts.AnyOf2<String, (id:String) -> Bool>, nodes:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>, ?recurse:Bool):Null<domhandler.Element>;
	static function getElementsByTagName(tagName:ts.AnyOf2<String, (name:String) -> Bool>, nodes:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>, ?recurse:Bool, ?limit:Float):Array<domhandler.Element>;
	static function getElementsByTagType(type:Dynamic, nodes:ts.AnyOf7<domhandler.Document, domhandler.Element, domhandler.CDATA, domhandler.Text, domhandler.Comment, domhandler.ProcessingInstruction, Array<domhandler.ChildNode>>, ?recurse:Bool, ?limit:Float):Array<domhandler.ChildNode>;
	/**
		Given an array of nodes, remove any member that is contained by another.
	**/
	static function removeSubsets(nodes:Array<domhandler.ChildNode>):Array<domhandler.ChildNode>;
	/**
		Compare the position of one node against another node in any other document.
		The return value is a bitmask with the values from {@link DocumentPosition}.
		
		Document order:
		> There is an ordering, document order, defined on all the nodes in the
		> document corresponding to the order in which the first character of the
		> XML representation of each node occurs in the XML representation of the
		> document after expansion of general entities. Thus, the document element
		> node will be the first node. Element nodes occur before their children.
		> Thus, document order orders element nodes in order of the occurrence of
		> their start-tag in the XML (after expansion of entities). The attribute
		> nodes of an element occur after the element and before its children. The
		> relative order of attribute nodes is implementation-dependent.
		
		Source:
		http://www.w3.org/TR/DOM-Level-3-Core/glossary.html#dt-document-order
	**/
	static function compareDocumentPosition(nodeA:domhandler.ChildNode, nodeB:domhandler.ChildNode):Float;
	/**
		Sort an array of nodes based on their relative position in the document and
		remove any duplicate nodes. If the array contains nodes that do not belong to
		the same document, sort order is unspecified.
	**/
	static function uniqueSort<T>(nodes:Array<T>):Array<T>;
	/**
		Get the feed object from the root of a DOM tree.
	**/
	static function getFeed(doc:Array<Dynamic>):Null<domutils.Feed>;
}