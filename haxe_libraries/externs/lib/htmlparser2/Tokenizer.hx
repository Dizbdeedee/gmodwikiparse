package htmlparser2;

@:jsRequire("htmlparser2", "Tokenizer") extern class Tokenizer {
	function new(__0:{ @:optional var xmlMode : Bool; @:optional var decodeEntities : Bool; }, cbs:TokenizerCallbacks);
	private final cbs : Dynamic;
	/**
		The current state the tokenizer is in.
	**/
	private var state : Dynamic;
	/**
		The read buffer.
	**/
	private var buffer : Dynamic;
	/**
		The beginning of the section that is currently being read.
	**/
	private var sectionStart : Dynamic;
	/**
		The index within the buffer that we are currently looking at.
	**/
	private var index : Dynamic;
	/**
		Some behavior, eg. when decoding entities, is done while we are in another state. This keeps track of the other state type.
	**/
	private var baseState : Dynamic;
	/**
		For special parsing behavior inside of script and style tags.
	**/
	private var isSpecial : Dynamic;
	/**
		Indicates whether the tokenizer has been paused.
	**/
	var running : Bool;
	/**
		The offset of the current buffer.
	**/
	private var offset : Dynamic;
	private final xmlMode : Dynamic;
	private final decodeEntities : Dynamic;
	private final entityTrie : Dynamic;
	function reset():Void;
	function write(chunk:String):Void;
	function end():Void;
	function pause():Void;
	function resume():Void;
	/**
		The current index within all of the written data.
	**/
	function getIndex():Float;
	/**
		The start of the current section.
	**/
	function getSectionStart():Float;
	private var stateText : Dynamic;
	private var currentSequence : Dynamic;
	private var sequenceIndex : Dynamic;
	private var stateSpecialStartSequence : Dynamic;
	/**
		Look for an end tag. For <title> tags, also decode entities.
	**/
	private var stateInSpecialTag : Dynamic;
	private var stateCDATASequence : Dynamic;
	/**
		When we wait for one specific character, we can speed things up
		by skipping through the buffer until we find it.
	**/
	private var fastForwardTo : Dynamic;
	/**
		Comments and CDATA end with `-->` and `]]>`.
		
		Their common qualities are:
		- Their end sequences have a distinct character they start with.
		- That character is then repeated, so we have to check multiple repeats.
		- All characters but the start character of the sequence can be skipped.
	**/
	private var stateInCommentLike : Dynamic;
	/**
		HTML only allows ASCII alpha characters (a-z and A-Z) at the beginning of a tag name.
		
		XML allows a lot more characters here (@see https://www.w3.org/TR/REC-xml/#NT-NameStartChar).
		We allow anything that wouldn't end the tag.
	**/
	private var isTagStartChar : Dynamic;
	private var startSpecial : Dynamic;
	private var stateBeforeTagName : Dynamic;
	private var stateInTagName : Dynamic;
	private var stateBeforeClosingTagName : Dynamic;
	private var stateInClosingTagName : Dynamic;
	private var stateAfterClosingTagName : Dynamic;
	private var stateBeforeAttributeName : Dynamic;
	private var stateInSelfClosingTag : Dynamic;
	private var stateInAttributeName : Dynamic;
	private var stateAfterAttributeName : Dynamic;
	private var stateBeforeAttributeValue : Dynamic;
	private var handleInAttributeValue : Dynamic;
	private var stateInAttributeValueDoubleQuotes : Dynamic;
	private var stateInAttributeValueSingleQuotes : Dynamic;
	private var stateInAttributeValueNoQuotes : Dynamic;
	private var stateBeforeDeclaration : Dynamic;
	private var stateInDeclaration : Dynamic;
	private var stateInProcessingInstruction : Dynamic;
	private var stateBeforeComment : Dynamic;
	private var stateInSpecialComment : Dynamic;
	private var stateBeforeSpecialS : Dynamic;
	private var trieIndex : Dynamic;
	private var trieCurrent : Dynamic;
	/**
		For named entities, the index of the value. For numeric entities, the code point.
	**/
	private var entityResult : Dynamic;
	private var entityExcess : Dynamic;
	private var stateBeforeEntity : Dynamic;
	private var stateInNamedEntity : Dynamic;
	private var emitNamedEntity : Dynamic;
	private var stateBeforeNumericEntity : Dynamic;
	private var emitNumericEntity : Dynamic;
	private var stateInNumericEntity : Dynamic;
	private var stateInHexEntity : Dynamic;
	private var allowLegacyEntity : Dynamic;
	/**
		Remove data that has already been consumed from the buffer.
	**/
	private var cleanup : Dynamic;
	private var shouldContinue : Dynamic;
	/**
		Iterates through the buffer, calling the function corresponding to the current state.
		
		States that are more likely to be hit are higher up, as a performance improvement.
	**/
	private var parse : Dynamic;
	private var finish : Dynamic;
	/**
		Handle any trailing data.
	**/
	private var handleTrailingData : Dynamic;
	private var emitPartial : Dynamic;
	private var emitCodePoint : Dynamic;
	static var prototype : Tokenizer;
}