@:jsRequire("domelementtype") @valueModuleOnly extern class Domelementtype {
	/**
		Tests whether an element is a tag or not.
	**/
	static function isTag(elem:{ var type : domelementtype.ElementType; }):Bool;
	/**
		Type for the root element of a document
	**/
	static final Root : String;
	/**
		Type for Text
	**/
	static final Text : String;
	/**
		Type for <? ... ?>
	**/
	static final Directive : String;
	/**
		Type for <!-- ... -->
	**/
	static final Comment : String;
	/**
		Type for <script> tags
	**/
	static final Script : String;
	/**
		Type for <style> tags
	**/
	static final Style : String;
	/**
		Type for Any tag
	**/
	static final Tag : String;
	/**
		Type for <![CDATA[ ... ]]>
	**/
	static final CDATA : String;
	/**
		Type for <!doctype ...>
	**/
	static final Doctype : String;
}