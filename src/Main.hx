// import node_warc.WARCParser;
// import haxe.Json;
import haxe.Json;
import node.readline.ReadLine;
import js.node.Readline;
import generators.gclass.GClassResolver.GClassResolverDef;
import typelink.TypeLinker;
import generators.standard.FunctionResolver;
import haxe.Timer;
using tink.CoreApi;
import js.node.Fs;
import data.WikiDB;
import warcio.WARCParser;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import generators.standard.UnresolvedFunctionParse;
import generators.standard.UnresolvedFunctionRetParse;
import generators.standard.UnresolvedFunctionArgParse;
import generators.genum.GEnumResolver;
import generators.library.LibraryResolver;
import generators.panel.PanelResolver;
import generators.struct.StructResolver;
import generators.desc.DescriptionPublisher;
import cheerio.lib.cheerio.Cheerio;
import generators.desc.DescSelector;
import cheerio.lib.load.CheerioAPI;
import generators.hook.HookResolver;
import ContentParser;
import ContentParserTest;
import ParseChooser;


typedef Page = {
    address : String,
    updateCount : Int,
    viewCount : Int
}

//append to warc
class Main {

    static function parseWorker(warc:WARCParser,parse:ContentParser) {
        return new Promise((success,failure) -> {
            var doNothing = false;
            function parseResult(result:Outcome<WARCResult,Error>) {
                if (doNothing) return;
                switch (result) {
                    case Success(data):
                        if (data == null) {
                            success(Noise);
                        } else {
                            parse.parse(data).handle((outcome) -> {
                                switch (outcome) {
                                    case Success(_):
                                        warc.parse().toPromise().handle(parseResult);
                                    case Failure(err):
                                        failure(err);
                                }
                            });
                        }
                    case Failure(err):
                        failure(err);
                }

            }
            warc.parse().toPromise().handle(parseResult);
            return () -> {
                doNothing = true;
            };
        });
    }
    static function createDBs(db:WikiDB):Promise<Noise> {
        var databasePromises = [
            db.DescItem.create(true),
            db.DescriptionStorage.create(true),
            db.Function.create(true),
            db.FunctionArg.create(true),
            db.FunctionRet.create(true),
            db.LuaExample.create(true),
            db.Struct.create(true),
            db.StructMember.create(true),
            db.GClass.create(true),
            db.Library.create(true),
            db.GEnum.create(true),
            db.GEnumMembers.create(true),
            db.GClassURL.create(true),
            db.Panel.create(true),
            db.PanelURL.create(true),
            db.Hook.create(true),
            db.HookURL.create(true),
            db.LibraryURL.create(true),
            db.LibraryField.create(true)
            // db.Link_ResolvedTypes.create(true)
        ];
        return Promise.inParallel(databasePromises);
    }

    static function linkMain(db:WikiDB) {
        db.Link_ResolvedTypes.drop().flatMap((_) ->
            db.Link_ResolvedTypes.create(true)
            .next(_ -> {
                trace("Poorly...");
                TypeLinker.addLuaTypes(db).noise();
            })
            .next(_ -> {
                TypeLinker.typeLinkage(db).noise();
            })
            .next(_ -> {
                TypeLinker.typeNext(db).noise();
            })
        ).handle((x) -> {
            trace(x);
            trace("Done");
        });
    }

    static function afterDB() {
        
    }

    public static function main() {
        #if missingJson
        produceMissingJson();
        #else
        main2();
        #end

    }

    static var linesParsed:Map<String,Bool> = [];

    static var allLines:Map<String,Bool> = [];

    static function produceMissingJson() {
        if (!Fs.existsSync("seeds.txt")) throw "No pages.json";
        var parse = Readline.createInterface({input: Fs.createReadStream("parsed.json")});
        parse.on("line",(parseLine) -> {
            var json = Json.parse(parseLine);
            var seedIn = Readline.createInterface({input: Fs.createReadStream("seeds.txt")});
            for (fieldID in Reflect.fields(json)) {
                var arr:Array<String> = Reflect.field(json,fieldID);
                for (arrItem in arr) {
                    linesParsed.set(arrItem,true);
                }
            }
            seedIn.on("line",(seedLine) -> {
                allLines.set(seedLine,true);
            });
            seedIn.on("close",() -> {
                var buf = new StringBuf();
                for (str => _ in allLines) {
                    if (linesParsed.exists(str)) {
                        // trace('Parsed $str');
                    } else {
                        buf.add(str + "\n");
                    }
                }
                Fs.writeFileSync("unparsedseeds.txt",buf.toString());
            });
        });
        
        
        
    }

