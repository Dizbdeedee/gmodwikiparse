package;

import generators.hook.HookResolver;
import node.util.TextDecoder;
import js.node.util.TextEncoder;
import js.node.StringDecoder;
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

typedef Sorts = {
    funcs : Array<String>,
    gclasses : Array<String>,
    struct : Array<String>,
    panels : Array<String>,
    libs : Array<String>,
    genums : Array<String>,
    hooks : Array<String>
}

typedef SavedResult = {
    uri : String,
    buffer : String
}

@:await
class ContentParserDef implements ContentParser {

    final dbConnection:data.WikiDB;

    final funcResolver:FunctionResolver;
    
    final gclassResolver:GClassResolver;

    final parseChooser:ParseChooser;

    final panelResolver:PanelResolver;

    final structResolver:StructResolver;

    final enumResolver:GEnumResolver;
    
    final libraryResolver:LibraryResolver;

    final hookResolver:HookResolver;

    final unparsedURL:Array<String> = [];

    final tests:Tests = {
        funcs: [],
        gclasses: [],
        panels: [],
        struct: [],
        libs: [],
        genums: [],
        hooks: []
    }

    final sortedURL:Sorts = {
        funcs: [],
        hooks: [],
        genums: [],
        libs: [],
        panels: [],
        struct: [],
        gclasses: []
    }

    public function new (_parseChooser:ParseChooser,initBundle:ContentParserResolversInitBundle) {
        dbConnection = _dbConnection;
        parseChooser = _parseChooser;
        funcResolver = initBundle._funcResolver;
        gclassResolver = initBundle._gclassResolver;
        panelResolver = initBundle._panelResolver;
        structResolver = initBundle._structResolver;
        enumResolver = initBundle._enumResolver;
        libraryResolver = initBundle._libraryResolver;
        hookResolver = initBundle._hookResolver;
    }

    public function parse(dbConnection:data.WikiDB,content:WARCResult):Promise<Noise> {
        if (content.warcType != "response") {
            return Promise.resolve(Noise);
        }
        var readPromise = content.readFully().toPromise();
        var handledPromise = readPromise.next((data) -> loadHTML(dbConnection,content));
        return handledPromise.noise();
    }


    function updateOutputTests() {
        Fs.writeFileSync("tests.json",Json.stringify(tests));
    }

    static final decoder:TextDecoder = new TextDecoder();

    function loadHTML(dbConnection:data.WikiDB,parsedWarc:WARCResult):Promise<Noise> {
        final url = parsedWarc.warcTargetURI;
        // trace(parsedWarc.payload);
        final buf = decoder.decode(parsedWarc.payload);
        // var doc = Htmlparser2.parseDocument(buf);
        final jq = Cheerio.load(buf);
        return processExceptions(url,jq).next((processed) -> {
            if (processed) return Promise.NOISE;
            trace('URI $url');
            return switch (parseChooser.choose(jq,url)) { 
                case NoMatch:
                    trace('Unmatched $url');
                    unparsedURL.push(url);
                    Fs.writeFileSync("unparsed.json",Json.stringify(unparsedURL));
                    Promise.NOISE;
                case Function:
                    updateTest(tests.funcs,url,buf);
                    sortedURL.funcs.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = funcResolver.resolve(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    funcResolver.publish(dbConnection,unresolved);
                    #end
                case Enum:
                    updateTest(tests.genums,url,buf);
                    sortedURL.genums.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = enumResolver.parse(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    enumResolver.publish(dbConnection,unresolved);
                    #end
                    
                case Struct:
                    updateTest(tests.struct,url,buf);
                    sortedURL.struct.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = structResolver.parse(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    structResolver.publish(dbConnection,unresolved);
                    #end
                case GClass:
                    updateTest(tests.gclasses,url,buf);
                    sortedURL.gclasses.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = gclassResolver.resolve(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    gclassResolver.publish(dbConnection,unresolved);
                    #end
                case Panel:
                    updateTest(tests.panels,url,buf);
                    sortedURL.panels.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = panelResolver.resolve(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    panelResolver.publish(dbConnection,unresolved);
                    #end   
                case Library:
                    updateTest(tests.libs,url,buf);
                    sortedURL.libs.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = libraryResolver.parse(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    libraryResolver.publish(dbConnection,unresolved);
                    #end
                case Hooks:
                    updateTest(tests.hooks,url,buf);
                    sortedURL.hooks.push(url);
                    Fs.writeFileSync("parsed.json",Json.stringify(sortedURL));
                    var unresolved = hookResolver.parse(url,jq);
                    #if nodb
                    Promise.NOISE;
                    #else
                    hookResolver.publish(dbConnection,unresolved);
                    #end

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
            case "https://wiki.facepunch.com/gmod/SKIN_Hooks":
                trace("Skin hooks hooks");
                Promise.resolve(true);
            default:
                Promise.resolve(false);
        }
    }

}
