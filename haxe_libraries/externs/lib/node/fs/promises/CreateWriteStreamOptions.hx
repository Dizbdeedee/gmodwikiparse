package node.fs.promises;

typedef CreateWriteStreamOptions = {
	@:optional
	var encoding : global.BufferEncoding;
	@:optional
	var autoClose : Bool;
	@:optional
	var emitClose : Bool;
	@:optional
	var start : Float;
};