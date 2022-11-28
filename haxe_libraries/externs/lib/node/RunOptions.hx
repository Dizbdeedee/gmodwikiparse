package node;

typedef RunOptions = {
	@:optional
	var concurrency : ts.AnyOf2<Float, Bool>;
	/**
		An array containing the list of files to run. If unspecified, the test runner execution model will be used.
	**/
	@:optional
	var files : haxe.ds.ReadOnlyArray<String>;
	/**
		Allows aborting an in-progress test.
	**/
	@:optional
	var signal : js.html.AbortSignal;
	/**
		A number of milliseconds the test will fail after. If unspecified, subtests inherit this
		value from their parent.
	**/
	@:optional
	var timeout : Float;
};