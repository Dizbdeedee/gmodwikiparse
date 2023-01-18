package domutils;

/**
	An entry of a feed.
**/
typedef FeedItem = {
	@:optional
	var id : String;
	@:optional
	var title : String;
	@:optional
	var link : String;
	@:optional
	var description : String;
	@:optional
	var pubDate : js.lib.Date;
	var media : Array<FeedItemMedia>;
};