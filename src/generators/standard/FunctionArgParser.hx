package generators.standard;

interface FunctionArgParser {
    function parse(jq:CheerioAPI):Option<Array<UnresolvedFunctionArg>>;
}

class FunctionArgParserDef {

    public function new(descParser:DescriptionParser) {

    }

    public function parse(jq:CheerioAPI):Array<UnresvoledFunctionArg> {
        var funcArgsNode = getOptCheer(jq,".function_arguments");
        return switch (funcArgsNode) {
            case Some(funcArgsNode):
                parseMultipleFuncArgs(funcArgsNode);
            default:
                [];
        }
    }

   

    function parseMultipleFuncArgs(funcArgNode:Cheerio<Dynamic>):Promise<Array<FunctionArg>> {
        // return new Promise((success,failure) -> {
        var funcArgs:Array<Promise<FunctionArg>> = [];
        funcArgNode.children().each((_,el) -> {
            var cheerEl = ContentParser.jq.call(el);
            funcArgs.push(parseFuncArg(cheerEl));
            return true;
        });
        return Promise.inSequence(funcArgs);
    }
        
	@:async function parseFuncArg(node:Cheerio<Dynamic>) {
		var typeNode = getChildCheer(node,"a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var argumentNo = Std.parseInt(getChildCheer(node,"span.numbertag").text());
		var name = getChildCheer(node,"span.name").text();
		var desc = getChildCheer(node,"div.numbertagindent");
		var defResult = getChildOptCheer(node,"span.default");
		
        var descNodes = descParser.parseDescNode(desc);
			// if (descNodes.length > 0) {
			// 	publishAndValidate(descNodes);
			// } 
		
		// trace(results);
		// DescriptionParser.parseDescription(selectorDesc);
		final funcArg:FunctionArg = {
			argumentNo : argumentNo,
			typeURL : typeURL,
			type : type,
			name : name,
			description : descID,
			funcid : null,
			def : switch (defResult) {
				case Some(cheer):
					cheer.text();
				case None:
					null;
			}
		}
		return funcArg;
	}
}