package;

import tink.sql.Expr;

using tink.CoreApi;

import Util.PromiseArray;
import js.node.Fs;
import haxe.Template;
import haxe.io.Path;
import typelink.HaxeTypeCategories;
import StringBuf;
import Assert.assert;

@:await class Generation {
	static final LOCATION_LOCATIONS = "locations";
	static final LOCATION_TRANSFORMATIONS = "transformations";
	static final LOCATION_HAXETYPECATEGORIES = "haxetypecategories";
	static final LOCATION_EXTRARETURNINFO = "extras";
	static final LOCATION_OUT = "out";

	static final HEAD_PREFIX = "gmod_";
	static final HEAD_CLIENT = '#if ${HEAD_PREFIX}client';
	static final HEAD_SERVER = '#if ${HEAD_PREFIX}server';
	static final HEAD_MENU = '#if ${HEAD_PREFIX}menu';

	final templates:Templates;

	public function new(_templates:Templates) {
		templates = _templates;
	}

	@:async public function readTypeCategories(dbConnection:data.WikiDB):Noise {
		var processSQLProm = new PromiseArray();
		var readDir = Fs.readdirSync(LOCATION_HAXETYPECATEGORIES);
		for (sqlFileName in readDir) {
			var sqlBuf = Fs.readFileSync(Path.join([LOCATION_HAXETYPECATEGORIES, sqlFileName]));
			var sql = sqlBuf.toString();
			processSQLProm.add(dbConnection.__pool.executeSql(sql));
		}
		var awaitResult = @:await processSQLProm.inSequence()
			.noise();
		return Noise;
	}

	@:async public function readExtraReturnInfo(dbConnection:data.WikiDB):Array<Noise> {
		var pa_processSQLS = new PromiseArray();
		var readDir = Fs.readdirSync(LOCATION_EXTRARETURNINFO);
		pa_processSQLS.add(dbConnection.__pool.executeSql("PRAGMA temp_store = 2"));
		pa_processSQLS.add(dbConnection.__pool.executeSql("DROP TABLE IF EXISTS VARS;CREATE TEMP TABLE VARS(Name Text PRIMARY KEY, Val INTEGER);"));
		for (sqlFileName in readDir) {
			var sqlBuf = Fs.readFileSync(Path.join([LOCATION_EXTRARETURNINFO, sqlFileName]));
			var sql = sqlBuf.toString();
			pa_processSQLS.add(dbConnection.__pool.executeSql(sql)
				.recover((e) -> {
					trace('readExtraReturnInfo/ Could not process $sqlFileName. Extra info maybe below');
					trace(e);
					return Noise;
				}));
		}
		return @:await pa_processSQLS.inSequence();
	}

	@:async public function writeGClasses(dbConnection:data.WikiDB) {
		var allGClassProcessProm = new PromiseArray();
		var allGClass = @:await dbConnection.GClass.all();
		for (gclass in allGClass) {
			allGClassProcessProm.add(processGClass(dbConnection, gclass));
		}
		var awaitResult = @:await allGClassProcessProm.inSequence();
		return Noise;
	}

	@:async public function writeAllLibraries(dbConnection:data.WikiDB) {
		var allLibrariesProcessProm = new PromiseArray();
		var allLibraries = @:await dbConnection.Library.all();
		for (library in allLibraries) {
			allLibrariesProcessProm.add(processLibrary(dbConnection, library));
		}
		var awaitResult = @:await allLibrariesProcessProm.inSequence();
		return Noise;
	}

	@:async function processGClass(dbConnection:data.WikiDB, gclass:data.WikiDB.GClass) {
		var allFunctionsProm:PromiseArray<data.WikiDB.Function> = new PromiseArray();
		var generatedFunctionsProm:PromiseArray<PreGeneratedFunction> = new PromiseArray();
		var linksArr = @:await dbConnection.Link_GClassOwns.where(Link_GClassOwns.gclassID == gclass.id)
			.all();
		if (linksArr.length == 0) {
			trace('processGClass/Missing link_gclassowns');
			return Noise;
		}
		for (link in linksArr) {
			allFunctionsProm.add(dbConnection.Function.where(Function.id == link.funcID)
				.first());
		}
		var allFunctionsArr = @:await allFunctionsProm.inSequence();
		if (allFunctionsArr.length == 0) {
			trace('processGClass/Missing functions');
			return Noise;
		}
		for (func in allFunctionsArr) {
			if (func != null) {
				generatedFunctionsProm.add(generateFunction(dbConnection, func));
			} else {
				trace("null func");
			}
		}
		var manyPregenFuncs = @:await generatedFunctionsProm.inSequence();
		var tabWidth = 2;
		var partialContent:StringBuf = new StringBuf();
		for (pregenFunc in manyPregenFuncs) {
			var f = pregenFunc.func;
			var beginHeader = switch [f.stateClient, f.stateMenu, f.stateServer] {
				case [false, false, false]:
					trace("processGClass// NO STATE");
					throw new haxe.Exception("processGClass// NO STATE");
				case [true, false, false]:
					"#if gmclient";
				case [false, false, true]:
					"#if gmserver";
				case [true, false, true]:
					"#if gmgame";
				case [true, true, false]:
					"#if (gmclient || gmmenu)";
				case [true, true, true]:
					"#if gm";
				default:
					trace("processGClass// UNMATCHED STATE");
					throw new haxe.Exception("processGClass// UNMATCHED STATE");
			}
			var endHeader = "#end";
			var templateData = {
				beginHeader: beginHeader,
				comment: "//ye",
				isPrivate: "",
				funcName: f.name,
				endHeader: endHeader,
				varList: pregenFunc.varList,
				typeOutput: pregenFunc.typeOutput
			};
			if (f.description != null) {
				// @:await renderText(dbConnection,f.description);
			}
			var str = templates.gclassFunctionTemplate.execute(templateData);
			partialContent.add(str);
		}
		var allPartialContent = partialContent.toString();
		var templateData = {
			allPartialContent: allPartialContent,
			gclassName: gclass.name,
			comment: "",
			beginHeader: "#if gm",
			endHeader: "#end"
		}
		var str = templates.gclassTemplate.execute(templateData);
		Fs.writeFileSync("wat/" + gclass.name + ".hx", str);
		return Noise;
	}

	@:async function renderText(dbConnection:data.WikiDB, descID:Int) {
		var description:Array<Dynamic> = @:await
			dbConnection.DescriptionStorage.join(dbConnection.DescItem)
				.on(DescItem.id == DescriptionStorage.descItem) // DEFER no dynamic
				.where((descStorage, descItem) -> descStorage.id == descID)
				.all();
		var strBuf = new StringBuf();
		for (d in description) {
			var descItemType:data.WikiDB.DescItemType = d.descItem.type;
			switch (descItemType) {
				case DESCRIPTION:
					strBuf.add(d.descItem.textValue);
				case DESCRIPTION_BREAK_BELOW:
					strBuf.add("\n");
				default:
			}
		}
		return strBuf.toString();
	}

	@:async function processLibrary(dbConnection:data.WikiDB, library:data.WikiDB.Library):Noise {
		var allFunctionsProm = new PromiseArray();
		var generatedFunctionsProm = new PromiseArray();
		var linksArr = @:await dbConnection.Link_LibraryOwns.where(Link_LibraryOwns.libraryID == library.id)
			.all();
		assert(linksArr.length > 0);
		for (link in linksArr) {
			allFunctionsProm.add(dbConnection.Function.where(Function.id == link.funcID)
				.first());
		}
		var allFunctionsArr = @:await allFunctionsProm.inSequence();
		for (func in allFunctionsArr) {
			generatedFunctionsProm.add(generateFunction(dbConnection, func));
		}
		var results = @:await generatedFunctionsProm.inSequence();
		return Noise;
	}

	function genPromiseGroupFuncAndRet(dbConnection:data.WikiDB,
			selectMultipleRetsResult:SelectMultipleRetsResult):Promise<GroupedFuncAndRet> {
		var functionRets = dbConnection.FunctionRet.where
			(FunctionRet.funcid == selectMultipleRetsResult.funcid)
			.all();
		var functionRetsWithRetInfo = functionRets.next((manyRets) -> {
			var pa_FunctionRetsWithRetInfo = new PromiseArray();
			for (ret in manyRets) {
				pa_FunctionRetsWithRetInfo.add(lookupReturnInfo(dbConnection, ret));
			}
			return pa_FunctionRetsWithRetInfo.inSequence();
		});
		var functions = dbConnection.Function.where(Function.id == selectMultipleRetsResult.funcid)
			.first();
		var both = functionRetsWithRetInfo && functions;
		return both.next((pair) -> {
			rets: pair.a,
			func: pair.b
		});
	}

	@:async public function generateMultireturns(dbConnection:data.WikiDB):Noise {
		var funcsWithMultipleRets:Array<SelectMultipleRetsResult> = @:await dbConnection.FunctionRet.join
			(dbConnection.Function)
			.on(FunctionRet.funcid == Function.id)
			.select({
				cnt: Functions.count(FunctionRet.funcid),
				funcid: FunctionRet.funcid
			})
			.groupBy((fields) -> return [fields.FunctionRet.funcid])
			.having((funcRet, func) -> return Functions.count(funcRet.funcid) > 1)
			.all();
		assert(funcsWithMultipleRets.length > 0);
		// could complicate this a little - but no need. Just keep it simple
		var pa_manyGroupedFuncRets:PromiseArray<GroupedFuncAndRet> = new PromiseArray();
		for (selectMultipleRetsResult in funcsWithMultipleRets) {
			pa_manyGroupedFuncRets.add(genPromiseGroupFuncAndRet(dbConnection, selectMultipleRetsResult));
		}
		var manyGroupedFuncRets = @:await pa_manyGroupedFuncRets.inSequence();
		assert(manyGroupedFuncRets.length > 0);
		for (groupedRetsAndFunc in manyGroupedFuncRets) {
			for (ret in groupedRetsAndFunc.rets) {}
		}
		var partialContent:String;
		return Noise;
	}

	@:async function lookupReturnInfo(dbConnection:data.WikiDB,
			funcRet:data.WikiDB.FunctionRet):RetWithExtraInfo {
		var retInfo = @:await dbConnection.Extra_ReturnInfo.where(Extra_ReturnInfo.funcRetID == funcRet.id)
			.all();
		assert(retInfo.length <= 1);
		return if (retInfo.length == 0) {
			{
				name: None,
				ret: funcRet
			}
		} else {
			{
				name: Some(retInfo[0].assignedName),
				ret: funcRet
			}
		}
	}

	@:async function generateFunction(dbConnection:data.WikiDB,
			func:data.WikiDB.Function):PreGeneratedFunction {
		var pa_pregenFuncArgs:PromiseArray<Option<PreGeneratedFuncArg>> = new PromiseArray();
		var pa_preGenFuncRets:PromiseArray<Option<String>> = new PromiseArray();
		var funcArgs = @:await dbConnection.FunctionArg.where(FunctionArg.funcid == func.id)
			.all();
		var funcRets = @:await dbConnection.FunctionRet.where(FunctionRet.funcid == func.id)
			.all();
		for (funcArg in funcArgs) {
			pa_pregenFuncArgs.add(preGenerateFuncArg(dbConnection, funcArg));
		}
		for (funcRet in funcRets) {
			pa_preGenFuncRets.add(preGenerateFuncRet(dbConnection, funcRet));
		}
		var preGenFuncArgsArr = @:await pa_pregenFuncArgs.inSequence();
		var lenFuncArgs = preGenFuncArgsArr.length;
		var varListBuilder = new StringBuf();
		for (i in 0...lenFuncArgs) {
			switch (preGenFuncArgsArr[i]) {
				case None:
					continue;
				case Some(itemandtype):
					var partialStr = if (i == lenFuncArgs - 1) {
						templates.funcArgEndTemplate.execute(itemandtype);
					} else {
						templates.funcArgTemplate.execute(itemandtype);
					}
					varListBuilder.add(partialStr);
			}
		}
		var varList = varListBuilder.toString();
		var preGenFuncRets = @:await pa_preGenFuncRets.inSequence();
		var lenPreGenFuncRets = preGenFuncRets.length;
		var typeOutput:String = if (lenPreGenFuncRets > 1) {
			for (i in 0...lenPreGenFuncRets) {}
			"GenerateAMultiReturn"; // lookup saved multireturn
		} else if (lenPreGenFuncRets == 1) {
			switch (preGenFuncRets[0]) {
				case Some(typstr):
					typstr;
				default:
					trace("generateFunction/ret/ ERROR");
					"ERROR";
			}
		} else {
			"Void";
		}
		return {varList: varList, typeOutput: typeOutput, func: func};
	}

	@:async function preGenerateFuncArg(dbConnection:data.WikiDB,
			funcArg:data.WikiDB.FunctionArg):Option<PreGeneratedFuncArg> {
		var typeLink:data.WikiDB.Link_FunctionArgTypeResolve;
		var type:data.WikiDB.Link_ResolvedTypes;
		try {
			typeLink = @:await dbConnection.Link_FunctionArgTypeResolve.where
				(Link_FunctionArgTypeResolve.funcArgNo == funcArg.id)
				.first();
			type = @:await dbConnection.Link_ResolvedTypes.where
				(Link_ResolvedTypes.typeID == typeLink.typeID)
				.first();
		} catch (e) {
			return None;
		}
		var typeNameCanoc = @:await processTypeName(dbConnection, type.name, type.typeCategory);
		return Some({
			varName: funcArg.name,
			type: typeNameCanoc
		});
	}

	@:async function preGenerateFuncRet(dbConnection:data.WikiDB,
			funcRet:data.WikiDB.FunctionRet):Option<String> {
		var typeLink:data.WikiDB.Link_FunctionRetTypeResolve;
		var type:data.WikiDB.Link_ResolvedTypes;
		try {
			typeLink = @:await dbConnection.Link_FunctionRetTypeResolve.where
				(Link_FunctionRetTypeResolve.funcRetID == funcRet.id)
				.first();
			type = @:await dbConnection.Link_ResolvedTypes.where
				(Link_ResolvedTypes.typeID == typeLink.typeID)
				.first();
		} catch (e) {
			trace('preGenerateFuncRet/ Can"t lookup type properly for $funcRet');
			return None;
		}
		var typeNameCanoc = @:await processTypeName(dbConnection, type.name, type.typeCategory);
		return Some(typeNameCanoc);
	}

	@:async function processTypeName(dbConnection:data.WikiDB, typeName:String, typeCat:Int):String {
		var typeCategory = @:await dbConnection.Link_HaxeTypeCategory.where
			(Link_HaxeTypeCategory.id == typeCat)
			.first();
		return switch (typeCategory) {
			case {isReplacement: false, location: loc}:
				'$loc$typeName';
			case {isReplacement: true, location: newType}:
				newType;
		}
	}
}

