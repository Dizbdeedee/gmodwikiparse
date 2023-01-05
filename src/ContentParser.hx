package;

import haxe.Json;
import js.node.Fs;
import generators.gclass.GClassResolver;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import generators.standard.FunctionResolver;
import ParseUtil;
using tink.CoreApi;

typedef WarcData = {
    url : String,
    buff : Dynamic
}


interface ContentParser {
    function parse(content:WARCResult):Promise<Noise>;
}

typedef Tests = {
    funcs : Array<SavedResult>,
    gclasses : Array<SavedResult>
}

typedef SavedResult = {
    uri : String,
    buffer : String
}

@:await
class ContentParserDef implements ContentParser {

    // var jq:CheerioAPI;

    final descParser:DescriptionParser;

    final dbConnection:data.WikiDB;

    final funcResolver:FunctionResolver;
    
    final gclassResolver:GClassResolver;

    final parseChooser:ParseChooser;

    final tests:Tests = {
        funcs : [],
        gclasses : []
    }

    public function new (_dbConnection:data.WikiDB,_descParser:DescriptionParser
        ,_funcResolver:FunctionResolver,_gclassResolver:GClassResolver,_parseChooser) {
        dbConnection = _dbConnection;
        descParser = _descParser;
        funcResolver = _funcResolver;
        gclassResolver = _gclassResolver;
        parseChooser = _parseChooser;
    }

    public function parse(content:WARCResult):Promise<Noise> {
        if (content.warcType != "response") {
            return Promise.resolve(Noise);
        }
        var readPromise = content.readFully().toPromise();
        var handledPromise = readPromise.next((data) -> loadHTML(content));
        return handledPromise.noise();
    }


    function updateOutputTests() {
        Fs.writeFileSync("tests.json",Json.stringify(tests));
    }

    function loadHTML(parsedWarc:WARCResult) {
        final jq = Cheerio.load(cast node.buffer.Buffer.from(parsedWarc.payload));
        return processExceptions(parsedWarc.warcTargetURI,jq).next((processed) -> {
            if (processed) return Promise.NOISE;
            trace('URI ${parsedWarc.warcTargetURI}');
            return switch (parseChooser.choose(jq,parsedWarc.warcTargetURI)) { 
                case NoMatch:
                    trace('Unmatched ${parsedWarc.warcTargetURI}');
                    Promise.NOISE;
                case Function:
                    if (tests.funcs.length < 5) {
                        tests.funcs.push({
                            uri: parsedWarc.warcTargetURI,
                            buffer: node.buffer.Buffer.from(parsedWarc.payload).toString()
                        });
                        updateOutputTests();
                    }
                    var unresolved = funcResolver.resolve(parsedWarc.warcTargetURI,jq);
                    // trace(unresolved);
                    
                    funcResolver.publish(dbConnection,unresolved);

                case Enum:
                    // Promise.resolve(parseEnum(parsedWarc.warcTargetURI,jq));
                    Promise.NOISE;
                case Struct:
                    // Promise.resolve(parseStruct(parsedWarc.warcTargetURI,jq));
                    Promise.NOISE;
                case GClass:
                    if (tests.gclasses.length < 5) {
                        tests.gclasses.push({
                            uri: parsedWarc.warcTargetURI,
                            buffer: node.buffer.Buffer.from(parsedWarc.payload).toString()
                        });
                        updateOutputTests();
                    }
                    var unresolved = gclassResolver.resolve(parsedWarc.warcTargetURI,jq);
                    gclassResolver.publish(dbConnection,unresolved);
                case Panel | Hooks:
                    Promise.NOISE;
            }
        });
    }

    function processExceptions(url:String,jq:CheerioAPI):tink.core.Promise<Bool> {
        return switch url {
            case "https://wiki.facepunch.com/gmod/Enums/STENCIL":
                trace("Stencil!");
                // parseEnum(parsedWarc.warcTargetURI,jq).next(parsedWarc.warcTargetURI);
                Promise.resolve(true);
            case "https://wiki.facepunch.com/gmod/PLAYER_Hooks":
                trace("Player Hooks hooks...");
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
