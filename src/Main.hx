// import node_warc.WARCParser;
// import haxe.Json;
import haxe.Timer;
using tink.CoreApi;
import js.node.Fs;
import data.WikiDB;
import warcio.WARCParser;
import warcio.WARCResult;
import generators.desc.DescriptionParser;
import cheerio.lib.cheerio.Cheerio;
import generators.desc.DescSelector;
import cheerio.lib.load.CheerioAPI;
import ContentParser;


typedef Page = {
    address : String,
    updateCount : Int,
    viewCount : Int
}

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
            db.GClass.create(true),
            db.Library.create(true),
            db.GEnum.create(true),
            db.GEnumMembers.create(true)
        ];
        return Promise.inParallel(databasePromises);
    }

    public static function main() {
        var driver = new tink.sql.drivers.Sqlite(s -> "wikidb");
        var db = new WikiDB("wiki_db",driver);
        createDBs(db).handle((out) -> {
            trace(out);
        });
        var warc = new WARCParser(Fs.createReadStream("gmodwiki.warc.gz"));
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
        var parse = new ContentParserDef(db,descParser);
        parseWorker(warc,parse).handle((outcome) -> {
            switch (outcome) {
                case Success(_):
                    trace("Poggers completed");
                case Failure(failure):
                    trace('grr failure $failure');
            }
        });
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