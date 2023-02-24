import generators.library.LibraryResolver;
import generators.struct.StructResolver;
import generators.panel.PanelResolver;
import generators.hook.HookResolver;
import generators.genum.GEnumResolver;
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
    function parseTest(dbConnection:data.WikiDB):Promise<Noise>;
}

class ContentParserTestDef implements ContentParserTest {

    final funcResolver:FunctionResolver;

    final gclassResolver:GClassResolver;

    final parseChooser:ParseChooser;

    final panelResolver:PanelResolver;

    final structResolver:StructResolver;

    final genumResolver:GEnumResolver;

    final hookResolver:HookResolver;

    final libraryResolver:LibraryResolver;

    public function new (_parseChooser:ParseChooser,initBundle:ContentParserResolversInitBundle) {
        parseChooser = _parseChooser;
        funcResolver = initBundle._funcResolver;
        gclassResolver = initBundle._gclassResolver;
        panelResolver = initBundle._panelResolver;
        structResolver = initBundle._structResolver;
        hookResolver = initBundle._hookResolver;
        libraryResolver = initBundle._libraryResolver;
        genumResolver = initBundle._enumResolver;
    }

    public function parseTest(dbConnection:data.WikiDB):Promise<Noise> {
        // Fs.readdirSync("test");
        trace("woo");
        var filebuf = Fs.readFileSync("tests.json");
        var json:Tests = cast Json.parse(filebuf.toString());
        var arr = [];
        for (func in json.funcs) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,func)));
        }
        for (gclass in json.gclasses) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,gclass)));
        }
        for (struct in json.struct) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,struct)));
        }
        for (panel in json.panels) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,panel)));
        }
        for (libs in json.libs) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,libs)));
        }
        for (genum in json.genums) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,genum)));
        }
        for (hook in json.hooks) {
            arr.push(Promise.lazy(() -> loadHTMLTest(dbConnection,hook)));
        }

        return Promise.inSequence(arr);
    }

    function loadHTMLTest(dbConnection:data.WikiDB,saved:SavedResult):Promise<Noise> {
        trace(saved.uri);
        final jq = Cheerio.load(saved.buffer);
        return processExceptions(saved.uri,jq).next((processed) -> {
            if (processed) return Promise.resolve(Noise);
            // trace(jq);
            return switch (parseChooser.choose(jq,saved.uri)) {
                case NoMatch:
                    trace(saved.uri);
                    Promise.resolve(Noise);
                case Function:
                    var unresolved = funcResolver.resolve(saved.uri,jq);
                    // trace(unresolved);
                    funcResolver.publish(dbConnection,unresolved);
                case Enum:
                    var unresolved = genumResolver.parse(saved.uri,jq);
                    genumResolver.publish(dbConnection,unresolved);
                case Struct:
                    var unresolved = structResolver.parse(saved.uri,jq);
                    trace(unresolved);
                    structResolver.publish(dbConnection,unresolved);
                case GClass:
                    var unresolved = gclassResolver.resolve(saved.uri,jq);
                    gclassResolver.publish(dbConnection,unresolved);
                case Panel:
                    var unresolved = panelResolver.resolve(saved.uri,jq);
                    panelResolver.publish(dbConnection,unresolved);
                case Hooks:
                    var unresolved = hookResolver.parse(saved.uri,jq);
                    hookResolver.publish(dbConnection,unresolved);
                case Library:
                    var unresolved = libraryResolver.parse(saved.uri,jq);
                    libraryResolver.publish(dbConnection,unresolved);
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