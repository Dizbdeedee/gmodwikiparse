
import ContentParser.SavedResult;
import ContentParser.Tests;
import haxe.Json;
import js.node.Fs;
import generators.gclass.GClassResolver;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import generators.standard.FunctionResolver;
import ParseUtil;
using tink.CoreApi;

interface ContentParserTest {
    function parseTest():Promise<Noise>;
}

class ContentParserTestDef implements ContentParserTest {

    final descParser:DescriptionParser;

    final dbConnection:data.WikiDB;

    final funcResolver:FunctionResolver;
    
    final gclassResolver:GClassResolver;

    final parseChooser:ParseChooser;

    public function new (_dbConnection:data.WikiDB,_descParser:DescriptionParser
        ,_funcResolver:FunctionResolver,_gclassResolver:GClassResolver,_parseChooser:ParseChooser) {
        dbConnection = _dbConnection;
        descParser = _descParser;
        funcResolver = _funcResolver;
        gclassResolver = _gclassResolver;
        parseChooser = _parseChooser;
    }

    public function parseTest():Promise<Noise> {
        // Fs.readdirSync("test");
        var filebuf = Fs.readFileSync("tests.json");
        var json:Tests = cast Json.parse(filebuf.toString());
        var arr = [];
        for (func in json.funcs) {
            arr.push(Promise.lazy(() -> loadHTMLTest(func)));
        }
        for (gclass in json.gclasses) {
            arr.push(Promise.lazy(() -> loadHTMLTest(gclass)));
        }
        return Promise.inSequence(arr);
    }

    function loadHTMLTest(saved:SavedResult):Promise<Noise> {
        final jq = Cheerio.load(saved.buffer);
        return processExceptions(saved.uri,jq).next((processed) -> {
            if (processed) return Promise.resolve(Noise);
            return switch (parseChooser.choose(jq,saved.uri)) {
                case NoMatch:
                    Promise.resolve(Noise);
                case Function:
                    var unresolved = funcResolver.resolve(saved.uri,jq);
                    // trace(unresolved);
                    funcResolver.publish(dbConnection,unresolved);
                case Enum:
                    // Promise.resolve(parseEnum(parsedWarc.warcTargetURI,jq));
                    Promise.resolve(Noise);
                case Struct:
                    // Promise.resolve(parseStruct(parsedWarc.warcTargetURI,jq));
                    Promise.resolve(Noise);
                case GClass:
                    var unresolved = gclassResolver.resolve(saved.uri,jq);
                    gclassResolver.publish(dbConnection,unresolved);
                case Panel | Hooks:
                    Promise.resolve(Noise);
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