enum DisplayType {
	NoMenu;
	Menu;
}

typedef GeneratedLibrary = {
	beginHeader:String,
	allPartialContent:String,
	libraryName:String,
	endHeader:String
}

typedef GeneratedGClass = {
	comment:String,
	beginHeader:String,
	allPartialContent:String,
	gclassName:String,
	endHeader:String
}

typedef GeneratedGClassFunction = {
	beginHeader:String,
	isPrivate:String,
	funcName:String,
	varList:String,
	typeOutput:String,
	endHeader:String
}

typedef GeneratedLibraryFunction = {
	beginHeader:String,
	funcName:String,
	varList:String,
	typeOutput:String,
	endHeader:String
}

typedef PreGeneratedLibrary = {
	beginHeader:String,
	allPartialContent:Array<PreGeneratedLibraryFunction>,
	libraryName:String,
	endHeader:String
}

typedef PreGeneratedGClass = {
	beginHeader:String,
	allPartialContent:Array<PreGeneratedGClassFunction>,
	libraryName:String,
	endHeader:String
}

typedef PreGeneratedGClassFunction = {
	beginHeader:String,
	isPrivate:String,
	funcName:String,
	varList:String,
	typeOutput:String,
	endHeader:String,
}

typedef PreGeneratedFunction = {
	varList:String,
	typeOutput:String,
	func:data.WikiDB.Function
}

typedef PreGeneratedLibraryFunction = {
	beginHeader:String,
	funcName:String,
	varList:String,
	typeOutput:String,
	endHeader:String
}

typedef PreGeneratedFuncArg = {
	varName:String,
	type:String
}

typedef GroupedFuncAndRet = {
	rets:Array<RetWithExtraInfo>,
	func:data.WikiDB.Function
}

typedef RetWithExtraInfo = {
	name:Option<String>,
	ret:data.WikiDB.FunctionRet
}

typedef SelectMultipleRetsResult = {
	var cnt(default, never):Int;
	var funcid(default, never):Int;
}
