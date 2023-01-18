package warcio;
@:jsRequire("warcio", "WARCParser")
extern class WARCParser {
	function new(source:Dynamic,?opt:Dynamic);

	function parse():js.lib.Promise<Null<WARCResult>>;

}
