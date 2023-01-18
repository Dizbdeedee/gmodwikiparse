package domutils;

/**
	A media item of a feed entry.
**/
typedef FeedItemMedia = {
	var medium : Null<FeedItemMediaMedium>;
	var isDefault : Bool;
	@:optional
	var url : String;
	@:optional
	var fileSize : Float;
	@:optional
	var type : String;
	@:optional
	var expression : FeedItemMediaExpression;
	@:optional
	var bitrate : Float;
	@:optional
	var framerate : Float;
	@:optional
	var samplingrate : Float;
	@:optional
	var channels : Float;
	@:optional
	var duration : Float;
	@:optional
	var height : Float;
	@:optional
	var width : Float;
	@:optional
	var lang : String;
};