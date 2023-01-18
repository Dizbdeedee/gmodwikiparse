@:jsRequire("domhandler") @valueModuleOnly extern class Domhandler {
	static function isTag(node:domhandler.Node):Bool;
	static function isCDATA(node:domhandler.Node):Bool;
	static function isText(node:domhandler.Node):Bool;
	static function isComment(node:domhandler.Node):Bool;
	static function isDirective(node:domhandler.Node):Bool;
	static function isDocument(node:domhandler.Node):Bool;
	static function hasChildren(node:domhandler.Node):Bool;
	/**
		Clone a node, and optionally its children.
	**/
	static function cloneNode<T>(node:T, ?recursive:Bool):T;
}