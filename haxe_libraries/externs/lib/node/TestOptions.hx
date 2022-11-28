package node;

typedef TestOptions = {
	/**
		The number of tests that can be run at the same time. If unspecified, subtests inherit this
		value from their parent.
	**/
	@:optional
	var concurrency : Float;
	/**
		If truthy, and the test context is configured to run `only` tests, then this test will be
		run. Otherwise, the test is skipped.
	**/
	@:optional
	var only : Bool;
	/**
		Allows aborting an in-progress test.
	**/
	@:optional
	var signal : js.html.AbortSignal;
	/**
		If truthy, the test is skipped. If a string is provided, that string is displayed in the
		test results as the reason for skipping the test.
	**/
	@:optional
	var skip : ts.AnyOf2<String, Bool>;
	/**
		A number of milliseconds the test will fail after. If unspecified, subtests inherit this
		value from their parent.
	**/
	@:optional
	var timeout : Float;
	/**
		If truthy, the test marked as `TODO`. If a string is provided, that string is displayed in
		the test results as the reason why the test is `TODO`.
	**/
	@:optional
	var todo : ts.AnyOf2<String, Bool>;
};