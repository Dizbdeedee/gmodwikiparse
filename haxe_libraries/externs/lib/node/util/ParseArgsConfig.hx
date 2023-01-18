package node.util;

typedef ParseArgsConfig = {
	@:optional
	var strict : Bool;
	@:optional
	var allowPositionals : Bool;
	@:optional
	var tokens : Bool;
	@:optional
	var options : ParseArgsConfig;
	@:optional
	var args : Array<String>;
};