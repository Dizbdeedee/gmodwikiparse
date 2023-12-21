package typelink;

// just a helper for the id matching. the manual way is easier! whatever
@:transitive
enum abstract HaxeTypeCategories(Int) from Int to Int {
	var table = 1;
	var string;
	var any;
	var boolean;
	var effects;
	var _function;
	var gclass;
	var genum;
	var number;
	var panel;
	var struct;
	var swep;
	var vararg;
}
