package generators.standard;

interface FunctionParser {
    function parseFunction(url:String,jq:CheerioAPI):UnresolvedFunction;
}

@:await
class FunctionParserDef {

    final descriptionResolver:DescriptionResolver;

    public function new(_descriptionResolver:DescriptionResolver) {
        descriptionResolver = _descriptionResolver;
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
        new DescriptionResolver()
        descriptionResolver.setParse(descNode);
        return {
            name: funcName,
            url: url,
            description:
        }
    }


}

//DescriptionResolver: we need a factory. But I don't want to call it a factory. It doesn't describe itself in that way. A factory doesn't mean anything and raises questions on what creating a new original object actually does
//is it valid to create the original object without a factory? What does the factory store??? ect ect.
//So like a dependency something or another