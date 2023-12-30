package typelink;

import haxe.io.Path;
import data.WikiDB;
import js.node.Fs;

using tink.CoreApi;

import Util.FutureArray;
import Util.PromiseArray;
import typelink.HaxeTypeCategories;

@:await class TypeLinker {
	static final LOCATION_LUATYPES = "luatypes";

	public function new() {}

	public static function addLuaTypes(dbConnection:data.WikiDB):Promise<Noise> {
		var processSQLProm = new PromiseArray();
		var readDir = Fs.readdirSync(LOCATION_LUATYPES);
		for (sqlFilename in readDir) {
			var sqlBuf = Fs.readFileSync(Path.join([LOCATION_LUATYPES, sqlFilename]));
			var sql = sqlBuf.toString();
			processSQLProm.add(dbConnection.__pool.executeSql(sql));
		}
		return processSQLProm.inSequence()
			.noise();
	}

	public static function addGClasses(dbConnection:data.WikiDB):Promise<Noise> {
		return dbConnection.GClass.all()
			.next((arr) -> {
				var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> = arr.map((gclass) -> {
					typeID: null,
					name: gclass.name,
					url: gclass.url,
					typeCategory: HaxeTypeCategories.gclass
				});
				return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
			});
	}

	public static function addPanels(dbConnection:data.WikiDB):Promise<Noise> {
		return dbConnection.Panel.all()
			.next((arr) -> {
				var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> = arr.map((panel) -> {
					typeID: null,
					name: panel.name,
					url: panel.url,
					typeCategory: HaxeTypeCategories.panel
				});
				return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
			});
	}

	@:async
	static function insertLibraryOwns(dbConnection:data.WikiDB, link:FunctionIDLibraryIDLink) {
		return @:await dbConnection.Link_LibraryOwns.insertOne({
			libraryID: link.libraryID,
			funcID: link.functionID
		});
	}

	static function getFunctionIDLibraryIDLink(dbConnection:data.WikiDB,
			libURL:data.WikiDB.LibraryURL):Future<Option<FunctionIDLibraryIDLink>> {
		var functionNext = (result) -> {
			return Some({functionID: result.functionID, libraryID: libURL.libraryID});
		}
		var functionRecover = (_) -> {
			trace('$libURL not found');
			return None;
		}
		return dbConnection.Function.select({
			functionID: Function.id
		})
			.where(Function.url == libURL.url)
			.first()
			.next(functionNext)
			.recover(functionRecover);
	}

	@:async public static function resolveLibraryOwns(dbConnection:data.WikiDB):Noise {
		var functionIDLibraryIDLinkFut = new FutureArray();
		var librariesInsertedProm = new PromiseArray();

		var libraryURLS = @:await dbConnection.LibraryURL.all();
		for (libURL in libraryURLS) {
			functionIDLibraryIDLinkFut.add(getFunctionIDLibraryIDLink(dbConnection, libURL));
		}
		var linksOptArr = @:await functionIDLibraryIDLinkFut.inSequence();
		for (linkOpt in linksOptArr) {
			switch (linkOpt) {
				case Some(link):
					librariesInsertedProm.add(insertLibraryOwns(dbConnection, link));
				default:
			}
		}
		var librariesInserted = @:await librariesInsertedProm.inSequence()
			.noise();
		return Promise.NOISE;
	}

	static function getFunctionIDGClassIDLink(dbConnection:data.WikiDB,
			gclassURL:data.WikiDB.GClassURL):Future<Option<FunctionIDGClassIDLink>> {
		var nextFunction = (res) -> {
			return Some({functionID: res.functionID, gclassID: gclassURL.gclassID});
		};
		var recoverFunction = (_) -> {
			trace('$gclassURL not found!!');
			return None;
		}
		return dbConnection.Function.select({
			functionID: Function.id
		})
			.where(Function.url == gclassURL.url)
			.first()
			.next(nextFunction)
			.recover(recoverFunction);
	}

	@:async
	static function insertGClassOwns(dbConnection:data.WikiDB, link:FunctionIDGClassIDLink) {
		var insertionGClassOwn = {
			gclassID: link.gclassID,
			funcID: link.functionID
		}
		return @:await dbConnection.Link_GClassOwns.insertOne({
			gclassID: link.gclassID,
			funcID: link.functionID
		});
	}

	@:async public static function resolveGClassOwns(dbConnection:data.WikiDB):Noise {
		var functionIDGClassIDLinkFut = new FutureArray();
		var gclassInsertedProm = new PromiseArray();

		var gclassURLArr = @:await dbConnection.GClassURL.all();
		for (gclassURL in gclassURLArr) {
			functionIDGClassIDLinkFut.add(getFunctionIDGClassIDLink(dbConnection, gclassURL));
		}
		var linksOptArr = @:await functionIDGClassIDLinkFut.inSequence();
		for (linkOpt in linksOptArr) {
			switch (linkOpt) {
				case Some(link):
					gclassInsertedProm.add(insertGClassOwns(dbConnection, link));
				default:
			}
		}
		var gClassInserted = @:await gclassInsertedProm.inSequence();
		return Promise.NOISE;
	}

	static function insertHookOwns(dbConnection:data.WikiDB, link:FunctionIDHookIDLink) {
		return null;
	}

	static function getFunctionIDHookIDLink(dbConnection:data.WikiDB,
			hookURL:data.WikiDB.HookURL):Future<Option<FunctionIDHookIDLink>> {
		return null;
	}

	@:async public static function resolveHookOwns(dbConnection:data.WikiDB):Noise {
		var processResultsHookURLLinkage = new FutureArray();
		var processHooksInserted = new PromiseArray();

		var hookURLS = @:await dbConnection.HookURL.all();
		for (hookURL in hookURLS) {
			processResultsHookURLLinkage.add(getFunctionIDHookIDLink(dbConnection, hookURL));
		}
		var resultsHookURLLinkage = @:await processResultsHookURLLinkage.inSequence();
		for (hookUrlLinkage in resultsHookURLLinkage) {
			switch (hookUrlLinkage) {
				case Some(link):
					processHooksInserted.add(insertHookOwns(dbConnection, link));
				default:
			}
		}
		var resultsHooksInserted = @:await processHooksInserted.inSequence();
		return Promise.NOISE;
	}

	@:async public static function typeFunctionArgs(dbConnection:data.WikiDB):Noise {
		var pa_linkFunctionArgs:FutureArray<Option<ItemAndType>> = new FutureArray();

		var allFunctionArgs = @:await dbConnection.FunctionArg.all();
		for (functionArg in allFunctionArgs) {
			pa_linkFunctionArgs.add(linkFunctionArgToType(functionArg, dbConnection));
		}
		var linkedFunctionArgs = @:await pa_linkFunctionArgs.inSequence();
		var manyFuncArgType:Array<data.WikiDB.Link_FunctionArgTypeResolve> = [];
		for (itemAndTypeRes in linkedFunctionArgs) {
			switch (itemAndTypeRes) {
				case Some({typeID: typeID, itemID: funcArgID}):
					manyFuncArgType.push({funcArgNo: funcArgID, typeID: typeID});
				default:
			}
		}
		return @:await dbConnection.Link_FunctionArgTypeResolve.insertMany(manyFuncArgType)
			.noise();
	}

	@:async public static function typeFunctionRets(dbConnection:data.WikiDB):Noise {
		var pa_linkFunctionRets:FutureArray<Option<ItemAndType>> = new FutureArray();
		var allFunctionRets = @:await dbConnection.FunctionRet.all();
		for (functionRet in allFunctionRets) {
			pa_linkFunctionRets.add(linkFunctionRetToType(functionRet, dbConnection));
		}
		var linkedFunctionRetsArr = @:await pa_linkFunctionRets.inSequence();
		var manyFunctionRetType:Array<data.WikiDB.Link_FunctionRetTypeResolve> = [];
		for (linkedFunctionRet in linkedFunctionRetsArr) {
			switch (linkedFunctionRet) {
				case Some({typeID: typeID, itemID: funcRetID}):
					manyFunctionRetType.push({funcRetID: funcRetID, typeID: typeID});
				default:
			}
		}
		return @:await dbConnection.Link_FunctionRetTypeResolve.insertMany(manyFunctionRetType)
			.noise();
	}

	static function linkFunctionArgToType(funcArg:data.WikiDB.FunctionArg,
			dbConnection:data.WikiDB):Future<Option<ItemAndType>> {
		var nextResolvedType:(result:data.WikiDB.Link_ResolvedTypes) -> Option<ItemAndType>;
		nextResolvedType = (result) -> {
			return Some({typeID: result.typeID, itemID: funcArg.id});
		}
		var recoverResolvedType = (err) -> {
			trace('Unmatched funcArg: ${funcArg.typeURL}');
			return None;
		}
		return dbConnection.Link_ResolvedTypes.where(funcArg.typeURL == Link_ResolvedTypes.url)
			.first()
			.next(nextResolvedType)
			.recover(recoverResolvedType);
	}

	static function linkFunctionRetToType(funcRet:data.WikiDB.FunctionRet,
			dbConnection:data.WikiDB):Future<Option<ItemAndType>> {
		var nextResolvedType:(result:data.WikiDB.Link_ResolvedTypes) -> Option<ItemAndType>;
		nextResolvedType = (result) -> {
			return Some({typeID: result.typeID, itemID: funcRet.id});
		}
		var recoverResolvedType = (err) -> {
			trace('Unmatched funcRet: ${funcRet.typeURL}');
			return None;
		}
		return dbConnection.Link_ResolvedTypes.where(funcRet.typeURL == Link_ResolvedTypes.url)
			.first()
			.next(nextResolvedType)
			.recover(recoverResolvedType);
	}
}

typedef ItemAndType = {
	itemID:Int,
	typeID:Int
}

typedef FunctionIDHookIDLink = {
	itemID:Int,
	typeID:Int
}

typedef FunctionIDLibraryIDLink = {
	functionID:Int,
	libraryID:Int
}

typedef FunctionIDGClassIDLink = {
	functionID:Int,
	gclassID:Int
}
