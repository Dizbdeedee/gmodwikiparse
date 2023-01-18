package warcio;

extern class WARCResult {
	function readFully():js.lib.Promise<Null<Dynamic>>;

	var warcTargetURI:String;

	var payload:js.lib.Uint8Array;

	var warcType:String;
}
