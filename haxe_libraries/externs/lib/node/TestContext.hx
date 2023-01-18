package node;

/**
	An instance of `TestContext` is passed to each test function in order to interact with the
	test runner. However, the `TestContext` constructor is not exposed as part of the API.
**/
typedef TestContext = {
	/**
		This function is used to write TAP diagnostics to the output. Any diagnostic information is
		included at the end of the test's results. This function does not return a value.
	**/
	function diagnostic(message:String):Void;
	/**
		If `shouldRunOnlyTests` is truthy, the test context will only run tests that have the `only`
		option set. Otherwise, all tests are run. If Node.js was not started with the `--test-only`
		command-line option, this function is a no-op.
	**/
	function runOnly(shouldRunOnlyTests:Bool):Void;
	/**
		This function causes the test's output to indicate the test as skipped. If `message` is
		provided, it is included in the TAP output. Calling `skip()` does not terminate execution of
		the test function. This function does not return a value.
	**/
	function skip(?message:String):Void;
	/**
		This function adds a `TODO` directive to the test's output. If `message` is provided, it is
		included in the TAP output. Calling `todo()` does not terminate execution of the test
		function. This function does not return a value.
	**/
	function todo(?message:String):Void;
	/**
		This function is used to create subtests under the current test. This function behaves in
		the same fashion as the top level {@link test} function.
	**/
	@:overload(function(?name:String, ?options:TestOptions, ?fn:TestFn):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?options:TestOptions, ?fn:TestFn):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?fn:TestFn):js.lib.Promise<ts.Undefined> { })
	dynamic function test(?name:String, ?fn:TestFn):js.lib.Promise<ts.Undefined>;
};