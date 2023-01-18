@:jsRequire("htmlparser2") @valueModuleOnly extern class Htmlparser2 {
	/**
		Parses the data, returns the resulting document.
	**/
	static function parseDocument(data:String, ?options:htmlparser2.Options):domhandler.Document;
	/**
		Parses data, returns an array of the root nodes.
		
		Note that the root nodes still have a `Document` node as their parent.
		Use `parseDocument` to get the `Document` node instead.
	**/
	static function parseDOM(data:String, ?options:htmlparser2.Options):Array<domhandler.ChildNode>;
	/**
		Creates a parser instance, with an attached DOM handler.
	**/
	static function createDomStream(cb:(error:Null<js.lib.Error>, dom:Array<domhandler.ChildNode>) -> Void, ?options:htmlparser2.Options, ?elementCb:(element:domhandler.Element) -> Void):htmlparser2.Parser;
	/**
		Parse a feed.
	**/
	static function parseFeed(feed:String, ?options:htmlparser2.Options):Null<domutils.Feed>;
	static var type : Dynamic;
	/**
		Get the feed object from the root of a DOM tree.
	**/
	static function getFeed(doc:Array<Dynamic>):Null<domutils.Feed>;
}