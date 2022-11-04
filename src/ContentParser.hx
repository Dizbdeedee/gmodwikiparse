package;

import WikiDB.DescItem;
import WikiDB.DescriptionStorage;
import tink.sql.Types;
import tink.sql.Database;
import WikiDB.FunctionArg;
import js.lib.Uint8Array;
import cheerio.lib.load.CheerioAPI;
import cheerio.lib.cheerio.Cheerio;
import node.Buffer;
import Main.WARCResult;
using tink.CoreApi;

typedef WarcData = {
	url : String,
	buff : Dynamic
}

@:await
class ContentParser {

	public static var jq:CheerioAPI;

	final descParser = DescriptionParser.makeDescParser2();

	final dbConnection:WikiDB;

	public function new (_dbConnection:WikiDB) {
		dbConnection = _dbConnection;
	}


	public function parse(content:WARCResult):Promise<Noise> {
		if (content.warcType != "response") {
			return Promise.resolve(Noise);
		}
		var readPromise = content.readFully().toPromise();
		var handledPromise = readPromise.next((data) -> loadHTML(content));
		// readPromise.next(loadHTML).eager();
		return handledPromise.noise();

	}

	function loadHTML(parsedWarc:WARCResult) {
		jq = Cheerio.load(cast node.buffer.Buffer.from(parsedWarc.payload));
		var isFunc = jq.call("div.function").length > 0;
		var isEnum = jq.call("div.enum").length > 0;
		var isStruct = jq.call("div.struct").length > 0;
		var prom:Promise<Noise> = switch [isFunc,isEnum,isStruct] {
			case [false,false,false]:
				// trace(parsedWarc);
				trace('Unmatched... ${parsedWarc.warcTargetURI}');
				Noise;
			case [true,false,false]:
				parseFunction(parsedWarc.warcTargetURI,jq).noise();
			case [false,true,false]:
				Promise.resolve(parseEnum(parsedWarc.warcTargetURI,jq));
			case [false,false,true]:
				Promise.resolve(parseStruct(parsedWarc.warcTargetURI,jq));
			default:
				trace("Multiple page types matched!!");
				trace(isFunc,isEnum,isStruct);
				
				// trace(data.warcTargetURI);
				throw "Multiple page types matched!!";

		}
		
		return prom;
	}

	function toBool(select:Option<Dynamic>) {
		return switch(select) {
			case Some(_):
				true;
			case None:
				false;
		}
	}

	function parseStruct(url:String,jq:CheerioAPI):WikiDB.Struct {
		return null;
	}

	function parseEnum(url:String,jq:CheerioAPI):WikiDB.GEnum {
		var title = getCheer(jq,"h1#pagetitle.pagetitle").text();
		var desc = getCheer(jq,".function_description");
		var enums = getCheer(jq,"h1 + table > tbody");
		trace(enums);
		return null;
	}

	@:async function parseFunction(url:String,jq:CheerioAPI):WikiDB.Function {
		var title = getCheer(jq,"h1#pagetitle.pagetitle").text();
		var isHook = toBool(getOptCheer(jq,".hook"));
		var isClient = toBool(getOptCheer(jq,".realm-client"));
		var isServer = toBool(getOptCheer(jq,".realm-server"));
		var isMenu = toBool(getOptCheer(jq,".realm-menu"));
		var funcNameReg = ~/[.:](.*)/;
		var funcName = if (funcNameReg.match(title)) {
			funcNameReg.matched(1);
		} else {
			title;
		}
		trace(funcName);
		var descNode = getOptCheer(jq,".description_section");
		var descID = @:await switch (descNode) {
			case Some(descNode):
				var descNodes = descParser.parseDescNode(descNode);
				publishDescToDB(descNodes);
			default:
				null;
		}
		trace(descID);
		var funcArgsNode = getOptCheer(jq,".function_arguments");
		switch (funcArgsNode) {
			case Some(funcArgsNode):
				parseMultipleFuncArgs(funcArgsNode);
			default:

		}
		var retNode = getOptCheer(jq,".function_returns");
		switch (retNode) {
			case Some(retNode):
				parseMultipleReturns(retNode);
			default:
		}
		parseMultipleLuaExamples(jq);
		return ({
			id : -1,
			name : funcName,
			url : url,
			description : -1,
			isHook : isHook,
			stateClient : isClient,
			stateServer : isServer,
			stateMenu : isMenu
		} : WikiDB.Function);
	}

	// and verify
	function getCheer(jq:CheerioAPI,select:String):Cheerio<Dynamic> {
		var cheer = jq.call(select);
		try {
			verifySelector(cheer);
		} catch (e) {
			trace(select);
			throw e;
		}
		return cheer;
	}

	//and verify
	function getOptCheer(jq:CheerioAPI,select:String):Option<Cheerio<Dynamic>> {
		var cheer = jq.call(select);
		verifyOptionalSelector(cheer);
		return if (cheer.length > 0) {
			Some(cheer);
		} else {
			None;
		};
	}

	function getChildCheer(node:Cheerio<Dynamic>,select:String):Cheerio<Dynamic> {
		var cheer = node.children(select);
		verifySelector(cheer);
		return cheer;
	}

	function getChildOptCheer(node:Cheerio<Dynamic>,select:String):Option<Cheerio<Dynamic>> {
		var cheer = node.children(select);
		verifyOptionalSelector(cheer);
		return if (cheer.length > 0) {
			Some(cheer);
		} else {
			None;
		};
	}

