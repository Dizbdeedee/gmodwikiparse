package generators.gclass;

import generators.desc.DescriptionPublisher;
import ParseUtil;
import generators.desc.DescriptionParser;
import generators.desc.UnresolvedDescription;
import data.Id;
using tink.CoreApi;

interface GClassResolver {
    function resolve(url:String,jq:CheerioAPI):UnresolvedGClassPage;
    function publish(conn:data.WikiDB,page:UnresolvedGClassPage):Promise<Noise>;
}

typedef UnresolvedGClassPage = {
    name : String,
    description : UnresolvedDescription,
    urls : Array<UnresolvedGClassURL>,
    url : String

}

class GClassResolverDef implements GClassResolver {
    final descParser:DescriptionParser;
    final descPublisher:DescriptionPublisher;
    public function new(_descParser:DescriptionParser,_descPublisher:DescriptionPublisher) {
        descParser = _descParser;
        descPublisher = _descPublisher;
    }

    public function resolve(url:String,jq:CheerioAPI):UnresolvedGClassPage {
        var regex = ~/gmod\/(.*)/;
        regex.match(url);
        var name = regex.matched(1);
        var pageContent = getCheer(jq,"div.type > div.section");
        var desc = descParser.parseDescNode(pageContent,jq);
        var urlsNode = getCheer(jq,"div.members > h1:contains('Methods') ~ div.section");
        var id = 0;
        var urls:Array<UnresolvedGClassURL> = [];
        urlsNode.children().each((_,el) -> {
            var cheerEl = jq.call(el);
            urls.push(parseURL(cheerEl,jq,id++));
            return true;
        });
        trace({
            description: desc,
            name : name,
            urls : urls,
            url : url
        });
        return {
            description: desc,
            name : name,
            urls : urls,
            url : url
        }
        
    }

    function parseURL(node:CheerioD,jq:CheerioAPI,no:Int):UnresolvedGClassURL {
        var url = getChildCheer(node,"a.subject").attr("href");
        return {
            urlNo : no,
            url : url
        }
    }

    public function publish(conn:data.WikiDB,page:UnresolvedGClassPage) {
        return descPublisher.publish(conn,page.description)
        .next((descID) -> 
            conn.GClass.insertOne({
                id: null,
                description: descID,
                url: page.url,
                name: page.name
            })
        .next((gclassID) -> {
            var urls = page.urls.map((url) -> 
                Promise.lazy(conn.GClassURL.insertOne({
                    urlNo: url.urlNo,
                    url: url.url,
                    gclassID: gclassID
                }))
            );
            return Promise.inSequence(urls).noise();
        }));
    }

}

typedef UnresolvedGClassURL = {
    urlNo : Int,
    url : String
}