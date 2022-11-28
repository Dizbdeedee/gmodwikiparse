package generators.standard;

interface FunctionParser {
    function parseFunction(url:String,jq:CheerioAPI):Promise<WikiDB.FunctionCreation>;
}

@:await
class FunctionParserDef {

    public function new(descriptionParser:DescriptionParser) {

    }
    
    @:async function parseFunction(url:String,jq:CheerioAPI) {
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
                publishAndValidate(descNodes);
            default:
                Promise.resolve(null);
        }
        
        var luaExamples = @:await parseMultipleLuaExamples(jq);
        var func:WikiDB.Function = {
            id : null,
            name : funcName,
            url : url,
            description : descID,
            isHook : isHook,
            stateClient : isClient,
            stateServer : isServer,
            stateMenu : isMenu
        };
        return ({
            func : func,
            funcargs : funcArgsArr,
            funcrets : retsArr,
            luaexamples : luaExamples
        } : WikiDB.FunctionCreation);
    }


}