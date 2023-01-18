package domhandler;

/**
	The description of an individual attribute.
**/
typedef Attribute = {
	var name : String;
	var value : String;
	@:optional
	var namespace : String;
	@:optional
	var prefix : String;
};