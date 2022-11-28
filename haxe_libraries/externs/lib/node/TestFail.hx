package node;

typedef TestFail = {
	/**
		The test duration.
	**/
	var duration : Float;
	/**
		The failure casing test to fail.
	**/
	var error : js.lib.Error;
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