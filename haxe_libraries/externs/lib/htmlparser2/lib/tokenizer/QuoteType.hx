package htmlparser2.lib.tokenizer;

@:jsRequire("htmlparser2/lib/Tokenizer", "QuoteType") @:enum extern abstract QuoteType(Int) from Int to Int {
	var NoValue;
	var Unquoted;
	var Single;
	var Double;
}