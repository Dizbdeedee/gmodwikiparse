package;

import generators.panel.PanelResolver;
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

    final panelResolver:PanelResolver;

    final tests:Tests = {
        funcs : [],
        gclasses : []
    }

    public function new (_dbConnection,_descParser
        ,_funcResolver,_gclassResolver,_parseChooser,
        _panelResolver) {
        dbConnection = _dbConnection;
        descParser = _descParser;
        funcResolver = _funcResolver;
        gclassResolver = _gclassResolver;
        parseChooser = _parseChooser;
        panelResolver = _panelResolver;
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
                case Panel:
                   var unresolved = panelResolver.resolve(parsedWarc.warcTargetURI,jq);
                   panelResolver.publish(dbConnection,unresolved);
                case Hooks:
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

}
