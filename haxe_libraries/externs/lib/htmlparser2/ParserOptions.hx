package htmlparser2;

typedef ParserOptions = {
	/**
		Indicates whether special tags (`<script>`, `<style>`, and `<title>`) should get special treatment
		and if "empty" tags (eg. `<br>`) can have children.  If `false`, the content of special tags
		will be text only. For feeds and other XML content (documents that don't consist of HTML),
		set this to `true`.
	**/
	@:optional
	var xmlMode : Bool;
	/**
		Decode entities within the document.
	**/
	@:optional
	var decodeEntities : Bool;
	/**
		If set to true, all tags will be lowercased.
	**/
	@:optional
	var lowerCaseTags : Bool;
	/**
		If set to `true`, all attribute names will be lowercased. This has noticeable impact on speed.
	**/
	@:optional
	var lowerCaseAttributeNames : Bool;
	/**
		If set to true, CDATA sections will be recognized as text even if the xmlMode option is not enabled.
		NOTE: If xmlMode is set to `true` then CDATA sections will always be recognized as text.
	**/
	@:optional
	var recognizeCDATA : Bool;
	/**
		If set to `true`, self-closing tags will trigger the onclosetag event even if xmlMode is not set to `true`.
		NOTE: If xmlMode is set to `true` then self-closing tags will always be recognized.
	**/
	@:optional
	var recognizeSelfClosing : Bool;
	/**
		Allows the default tokenizer to be overwritten.
	**/
	@:optional
	var Tokenizer : {
		var prototype : Tokenizer;
	};
};