// import node_warc.WARCParser;
// import haxe.Json;
import haxe.Json;
import node.readline.ReadLine;
import js.node.Readline;
import generators.gclass.GClassResolver.GClassResolverDef;
import typelink.TypeLinker;
import generators.standard.FunctionResolver;
import haxe.Timer;

using tink.CoreApi;

import js.node.Fs;
import data.WikiDB;
import warcio.WARCParser;
import warcio.WARCResult;
import Util.PromiseArray;

typedef Page = {
	address:String,
	updateCount:Int,
	viewCount:Int
}

final WARC_NAME = "gmodwiki";
final WARC_EXT = ".warc";
final WARC_EXT_ZIPPED = ".warc.gz";

// append to warc
class Main {
	static function parseWorker(dbConnection:data.WikiDB, warcParse:WARCParser, contentParse:ContentParser) {
		function processWARC(data:WARCResult) {
			return if (data != null) {
				contentParse.parse(dbConnection, data)
					.next(_ -> warcParse.parse()
						.toPromise()
						.next(processWARC));
			} else {
				Promise.resolve(true);
			}
		}
		return warcParse.parse()
			.toPromise()
			.next(processWARC);
	}

	static function createDBs(dbConnection:WikiDB):Promise<Noise> {
		var databasePromises = [
			dbConnection.DescItem.create(true),
			dbConnection.DescriptionStorage.create(true),
			dbConnection.Function.create(true),
			dbConnection.FunctionArg.create(true),
			dbConnection.FunctionRet.create(true),
			dbConnection.LuaExample.create(true),
			dbConnection.Struct.create(true),
			dbConnection.StructMember.create(true),
			dbConnection.GClass.create(true),
			dbConnection.Library.create(true),
			dbConnection.GEnum.create(true),
			dbConnection.GEnumMembers.create(true),
			dbConnection.GClassURL.create(true),
			dbConnection.Panel.create(true),
			dbConnection.PanelURL.create(true),
			dbConnection.Hook.create(true),
			dbConnection.HookURL.create(true),
			dbConnection.LibraryURL.create(true),
			dbConnection.LibraryField.create(true),
			dbConnection.Link_LibraryOwns.create(true),
			dbConnection.Link_GClassOwns.create(true),
			dbConnection.Link_HookOwns.create(true),
			dbConnection.Link_FunctionArgTypeResolve.create(true),
			dbConnection.Link_FunctionRetTypeResolve.create(true),
			dbConnection.Link_Category.create(true),
			dbConnection.PreviousURLSSeen.create(true) // dbConnection.Link_HaxeTypeCategory.create(true)
				// dbConnection.Link_ResolvedTypes.create(true)
		];
		return Promise.inParallel(databasePromises);
	}

	static function dropLinkageTables(dbConnection:data.WikiDB):Promise<Noise> {
		return dbConnection.Link_ResolvedTypes.drop()
			.flatMap(res -> {
				return dbConnection.Link_ResolvedTypes.create(true)
					.next(r -> {
						return dbConnection.Link_HaxeTypeCategory.drop()
							.flatMap(res -> {
								return dbConnection.Link_HaxeTypeCategory.create(true);
							});
					});
			});
	}

	static function linkMain(dbConnection:WikiDB) {
		var templates = new Templates.TemplatesDef();
		var generation = new Generation(templates);
		var performOps:PromiseArray<Noise> = new PromiseArray();
		performOps.add(dropLinkageTables(dbConnection));
		performOps.add(TypeLinker.addLuaTypes(dbConnection));
		performOps.add(TypeLinker.addGClasses(dbConnection));
		performOps.add(TypeLinker.addPanels(dbConnection));
		performOps.add(TypeLinker.typeFunctionArgs(dbConnection));
		performOps.add(TypeLinker.typeFunctionRets(dbConnection));
		performOps.add(TypeLinker.resolveLibraryOwns(dbConnection));
		performOps.add(TypeLinker.resolveGClassOwns(dbConnection));
		performOps.add(generation.readTypeCategories(dbConnection));
		performOps.add(generation.readExtraReturnInfo(dbConnection));
		performOps.add(generation.generateMultireturns(dbConnection));
		performOps.add(generation.writeGClasses(dbConnection));
		var p_operations = performOps.inSequence();
		p_operations.handle((results) -> {
			CommitArea.endOfRun();
			switch (results) {
				case Success(_):
					trace("linkMain/ all link ops performed successfully");
				case Failure(err):
					trace('linkMain/ ${err.toString()}');
			}
		});
	}

	static function existsWarc(find:String):String {
		return if (Fs.existsSync('$find$WARC_EXT')) {
			'$find$WARC_EXT';
		} else if (Fs.existsSync('$find$WARC_EXT_ZIPPED')) {
			'$find$WARC_EXT_ZIPPED';
		} else {
			null;
		}
	}

	static function findAvaliableWarcs():Array<String> {
		var avaliable = [];
		for (i in 1...100) {
			var resultExists = existsWarc('${WARC_NAME}_$i');
			if (resultExists != null) {
				avaliable.push(resultExists);
			} else {
				break;
			}
		}
		return avaliable;
	}

	// hmmmmm...?

	public static function main() {
		#if missingJson
		MissingJson.produceMissingJson();
		#else
		mainOthers();
		#end
	}

	public static function mainOthers() {
		#if (!linkage && !keepPrev)
		// if (Fs.existsSync("wikidb.sqlite")) {
		//     Fs.unlinkSync("wikidb.sqlite");
		// }
		#end
		var driver = new tink.sql.drivers.Sqlite(s -> "wikidb.sqlite");
		var dbConnection = new WikiDB("wiki_db", driver);
		createDBs(dbConnection).handle(_ -> {
			#if linkage
			linkMain(dbConnection);
			#elseif test
			var contentParser = Creation.contentParserTest();
			contentParser.parseTest(dbConnection)
				.handle(_ -> {});
			#else
			var contentParser = Creation.contentParser();
			trace(findAvaliableWarcs());
			for (warcFileName in findAvaliableWarcs()) {
				var warc = new WARCParser(Fs.createReadStream(warcFileName));
				parseWorker(dbConnection, warc, contentParser).handle((outcome) -> {
					switch (outcome) {
						case Success(_):
							linkMain(dbConnection);
							trace("Poggers completed");
						case Failure(failure):
							trace(failure.callStack);
							trace('grr failure $failure');
					}
				});
			}
			#end
		});
	}
}
