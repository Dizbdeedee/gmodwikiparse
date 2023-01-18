package htmlparser2;

typedef TokenizerCallbacks = {
	function onattribdata(start:Float, endIndex:Float):Void;
	function onattribentity(codepoint:Float):Void;
	function onattribend(quote:htmlparser2.lib.tokenizer.QuoteType, endIndex:Float):Void;
	function onattribname(start:Float, endIndex:Float):Void;
	function oncdata(start:Float, endIndex:Float, endOffset:Float):Void;
	function onclosetag(start:Float, endIndex:Float):Void;
	function oncomment(start:Float, endIndex:Float, endOffset:Float):Void;
	function ondeclaration(start:Float, endIndex:Float):Void;
	function onend():Void;
	function onopentagend(endIndex:Float):Void;
	function onopentagname(start:Float, endIndex:Float):Void;
	function onprocessinginstruction(start:Float, endIndex:Float):Void;
	function onselfclosingtag(endIndex:Float):Void;
	function ontext(start:Float, endIndex:Float):Void;
	function ontextentity(codepoint:Float):Void;
};