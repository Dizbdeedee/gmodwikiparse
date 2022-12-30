package generators.standard;
import CheerioAPI;
import generators.desc.UnresolvedDescription;
import ParseUtil;
import generators.desc.DescriptionParser;

interface UnresolvedFunctionParse {
    function parse(url:String,jq:CheerioAPI):UnresolvedFunction;
}

class UnresolvedFunctionParseDef implements UnresolvedFunctionParse {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    public function parse(url:String,jq:CheerioAPI):UnresolvedFunction {
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
        var descOpt = getOptCheer(jq,".description_section");
        var unDescription = switch (descOpt) {
            case Some(descNode):
                descParser.parseDescNode(descNode,jq);
            case None:
                [];
        }
        // descriptionResolver.setParse(descNode);
        return {
            name: funcName,
            url: url,
            description: unDescription,
            isHook: isHook,
            stateClient: isClient,
            stateServer: isServer,
            stateMenu: isMenu
        };
    }
}

typedef UnresolvedFunction = {
    // var id:Null<Id<Function>>;
    var name:String;
    var url:String;
    var description:UnresolvedDescription;
    var isHook:Bool;
    var stateClient:Bool;
    var stateMenu:Bool;
    var stateServer:Bool;


}