	function verifySelector(node:Cheerio<Dynamic>) {
		if (node.length > 1) {
			trace("Too many selected!");
			trace(node);
			throw node;
		} else if (node.length < 1) {
			trace("Not enough selected!");
			trace(node);
			throw new haxe.Exception("Not enough selected!");
		}
	}

	function verifyOptionalSelector(node:Cheerio<Dynamic>) {
		if (node.length > 1) {
			trace("Too many selected!");
			trace(node);
			throw node;
		}
	}

	function parseMultipleLuaExamples(jq:CheerioAPI) {
		jq.call("h2 + .example").each((_,el) -> {
			var cheerEl = jq.call(el);
			parseLuaExample(cheerEl);
			return true;
		});
	}

	function parseLuaExample(node:Cheerio<Dynamic>) {
		var desc = getChildOptCheer(node,"div.description");
		var code = getChildCheer(node,"div.code");
		var output = getChildOptCheer(node,"div.output");
		// trace(node);
		switch(desc) {
			case Some(descNode):
				descParser.parseDescNode(descNode);
			default:
				trace("No description??");
		}
		// trace(descParser.parseDescNode(code));
		switch (output) {
			case Some(outputNode):
				descParser.parseDescNode(outputNode);
			default:
				trace("No output");
		}

	}

	function parseMultipleFuncArgs(funcArgs:Cheerio<Dynamic>) {
		funcArgs.children().each((_,el) -> {
			var cheerEl = ContentParser.jq.call(el);
			parseFuncArg(cheerEl);
			return true;
		});
		// var curNode:Cheerio<Dynamic> = funcArgs.children();
		// while (curNode.length > 0) {
		// 	curNode = parseFuncArg(curNode);
		// }
	}

	function parseMultipleReturns(rets:Cheerio<Dynamic>) {
		rets.children().each((_,el) -> {
			var cheerEl = ContentParser.jq.call(el);
			parseReturn(cheerEl);
			return true;
		});
	}

	function parseReturn(node:Cheerio<Dynamic>) {
		var typeNode = getChildCheer(node,"a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var returnNo = Std.parseInt(getChildCheer(node,"span.numbertag").text());
		var desc = getChildOptCheer(node,"div.numbertagindent");
		var results = switch (desc) {
			case Some(descNode):
				descParser.parseDescNode(descNode);
			case None:
				null;
		}
		var funcRet:WikiDB.FunctionRet = {
			returnNo : returnNo,
			typeURL : typeURL,
			type : type,
			desc : -1,
			funcid : -1
		}
		// trace(funcRet);
	}

	function parseFuncArg(node:Cheerio<Dynamic>) {
		var typeNode = getChildCheer(node,"a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var argumentNo = Std.parseInt(getChildCheer(node,"span.numbertag").text());
		var name = getChildCheer(node,"span.name").text();
		var desc = getChildCheer(node,"div.numbertagindent");
		var defResult = getChildOptCheer(node,"span.default");
		var results = descParser.parseDescNode(desc);
		// trace(results);
		// DescriptionParser.parseDescription(selectorDesc);
		var created:FunctionArg = {
			argumentNo : argumentNo,
			typeURL : typeURL,
			type : type,
			name : name,
			description : -1,
			funcid : -1,
			def : switch (defResult) {
				case Some(cheer):
					cheer.text();
				case None:
					null;
			}

		}
	}

	function giveDescItemsIDs(arr:Array<DescItem>,maxIndex:Int):Promise<Array<Id<DescItem>>> {
		var nextID = maxIndex + 1;
		var insertionDescriptions = arr.map((desc) -> {
			// untyped desc.id = nextID++;
			return dbConnection.DescItem.insertOne({
				id : nextID++,
				type : desc.type,
				textValue : desc.textValue
			});
		});
		return Promise.inSequence(insertionDescriptions);
	}

	function getMaxID() {
		return dbConnection.DescItem.select({
			id : tink.sql.expr.Functions.max(DescItem.id)
		}).first().next((result) -> result.id);
	}

	function assignFirstDescriptionStorage(initial:Id<DescItem>) {
		return dbConnection.DescriptionStorage.insertOne({
			id : -1,
			descItem : initial
		}).next((autoDescStoreID) -> {
			dbConnection.DescriptionStorage.update((ds) -> [ds.id.set(autoDescStoreID)],{
				where : (ds) -> ds.id == -1
			}).next(_ -> autoDescStoreID);
		});
	}

	function createDescriptionStorages(descItemIDSS:Array<Id<DescItem>>):Promise<Id<DescriptionStorage>> {
		return assignFirstDescriptionStorage(descItemIDSS[0]).next((autoID) -> {
			var process:Array<DescriptionStorage> = descItemIDSS.slice(1)
			.map((descItemID) -> 
				{
					id : autoID,
					descItem : descItemID
				}
			);
			return dbConnection.DescriptionStorage.insertMany(process).next(_ -> autoID);
		});
	}

	function publishDescToDB(arr:Array<DescItem>):Promise<Id<DescriptionStorage>> {
		return getMaxID()
		.next((maxID) -> giveDescItemsIDs(arr,maxID)
			.next(createDescriptionStorages));
	}

	


}
