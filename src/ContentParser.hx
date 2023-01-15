package;

import generators.struct.StructResolver;
import generators.panel.PanelResolver;
import haxe.Json;
import js.node.Fs;
import generators.gclass.GClassResolver;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import generators.standard.FunctionResolver;
import generators.library.LibraryResolver;
import generators.genum.GEnumResolver;
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
    gclasses : Array<SavedResult>,
    struct : Array<SavedResult>,
    panels : Array<SavedResult>,
    libs : Array<SavedResult>,
    genums : Array<SavedResult>,
    hooks : Array<SavedResult>
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

    final structResolver:StructResolver;

    final enumResolver:GEnumResolver;
    
    final libraryResolver:LibraryResolver;

    final tests:Tests = {
        funcs: [],
        gclasses: [],
        panels: [],
        struct: [],
        libs: [],
        genums: []
    }

    public function new (_dbConnection,_descParser
        ,_funcResolver,_gclassResolver,_parseChooser,
        _panelResolver,_structResolver,
        _enumResolver,_libraryResolver) {
        dbConnection = _dbConnection;
        descParser = _descParser;
        funcResolver = _funcResolver;
        gclassResolver = _gclassResolver;
        parseChooser = _parseChooser;
        panelResolver = _panelResolver;
        structResolver = _structResolver;
        enumResolver = _enumResolver;
        libraryResolver = _libraryResolver;
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

    function loadHTML(parsedWarc:WARCResult):Promise<Noise> {
        final url = parsedWarc.warcTargetURI;
        final buf = cast node.buffer.Buffer.from(parsedWarc.payload);
        final jq = Cheerio.load(buf);
        return processExceptions(url,jq).next((processed) -> {
            if (processed) return Promise.NOISE;
            trace('URI $url');
            return switch (parseChooser.choose(jq,url)) { 
                case NoMatch:
                    trace('Unmatched $url');
                    Promise.NOISE;
                case Function:
                    updateTest(tests.funcs,url,buf);
                    var unresolved = funcResolver.resolve(url,jq);
                    funcResolver.publish(dbConnection,unresolved);
                case Enum:
                    updateTest(tests.genums,url,buf);
                    var unresolved = enumResolver.parse(jq,url);
                    enumResolver.publish(dbConnection,unresolved);
                case Struct:
                    updateTest(tests.struct,url,buf);
                    var unresolved = structResolver.parse(url,jq);
                    structResolver.publish(dbConnection,unresolved);
                case GClass:
                    updateTest(tests.gclasses,url,buf);
                    var unresolved = gclassResolver.resolve(url,jq);
                    gclassResolver.publish(dbConnection,unresolved);
                case Panel:
                    updateTest(tests.panels,url,buf);
                    var unresolved = panelResolver.resolve(url,jq);
                    panelResolver.publish(dbConnection,unresolved);
                case Library:
                    updateTest(tests.libs,url,buf);
                    var unresolved = libraryResolver.parse(jq,url);
                    libraryResolver.publish(dbConnection,unresolved);
                case Hooks:
                    Promise.NOISE;

            }
        });
    }

    function updateTest(arr:Array<SavedResult>,url:String,buf:String) {
        if (arr.length < 5) {
            arr.push({
                uri: url,
                buffer: buf
            });
            updateOutputTests();
        }
    }

    function processExceptions(url:String,jq:CheerioAPI):tink.core.Promise<Bool> {
        return switch url {
            case "https://wiki.facepunch.com/gmod/Enums/STENCIL":
                trace("Stencil!");
                // parseEnum(url,jq).next(url);
                Promise.resolve(true);
            case "https://wiki.facepunch.com/gmod/PLAYER_Hooks":
                trace("Player Hooks hooks...");
                Promise.resolve(true);
            default:
                Promise.resolve(false);
        }
    }

}
