package node;

typedef TestPass = {
	/**
		The test duration.
	**/
	var duration : Float;
	/**
		The test name.
	**/
	var name : String;
	/**
		The ordinal number of the test.
	**/
	var testNumber : Float;
	/**
		Present if `context.todo` is called.
	**/
	@:optional
	var todo : String;
	/**
		Present if `context.skip` is called.
	**/
	@:optional
	var skip : String;
};