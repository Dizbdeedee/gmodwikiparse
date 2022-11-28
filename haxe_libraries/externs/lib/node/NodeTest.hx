package node;

/**
	The `node:test` module provides a standalone testing module.
**/
@:jsRequire("node:test") @valueModuleOnly extern class NodeTest {
	/**
		The `test()` function is the value imported from the test module. Each invocation of this
		function results in the creation of a test point in the TAP output.
		
		The {@link TestContext} object passed to the fn argument can be used to perform actions
		related to the current test. Examples include skipping the test, adding additional TAP
		diagnostic information, or creating subtests.
		
		`test()` returns a {@link Promise} that resolves once the test completes. The return value
		can usually be discarded for top level tests. However, the return value from subtests should
		be used to prevent the parent test from finishing first and cancelling the subtest as shown
		in the following example.
		
		```js
		test('top level test', async (t) => {
		   // The setTimeout() in the following subtest would cause it to outlive its
		   // parent test if 'await' is removed on the next line. Once the parent test
		   // completes, it will cancel any outstanding subtests.
		   await t.test('longer running subtest', async (t) => {
		     return new Promise((resolve, reject) => {
		       setTimeout(resolve, 1000);
		     });
		   });
		});
		```
	**/
	@:native("default")
	@:overload(function(?name:String, ?options:NodeTest, ?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?options:NodeTest, ?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	static function default_(?name:String, ?fn:NodeTest):js.lib.Promise<ts.Undefined>;
	/**
		Programmatically start the test runner.
	**/
	static function run(?options:NodeTest):NodeTest;
	/**
		The `test()` function is the value imported from the test module. Each invocation of this
		function results in the creation of a test point in the TAP output.
		
		The {@link TestContext} object passed to the fn argument can be used to perform actions
		related to the current test. Examples include skipping the test, adding additional TAP
		diagnostic information, or creating subtests.
		
		`test()` returns a {@link Promise} that resolves once the test completes. The return value
		can usually be discarded for top level tests. However, the return value from subtests should
		be used to prevent the parent test from finishing first and cancelling the subtest as shown
		in the following example.
		
		```js
		test('top level test', async (t) => {
		   // The setTimeout() in the following subtest would cause it to outlive its
		   // parent test if 'await' is removed on the next line. Once the parent test
		   // completes, it will cancel any outstanding subtests.
		   await t.test('longer running subtest', async (t) => {
		     return new Promise((resolve, reject) => {
		       setTimeout(resolve, 1000);
		     });
		   });
		});
		```
	**/
	@:overload(function(?name:String, ?options:NodeTest, ?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?options:NodeTest, ?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	@:overload(function(?fn:NodeTest):js.lib.Promise<ts.Undefined> { })
	static function test(?name:String, ?fn:NodeTest):js.lib.Promise<ts.Undefined>;
	@:overload(function(?name:String, ?fn:NodeTest):Void { })
	@:overload(function(?options:NodeTest, ?fn:NodeTest):Void { })
	@:overload(function(?fn:NodeTest):Void { })
	static function describe(?name:String, ?options:NodeTest, ?fn:NodeTest):Void;
	@:overload(function(?name:String, ?fn:NodeTest):Void { })
	@:overload(function(?options:NodeTest, ?fn:NodeTest):Void { })
	@:overload(function(?fn:NodeTest):Void { })
	static function it(?name:String, ?options:NodeTest, ?fn:NodeTest):Void;
}