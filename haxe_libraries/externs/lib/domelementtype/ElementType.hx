package domelementtype;

/**
	Types of elements found in htmlparser2's DOM
**/
@:jsRequire("domelementtype", "ElementType") @:enum extern abstract ElementType(String) from String to String {
	/**
		Type for the root element of a document
	**/
	var Root;
	/**
		Type for Text
	**/
	var Text;
	/**
		Type for <? ... ?>
	**/
	var Directive;
	/**
		Type for <!-- ... -->
	**/
	var Comment;
	/**
		Type for <script> tags
	**/
	var Script;
	/**
		Type for <style> tags
	**/
	var Style;
	/**
		Type for Any tag
	**/
	var Tag;
	/**
		Type for <![CDATA[ ... ]]>
	**/
	var CDATA;
	/**
		Type for <!doctype ...>
	**/
	var Doctype;
}