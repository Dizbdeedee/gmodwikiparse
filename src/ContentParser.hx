package;

import data.WikiDB.DescItem;
import data.WikiDB.DescriptionStorage;
import tink.sql.Types;
import tink.sql.Database;
import data.WikiDB.FunctionArg;
import js.lib.Uint8Array;
import cheerio.lib.load.CheerioAPI;
import cheerio.lib.cheerio.Cheerio;
import node.Buffer;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import ParseUtil.getOptCheer;
import ParseUtil.getCheer;
import ParseUtil.getChildCheer;
import ParseUtil.getChildOptCheer;
using tink.CoreApi;
using Lambda;

typedef WarcData = {
    url : String,
    buff : Dynamic
}


interface ContentParser {
    function parse(content:WARCResult):Promise<Noise>;
}

@:await
class ContentParserDef implements ContentParser {

    var jq:CheerioAPI;

    final descParser:DescriptionParser;

    final dbConnection:data.WikiDB;

    public function new (_dbConnection:data.WikiDB,_descParser:DescriptionParser) {
        dbConnection = _dbConnection;
        descParser = _descParser;
    }

    public function parse(content:WARCResult):Promise<Noise> {
        if (content.warcType != "response") {
            return Promise.resolve(Noise);
        }
        var readPromise = content.readFully().toPromise();
        var handledPromise = readPromise.next((data) -> loadHTML(content));
        return handledPromise.noise();
    }

    function loadHTML(parsedWarc:WARCResult) {
        jq = Cheerio.load(cast node.buffer.Buffer.from(parsedWarc.payload));
        return processExceptions(parsedWarc.warcTargetURI,jq).next((processed) -> {
            if (processed) return Promise.resolve(Noise);
            var isFunc = getOptCheer(jq,"div.function");
            var isEnum = getOptCheer(jq,"div.enum");
            var isStruct = getOptCheer(jq,"div.struct");
            return switch [isFunc,isEnum,isStruct] {
                case [None,None,None]:
                    // trace(parsedWarc);
                    trace('Unmatched... ${parsedWarc.warcTargetURI}');
                    Promise.resolve(Noise);
                case [Some(_),None,None]:
                    // publishFunction(parsedWarc.warcTargetURI,jq);
                    Promise.resolve(Noise);
                case [None,Some(_),None]:
                    // Promise.resolve(parseEnum(parsedWarc.warcTargetURI,jq));
                    Promise.resolve(Noise);
                case [None,None,Some(_)]:
                    // Promise.resolve(parseStruct(parsedWarc.warcTargetURI,jq));
                    Promise.resolve(Noise);
                default:
                    trace("Multiple page types matched!!");
                    trace(isFunc,isEnum,isStruct);

                    // trace(data.warcTargetURI);
                    throw "Multiple page types matched!!";
            }
        });
    }

    function processExceptions(url:String,jq:CheerioAPI):tink.core.Promise<Bool> {
        return switch url {
            case "https://wiki.facepunch.com/gmod/Enums/STENCIL":
                trace("Stencil!");
                // parseEnum(parsedWarc.warcTargetURI,jq).next(parsedWarc.warcTargetURI);
                Promise.resolve(true);
            default:
                Promise.resolve(false);
        }
    }


    // function parseStruct(url:String,jq:CheerioAPI):data.WikiDB.Struct {
    //     return null;
    // }

    // @:async function parseEnum(url:String,jq:CheerioAPI):data.WikiDB.GEnum {
    //     var title = getCheer(jq,"h1#pagetitle.pagetitle").text();
    //     var desc = getOptCheer(jq,".function_description");
    //     var enums = getCheer(jq,"h1 + table > tbody");
    //     return null;
    // }

    // @:async function parseReturn(node:Cheerio<Dynamic>,jq:CheerioAPI) {
    //     var typeNode = getChildCheer(node,"a");
    //     var type = typeNode.text();
    //     var typeURL = typeNode.attr("href");
    //     var returnNo = Std.parseInt(getChildCheer(node,"span.numbertag").text());
    //     var desc = getChildOptCheer(node,"div.numbertagindent");
    //     var descStoreID = @:await switch (desc) {
    //         case Some(descNode):
    //             var descs = descParser.parseDescNode(descNode);
    //             if (descs.length >= 1) {
    //                 publishAndValidate(descs);
    //             } else {
    //                 Promise.resolve(null);
    //             }
    //         case None:
    //             Promise.resolve(null);
    //     }
    //     var funcRet:WikiDB.FunctionRet = {
    //         returnNo : returnNo,
    //         typeURL : typeURL,
    //         type : type,
    //         desc : descStoreID,
    //         funcid : null
    //     }
    //     return funcRet;
    //     // trace(funcRet);
    // }

    // @:async function parseFuncArg(node:Cheerio<Dynamic>) {
    //     var typeNode = getChildCheer(node,"a");
    //     var type = typeNode.text();
    //     var typeURL = typeNode.attr("href");
    //     var argumentNo = Std.parseInt(getChildCheer(node,"span.numbertag").text());
    //     var name = getChildCheer(node,"span.name").text();
    //     var desc = getChildCheer(node,"div.numbertagindent");
    //     var defResult = getChildOptCheer(node,"span.default");
    //     var descID = @:await {
    //         var descNodes = descParser.parseDescNode(desc,jq);
    //         if (descNodes.length > 0) {
    //             publishAndValidate(descNodes);
    //         } else {
    //             Promise.resolve(null);
    //         }
    //     }
    //     // trace(results);
    //     // DescriptionParser.parseDescription(selectorDesc);
    //     final funcArg:FunctionArg = {
    //         argumentNo : argumentNo,
    //         typeURL : typeURL,
    //         type : type,
    //         name : name,
    //         description : descID,
    //         funcid : null,
    //         def : switch (defResult) {
    //             case Some(cheer):
    //                 cheer.text();
    //             case None:
    //                 null;
    //         }
    //     }
    //     return funcArg;
    // }






}