    public static function main2() {
        
        #if !linkage
        if (Fs.existsSync("wikidb.sqlite")) {
            Fs.unlinkSync("wikidb.sqlite");
        }
        #end
        var driver = new tink.sql.drivers.Sqlite(s -> "wikidb.sqlite");
        var db = new WikiDB("wiki_db",driver);
        createDBs(db).handle(_ -> {
            var warc = new WARCParser(Fs.createReadStream("gmodwiki.warc"));
            var descParserLZ = new DescriptionParserLazy();
            var descParser = new DescriptionParserDef(
            [
                new PSelector(descParserLZ),
                new NoteSelector(descParserLZ),
                new WarnSelector(descParserLZ),
                new BugSelector(descParserLZ),
                new DeprecatedSelector(descParserLZ),
                new RemovedSelector(descParserLZ),
                new ListSelector(descParserLZ),
                new LuaCodeSelector(descParserLZ),
                new HeadingSelector(),
                new HeadingWithSectionSelector(),
                new ValidateSelector(descParserLZ),
                new TitleSelector(),
                new AnchorSelector(),
                new ImageSelector(),
                new TextSelector(),
                new LinkSelector(),
                new TableSelector(),
                new CodeTagSelector(),
                new StrongSelector(),
                new BRSelector(),
                new JSCodeSelector(),
                new KeySelector(),
                new InternalSelector(descParserLZ),
                new ItalicsSelector(),
                new ImgSelector(),
                new ListItemSelector(),
                new CodeFeatureSelector(descParserLZ),
                new BoldSelector()
            ]);
            descParserLZ.resolve(descParser);
            var func = new FunctionResolverDef(
                new UnresolvedFunctionParseDef(descParser),
                new UnresolvedFunctionArgParseDef(descParser),
                new UnresolvedFunctionRetParseDef(descParser),
                new DescriptionPublisherDef()
            );
            var gclass = new GClassResolverDef(descParser,new DescriptionPublisherDef());
            var parseChooser = new ParseChooserDef();
            var panel = new PanelResolverDef(descParser,new DescriptionPublisherDef());
            var struct = new StructResolverDef(descParser,new DescriptionPublisherDef());
            var genum = new GEnumResolverDef(descParser,new DescriptionPublisherDef());
            var library = new LibraryResolverDef(descParser,new DescriptionPublisherDef());
            var hook = new HookResolverDef(descParser,new DescriptionPublisherDef());
            #if linkage
            linkMain(db);
            #else
            #if !test
             var parse = new ContentParserDef(db,parseChooser,
            {
                _panelResolver: panel,
                _structResolver: struct,
                _enumResolver: genum,
                _gclassResolver: gclass,
                _libraryResolver: library,
                _funcResolver: func,
                _hookResolver: hook
            });
            parseWorker(warc,parse).handle((outcome) -> {
                switch (outcome) {
                    case Success(_):
                        linkMain(db);
                        trace("Poggers completed");
                    case Failure(failure):
                        trace(failure.callStack);
                        trace('grr failure $failure');
                }
            });
            #else
            var parse = new ContentParserTestDef(db,parseChooser,{
                _panelResolver: panel,
                _structResolver: struct,
                _enumResolver: genum,
                _gclassResolver: gclass,
                _libraryResolver: library,
                _funcResolver: func,
                _hookResolver: hook
            });
            parse.parseTest().handle(_ -> {

            });
            #end
            #end
        });
        // linkMain(db);
        
    }
}

//TODO... sigh
class DescriptionParserLazy implements generators.desc.DescriptionParser {
    var descParser:generators.desc.DescriptionParser;

    public function new() {}

    public function resolve(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    public function parseDescNode(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return descParser.parseDescNode(elem,jq);
    }
}