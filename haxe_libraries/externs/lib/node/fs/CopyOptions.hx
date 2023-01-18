package node.fs;

typedef CopyOptions = {
	/**
		Function to filter copied files/directories. Return
		`true` to copy the item, `false` to ignore it.
	**/
	@:optional
	function filter(source:String, destination:String):ts.AnyOf2<Bool, js.lib.Promise<Bool>>;
	/**
		Dereference symlinks
	**/
	@:optional
	var dereference : Bool;
	/**
		When `force` is `false`, and the destination
		exists, throw an error.
	**/
	@:optional
	var errorOnExist : Bool;
	/**
		Overwrite existing file or directory. _The copy
		operation will ignore errors if you set this to false and the destination
		exists. Use the `errorOnExist` option to change this behavior.
	**/
	@:optional
	var force : Bool;
	/**
		When `true` timestamps from `src` will
		be preserved.
	**/
	@:optional
	var preserveTimestamps : Bool;
	/**
		Copy directories recursively.
	**/
	@:optional
	var recursive : Bool;
	/**
		When true, path resolution for symlinks will be skipped
	**/
	@:optional
	var verbatimSymlinks : Bool;
};