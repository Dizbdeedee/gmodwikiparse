package generators.hook;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionPublisher;
import generators.desc.DescriptionParser;
import ParseUtil;
using tink.CoreApi;

interface HookResolver {
    function parse(url:String,jq:CheerioAPI):UnresolvedHookPage;
    function publish(conn:data.WikiDB,page:UnresolvedHookPage):Promise<Noise>;
}

typedef UnresolvedHookPage = {
    name : String,
    description : UnresolvedDescription,
    url : String,
    urls : Array<UnresolvedHookURL>

}

typedef UnresolvedHookURL = {
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
        var name = getPageName(url);
        var descNode = getCheer(jq,"div.type > div.section");
        var description = descParser.parseDescNode(descNode,jq);
        var urlsNode = getCheer(jq,"h1:contains('Events') + div.section");
        var id = 0;
        var urls:Array<UnresolvedHookURL> = mapChildren(urlsNode,jq,(el) -> {
            parseURL(el,jq,id++);
        });
        // var name = getPageName()
        return {
            name: name,
            description: description,
            urls: urls,
            url: url
        }
    }

    function parseURL(node:CheerioD,jq:CheerioAPI,urlNo:Int):UnresolvedHookURL {
        var url = getChildCheer(node,"a.subject").attr("href");
        return {
            urlNo: urlNo,
            url: url
        }
    }

    public function publish(conn:data.WikiDB,page:UnresolvedHookPage):Promise<Noise> {
        return Promise.NOISE;
    }
}