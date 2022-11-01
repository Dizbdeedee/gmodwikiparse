package;

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

class ContentParser {

	public static var jq:CheerioAPI;

	final descParser = DescriptionParser2.makeDescParser2();

	public function new () {}


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
		// trace(parsedWarc.warcTargetURI);
		var isFunc = jq.call("div.function").length > 0;
		var isEnum = jq.call("div.enum").length > 0;
		var isStruct = jq.call("div.struct").length > 0;
		switch [isFunc,isEnum,isStruct] {
			case [false,false,false]:
				// trace(parsedWarc);
				trace('Unmatched... ${parsedWarc.warcTargetURI}');
			case [true,false,false]:
				parseFunction(parsedWarc.warcTargetURI,jq);
			case [false,true,false]:
				parseEnum(parsedWarc.warcTargetURI,jq);
			case [false,false,true]:
				parseStruct(parsedWarc.warcTargetURI,jq);
			default:
				trace("Multiple page types matched!!");
				trace(isFunc,isEnum,isStruct);
				
				// trace(data.warcTargetURI);
				throw "Multiple page types matched!!";

		}
		return Noise;
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

	function parseFunction(url:String,jq:CheerioAPI):WikiDB.Function {
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
		switch (descNode) {
			case Some(descNode):
				descParser.parseDescNode(descNode);
			default:
		}
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
		return {
			id : -1,
			name : funcName,
			url : url,
			description : -1,
			isHook : isHook,
			stateClient : isClient,
			stateServer : isServer,
			stateMenu : isMenu
		};
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
		trace(descParser.parseDescNode(code));
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


}