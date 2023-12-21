package generators.standard;

import generators.desc.DescriptionParser;
import ParseUtil;
import generators.desc.UnresolvedDescription;

interface UnresolvedFunctionRetParse {
	function parse(jq:CheerioAPI):Array<UnresolvedFunctionRet>;
}

class UnresolvedFunctionRetParseDef implements UnresolvedFunctionRetParse {
	final descParser:DescriptionParser;

	public function new(_descParser:DescriptionParser) {
		descParser = _descParser;
	}

	public function parse(jq:CheerioAPI):Array<UnresolvedFunctionRet> {
		var funcRetNodeOpt = getOptCheer(jq, ".function_returns");
		return switch (funcRetNodeOpt) {
			case Some(funcRetNode):
				final funcRets = [];
				funcRetNode.children()
					.each((_, el) -> {
						var cheerEl = jq.call(el);
						funcRets.push(parseReturn(cheerEl, jq));
						return true;
					});
				funcRets;
			case None:
				[];
		}
	}

	function parseReturn(node:CheerioD, jq:CheerioAPI):UnresolvedFunctionRet {
		var typeNode = getChildCheer(node, "a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var returnNo = Std.parseInt(getChildCheer(node, "span.numbertag").text());
		var desc = getChildOptCheer(node, "div.numbertagindent");
		var unresolvedDesc:UnresolvedDescription = switch (desc) {
			case Some(descNode):
				descParser.parseDescNode(descNode, jq);
			case None:
				[];
		}
		return {
			returnNo: returnNo,
			typeURL: typeURL,
			type: type,
			description: unresolvedDesc
		}
	}
}

typedef UnresolvedFunctionRet = {
	var returnNo:Int;
	var type:String;
	var typeURL:String;
	var description:UnresolvedDescription;
}
