package node;

/**
	The type of a function under Suite.
	If the test uses callbacks, the callback function is passed as an argument
**/
typedef SuiteFn = (done:ts.AnyOf2<() -> Void, (result:Dynamic) -> Void>) -> Void;