// import node_warc.WARCParser;
// import haxe.Json;
import haxe.Timer;
using tink.CoreApi;
import js.node.Fs;
import WikiDB;
import warcio.WARCParser;
import warcio.WARCResult;


typedef Page = {
	address : String,
	updateCount : Int,
	viewCount : Int
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
	//@:tables(DescItem,Function,FunctionArg,FunctionRet,LuaExample,Struct,StructMember,GClass,Library,GEnum,GEnumMembers)
	static function createDBs(db:WikiDB):Promise<Noise> {
		var databasePromises = [
			db.DescItem.create(true),
			db.DescriptionStorage.create(true),
			db.Function.create(true),
			db.FunctionArg.create(true),
			db.FunctionRet.create(true),
			db.LuaExample.create(true),
			db.Struct.create(true),
			db.GClass.create(true),
			db.Library.create(true),
			db.GEnum.create(true),
			db.GEnumMembers.create(true)
		];
		return Promise.inParallel(databasePromises);
	}

	public static function main() {
		var driver = new tink.sql.drivers.Sqlite(s -> "wikidb");
		var db = new WikiDB("wiki_db",driver);
		createDBs(db).handle((out) -> {
			trace(out);
		});
		// db.DescItem.create(true).next(_ -> 
		// 	db.Function.create(true).next(_ -> 
		// 		db.FunctionArg.create(true).next
		// 	)
		// ).handle((out) -> {
		// 	trace(out);
		// });
		var warc = new WARCParser(Fs.createReadStream("gmodwiki.warc.gz"));
		var parse = new ContentParser(db);
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