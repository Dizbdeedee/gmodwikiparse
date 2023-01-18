package domutils;

/**
	An object with keys to check elements against. If a key is `tag_name`,
	`tag_type` or `tag_contains`, it will check the value against that specific
	value. Otherwise, it will check an attribute with the key's name.
**/
typedef TestElementOpts = {
	@:optional
	var tag_name : ts.AnyOf2<String, (name:String) -> Bool>;
	@:optional
	var tag_type : ts.AnyOf2<String, (name:String) -> Bool>;
	@:optional
	var tag_contains : ts.AnyOf3<String, () -> Bool, (data:String) -> Bool>;
};