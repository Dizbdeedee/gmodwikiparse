package generators.genum;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionParser;
import generators.desc.DescriptionPublisher;
import ParseUtil;
using tink.CoreApi;

interface GEnumResolver {
    function parse(jq:CheerioAPI,url:String):UnresolvedGEnum;
    function publish(conn:data.WikiDB,page:UnresolvedGEnum):Promise<Noise>;
}

typedef UnresolvedGEnumMember = {
    memberNo : Int,
    name : String,
    value : String,
    description : UnresolvedDescription
}

typedef UnresolvedGEnum = {
    name : String,
    url : String,
    enums : Array<UnresolvedGEnumMember>,
    description : UnresolvedDescription,
    realmClient : Bool,
    realmServer : Bool,
    realmMenu : Bool,
    isDeprecated : Bool
}


class GEnumResolverDef implements GEnumResolver {

    final descParser:DescriptionParser;

    final descPublisher:DescriptionPublisher;

    public function new(_descParser,_descPublisher) {
        descParser = _descParser;
        descPublisher = _descPublisher;
    }

    public function parse(jq:CheerioAPI,url:String):UnresolvedGEnum {
        var name = getPageName(url);
        var desc = descParser.parseDescNode(getCheer(jq,"div.function_description"),jq);
        var enums = parseGEnumMembers(jq,getCheer(jq,'h1:contains("Values") + table > tbody'));
        var sidebar = getCheer(jq,"a.active.enum");
        var realmServer = sidebar.hasClass("rs");
        var realmClient = sidebar.hasClass("rc");
        var realmMenu = sidebar.hasClass("rm");
        var isDeprecated = isPageDeprecated(jq);
        return {
            name: name,
            enums: enums,
            description: desc,
            url: url,
            realmServer: realmServer,
            realmClient: realmClient,
            realmMenu: realmMenu,
            isDeprecated: isDeprecated
        }
    }

    public function publish(conn:data.WikiDB,page:UnresolvedGEnum):Promise<Noise> {
        return descPublisher.publish(conn,page.description)
        .next(pageDescID -> 
            conn.GEnum.insertOne({
                id: null,
                realmMenu: page.realmMenu,
                realmClient: page.realmClient,
                realmServer: page.realmServer,
                isDeprecated: page.isDeprecated,
                url: page.url,
                desc: pageDescID
            })
        .next(genumID -> {
            var promiseInsert = [for (genum in page.enums) genumMemPublish(conn,genumID,genum)];
            Promise.inSequence(promiseInsert);
        })
        );
        
    }

    function genumMemPublish(conn:data.WikiDB,genumID:Int,genumMem:UnresolvedGEnumMember):Promise<Noise> {
        return Promise.lazy(() -> {
            return if (genumMem.description != null) {
                descPublisher.publish(conn,genumMem.description);
            } else {
                Promise.resolve(null);
            }
        })
        .next(descID -> {
          conn.GEnumMembers.insertOne({
            memberNo: genumMem.memberNo,
            value: genumMem.value,
            desc: descID,
            enumName: genumMem.name,
            enumID: genumID
          });  
        });
    }

    function parseGEnumMembers(jq:CheerioAPI,urlsNode:CheerioD):Array<UnresolvedGEnumMember> {
        var id:Int = 0;
        final urls:Array<UnresolvedGEnumMember> = [];
        urlsNode.children().each((_,el) -> {
            var cheerEl = jq.call(el);
            urls.push(parseGEnumMember(cheerEl,jq,id++));
            return true;
        });
        return urls;
    }

    function parseGEnumMember(cheerEl:CheerioD,jq:CheerioAPI,id:Int):UnresolvedGEnumMember {
        var name = getChildCheerTraverse(cheerEl,'td > a[name]').attr("name");
        var tds = cheerEl.children();
        var val = jq.call(tds.get(1)).text();
        var descNode = jq.call(tds.get(2));
        var desc = descParser.parseDescNode(descNode,jq);
        desc = if (desc.length < 1) {
            null;
        } else {
            desc;
        }
        return {
            name: name,
            value: val,
            description: desc,
            memberNo: id
        }
    }
}