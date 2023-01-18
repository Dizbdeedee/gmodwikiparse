package domutils;

/**
	The root of a feed.
**/
typedef Feed = {
	var type : String;
	@:optional
	var id : String;
	@:optional
	var title : String;
	@:optional
	var link : String;
	@:optional
	var description : String;
	@:optional
	var updated : js.lib.Date;
	@:optional
	var author : String;
	var items : Array<FeedItem>;
};