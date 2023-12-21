package generators.standard;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionParser;
import ParseUtil;

interface UnresolvedFunctionArgParse {
	function parse(jq:CheerioAPI):Array<UnresolvedFunctionArg>;
}

class UnresolvedFunctionArgParseDef implements UnresolvedFunctionArgParse {
	final descParser:DescriptionParser;

	public function new(_descParser:DescriptionParser) {
		descParser = _descParser;
	}

	public function parse(jq:CheerioAPI):Array<UnresolvedFunctionArg> {
		var funcArgsNodeOpt = getOptCheer(jq, ".function_arguments");
		return switch (funcArgsNodeOpt) {
			case Some(funcArgNode):
				var funcArgs:Array<UnresolvedFunctionArg> = [];
				funcArgNode.children()
					.each((_, el) -> {
						var cheerEl = jq.call(el);
						funcArgs.push(parseFuncArg(cheerEl, jq));
						return true;
					});
				funcArgs;
			default:
				[];
		}
	}

	function parseFuncArg(node:CheerioD, jq:CheerioAPI):UnresolvedFunctionArg {
		var typeNode = getChildCheer(node, "a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var argumentNo = Std.parseInt(getChildCheer(node, "span.numbertag").text());
		var name = getChildCheer(node, "span.name").text();
		var desc = getChildCheer(node, "div.numbertagindent");
		var defResult = getChildOptCheer(node, "span.default");
		var descNodes = descParser.parseDescNode(desc, jq);
		return {
			argumentNo: argumentNo,
			typeURL: typeURL,
			type: type,
			name: name,
			description: descNodes,
			def: switch (defResult) {
				case Some(cheer):
					cheer.text();
				case None:
					null;
			}
		};
	}
}

typedef UnresolvedFunctionArg = {
	var argumentNo:Int;
	var name:String;
	var type:String;
	var typeURL:String;
	var ?def:String;
	var description:UnresolvedDescription;
}
