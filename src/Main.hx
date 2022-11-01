// import node_warc.WARCParser;
// import haxe.Json;
import haxe.Timer;
using tink.CoreApi;
import js.node.Fs;
import WikiDB;


typedef Page = {
	address : String,
	updateCount : Int,
	viewCount : Int
}

extern class WARCResult {
	function readFully():js.lib.Promise<Null<Dynamic>>;

	var warcTargetURI:String;

	var payload:js.lib.Uint8Array;

	var warcType:String;
}


@:jsRequire("warcio", "WARCParser")
extern class WARCParser {
	function new(source:Dynamic,?opt:Dynamic);

	function parse():js.lib.Promise<Null<WARCResult>>;

}


class Main {

	static function parseWorker(warc:WARCParser,parse:ContentParser) {
		return new Promise((success,failure) -> {
			var doNothing = false;
			function parseResult(result:Outcome<WARCResult,Error>) {
				if (doNothing) return;
				switch (result) {
					case Success(data):
						if (data == null) {
							success(Noise);
						} else {
							parse.parse(data).handle((outcome) -> {
								switch (outcome) {
									case Success(_):
										warc.parse().toPromise().handle(parseResult);
									case Failure(err):
										failure(err);
								}
							});
						}
					case Failure(err):
						failure(err);
				}

			}
			warc.parse().toPromise().handle(parseResult);
			return () -> {
				doNothing = true;
			};
		});
	}

	public static function main() {
		var driver = new tink.sql.drivers.Sqlite(s -> "wikidb");
		var db = new WikiDB("wiki_db",driver);
		var warc = new WARCParser(Fs.createReadStream("gmodwiki.warc.gz"));
		var parse = new ContentParser();
		parseWorker(warc,parse).handle((outcome) -> {
			switch (outcome) {
				case Success(_):
					trace("Poggers completed");
				case Failure(failure):
					trace('grr failure $failure');
			}
		});
	}
}


class Async {
  extern public static inline function await<M, T:js.lib.Promise<M>>(t:T):M {
	return js.Syntax.code("await {0}", t);
  }
  extern public static inline function async(f:Void->Void):Void {
	js.Syntax.code("async {0}", f)();
  }
}