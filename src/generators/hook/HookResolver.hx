package generators.hook;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionPublisher;
import generators.desc.DescriptionParser;
import ParseUtil;
using tink.CoreApi;

interface HookResolver {
    function parse(url:String,jq:CheerioAPI):UnresolvedStructPage;
    function publish(conn:data.WikiDB,page:UnresolvedStructPage):Promise<Noise>;
}

typedef UnresolvedHook {
    name : String,
    description : UnresolvedDescription,
    url : String,
    urls : Array<UnresolvedHookURL>

}

typedef UnresolvedHookURL {
    urlNo : Int,
    url : String
}


class HookResolverDef implements HookResolver {

    final descParser:DescriptionParser;

    final descPublisher:DescriptionPublisher;

    public function new(_descParser,_descPublisher) {
        descParser = _descParser;
        descPublisher = _descPublisher;
    }

    public function parse(url:String,jq:CheerioAPI):UnresolvedHookPage {
        var name = getPageName
        return {
            name : null,
            description : null
        }
    }

    public function publish(conn:data.WikiDB,page:UnresolvedHookPage):Promise<Noise> {
        return Promise.NOISE;
    }
}