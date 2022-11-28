package node;

/**
	The type of a function under test.
	If the test uses callbacks, the callback function is passed as an argument
**/
typedef ItFn = (done:ts.AnyOf2<() -> Void, (result:Dynamic) -> Void>) -> Dynamic;