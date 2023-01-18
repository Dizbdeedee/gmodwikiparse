package domutils;

@:enum extern abstract DocumentPosition(Int) from Int to Int {
	var DISCONNECTED = 1;
	var PRECEDING = 2;
	var FOLLOWING = 4;
	var CONTAINS = 8;
	var CONTAINED_BY = 16;
}