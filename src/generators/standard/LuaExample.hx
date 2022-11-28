package parsers.standard;

@:await
class LuaExampleParser {

    function parseMultipleLuaExamples(jq:CheerioAPI):Promise<Array<WikiDB.LuaExample>> {
        var examples = [];
        var exampleID = 0;
        jq.call("h2 + .example").each((_,el) -> {
            var cheerEl = jq.call(el);
            examples.push(parseLuaExample(cheerEl,exampleID++));
            return true;
        });
        return Promise.inSequence(examples);
    }
    
    @:async function parseLuaExample(node:Cheerio<Dynamic>,exampleID:Int) {
        var desc = getChildOptCheer(node,"div.description");
        var code = getChildCheer(node,"div.code");
        var output = getChildOptCheer(node,"div.output");
        // trace(node);
        var descID = @:await switch(desc) {
            case Some(descNode):
                var genDescs = descParser.parseDescNode(descNode);
                publishAndValidate(genDescs);
            default:
                trace("No description??");
                Promise.resolve(null);
        }
    
        var code = @:await {
            var genDescs = descParser.parseDescNode(code);
            publishAndValidate(genDescs);
        }
    
        var outputDescID = @:await switch (output) {
            case Some(outputNode):
                var genDescs = descParser.parseDescNode(outputNode);
                publishAndValidate(genDescs);
            default:
                trace("No output");
                Promise.resolve(null);
        }
        var luaexmp:WikiDB.LuaExample = {
            exampleNo : exampleID,
            funcid : null,
            desc : descID,
            output : outputDescID,
            code : code
        }
        return luaexmp;
    }
}

class LuaExamplePublisher {

}
