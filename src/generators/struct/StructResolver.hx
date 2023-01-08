package generators.struct;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionPublisher;
import generators.desc.DescriptionParser;
import ParseUtil;
using tink.CoreApi;

interface StructResolver {
    function parse(url:String,jq:CheerioAPI):UnresolvedStructPage;
    function publish(conn:data.WikiDB,page:UnresolvedStructPage):Promise<Noise>;
}

typedef UnresolvedStructPage = {
    name : String,
    url : String,
    fields : Array<UnresolvedStructField>,
    description : UnresolvedDescription

}

typedef UnresolvedStructField = {
    fieldNo : Int,
    name : String,
    typeUrl : String,
    type : String,
    description : UnresolvedDescription,
    def : String
}

class StructResolverDef implements StructResolver {

    final descParser:DescriptionParser;

    final descPublisher:DescriptionPublisher;

    public function new(_descParser:DescriptionParser,_descPublisher:DescriptionPublisher) {
        descParser = _descParser;
        descPublisher = _descPublisher;
    }

    public function parse(url:String,jq:CheerioAPI):UnresolvedStructPage {
        var regex = ~/gmod\/(.*)/;
        regex.match(url);

        var name = regex.matched(1);
        var descContent = getCheer(jq,"div.struct_description");
        var desc = descParser.parseDescNode(descContent,jq);
        var fieldsNodes = getCheer(jq,"div.struct").children("div.parameter");
        var fields = [];
        var id = 0;
        fieldsNodes.each((_,el) -> {
            var cheerEl = jq.call(el);
            fields.push(parseParameter(cheerEl,jq,id++));
        });

        return {
            name: name,
            description: desc,
            fields: fields,
            url: url  
        }

        // var pageContent = getCheer(jq,"div.type > div.section");
        // var desc = descParser.parseDescNode(pageContent,jq);
        // var urlsNode = getCheer(jq,"div.members > h1:contains('Methods') ~ div.section");
        // var id = 0;
        // var urls:Array<UnresolvedGClassURL> = [];
        // urlsNode.children().each((_,el) -> {
        //     var cheerEl = jq.call(el);
        //     urls.push(parseURL(cheerEl,jq,id++));
        //     return true;
        // });
        // trace({
        //     description: desc,
        //     name : name,
        //     urls : urls,
        //     url : url
        // });
        // return {
        //     description: desc,
        //     name : name,
        //     urls : urls,
        //     url : url
        // }
        
    }

    function parseParameter(node:CheerioD,jq:CheerioAPI,no:Int):UnresolvedStructField {
        var name = getChildCheer(node,"p > strong").text();
        var typeUrl = getChildCheer(node,"p:has(strong) > a").attr("href");
        var type = getChildCheer(node,"p:has(strong) > a").text();
        var descNode = getChildCheer(node,"div.description");
        var desc = descParser.parseDescNode(descNode,jq);
        var def = getChildOptCheer(node,"div.description > p:has(code)");
        trace(def);
        return {
            fieldNo: no,
            def: null,
            description: desc,
            type: type,
            typeUrl: typeUrl,
            name: name
        }
         
    }

    public function publish(conn:data.WikiDB,page:UnresolvedStructPage):Promise<Noise> {
        return Promise.NOISE;
        // return descPublisher.publish(conn,page.description)
        // .next((descID) -> 
        //     conn.GClass.insertOne({
        //         id: null,
        //         description: descID,
        //         url: page.url,
        //         name: page.name
        //     })
        // .next((gclassID) -> {
        //     var urls = page.urls.map((url) -> 
        //         Promise.lazy(conn.GClassURL.insertOne({
        //             urlNo: url.urlNo,
        //             url: url.url,
        //             gclassID: gclassID
        //         }))
        //     );
        //     return Promise.inSequence(urls).noise();
        // }));
    }

}