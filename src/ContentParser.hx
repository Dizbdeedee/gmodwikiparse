package;

import cheerio.lib.load.CheerioAPI;
import cheerio.lib.cheerio.Cheerio;
import node.Buffer;
import Main.WARCResult;
using tink.CoreApi;

class ContentParser {

	public function new () {}

	static var printonce = 0;

	static var functionID = 0;

	static var descID = 0;

	public function parse(content:WARCResult):Promise<Dynamic> {
		var readPromise = content.readFully().toPromise();
		readPromise.next(pparse).eager();
		return readPromise;

	}

	function pparse(data:WARCResult) {
		var jq = Cheerio.load(cast js.node.Buffer.from(data));
		var isFunc = jq.call(".function").is("*");

		if (isFunc) {
			parseFunction(data.warcTargetURI,jq);
		}
	}

	function parseFunction(url:String,jq:CheerioAPI):WikiDB.Function {
		var title = jq.call("h1#pagetitle.pagetitle").text();
		var isHook = jq.call(".hook").is("*");
		var isClient = jq.call(".realm-client").is("*");
		var isServer = jq.call(".realm-server").is("*");
		var isMenu = jq.call(".realm-menu").is("*");

		var funcNameReg = ~/[.:](.*)/;
		if (jq.call(".description_section").is("*")) {
		parseDescription(jq.call(".description_section"));
		}
		var funcStrip = funcNameReg.match(title);
		var funcName = if (funcStrip) {
			funcNameReg.matched(1);
		} else {
			title;
		}
		// trace(funcName);
		return {
			id : functionID++,
			name : funcName,
			url : url,
			description : -1,
			isHook : isHook,
			stateClient : isClient,
			stateServer : isServer,
			stateMenu : isMenu

		};
	}


	function parseChoose(nextNode:Cheerio<Dynamic>) {

	}

	function parseDescription(descNode:Cheerio<Dynamic>) {
		var firstElem = descNode.children().first();
		var p = descNode.children().first().is("p");
		var note = firstElem.is(".note");
		var warn = firstElem.is(".warning");
		var internal = firstElem.is(".internal");
		var bug = firstElem.is(".bug");
		var deprecated = firstElem.is(".deprecated");
		var removed = firstElem.is(".removed");
		switch [p,note,warn,internal,bug,deprecated,removed] {
			case [false,false,false,false,false,false,false]:
				trace(firstElem);
			default:

		}
		// var parsePara = descNode.children().get(0).is("p");
		// var parseNote = descNode.children().get(0).is(".note");
		// switch [parsePara,parseNote] {
		//	case [true,false]:
		//		trace("Paragraph");
		//		parseChoose(descNode.children().get(0).next());
		//	case [false,true]:
		//		trace("Note");
		//		parseChoose(descNode.children().get(0).next());
		//	default:
		//		trace("FAIL");
		// }

	}
}