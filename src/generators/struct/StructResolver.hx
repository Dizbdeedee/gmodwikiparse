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
    description : UnresolvedDescription,
    realmClient : Bool,
    realmMenu : Bool,
    realmServer : Bool
}

typedef UnresolvedStructField = {
    fieldNo : Int,
    name : String,
    typeUrl : String,
    type : String,
    description : UnresolvedDescription,
    ?def : String,
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
        var fieldsNodes = getCheer(jq,"div.struct").find("div.parameter");
        var fields = [];
        var id = 0;
        fieldsNodes.each((_,el) -> {
            var cheerEl = jq.call(el);
            fields.push(parseParameter(cheerEl,jq,id++));
        });

        var sidebar = getCheer(jq,"a.struct.active");
        var realmServer = sidebar.hasClass("rs");
        var realmClient = sidebar.hasClass("rc");
        var realmMenu = sidebar.hasClass("rm");
        return {
            name: name,
            description: desc,
            fields: fields,
            url: url,
            realmServer: realmServer,
            realmClient: realmClient,
            realmMenu: realmMenu
        }
    }

    function parseParameter(node:CheerioD,jq:CheerioAPI,no:Int):UnresolvedStructField {
        var name = getChildCheerTraverse(node,"strong").text();
        var typeUrl = getChildCheer(node,"a").attr("href");
        var type = getChildCheer(node,"a").text();
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
        return descPublisher.publish(conn,page.description)
        .next(descID -> {
            conn.Struct.insertOne({
                id: null,
                description: descID,
                url: page.url,
                name: page.name,
                realmServer: page.realmServer,
                realmMenu: page.realmMenu,
                realmClient: page.realmClient
            })
        .next(structID -> {
            var publishFields = [for (field in page.fields) pageFields(conn,structID,field)];
            return Promise.inSequence(publishFields);
        });
        });
    }

    function pageFields(conn:data.WikiDB,structID:Int,field:UnresolvedStructField) {
        return Promise.lazy(() -> {
            descPublisher.publish(conn,field.description);
        })
        .next(fieldDescID -> {
            conn.StructMember.insertOne({
                structOrder: field.fieldNo,
                def: field.def,
                typeURL: field.typeUrl,
                type: field.type,
                name: field.name,
                structID: structID
            });
        });
    }

}