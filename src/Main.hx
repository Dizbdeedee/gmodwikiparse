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



typedef Page = {
    address : String,
    updateCount : Int,
    viewCount : Int
}

static final WARC_NAME = "gmodwiki"

static final WARC_EXT = ".warc";

static final WARC_EXT_ZIPPED = ".warc.gz";

//append to warc
class Main {

    static function parseWorker(dbConnection:data.wikiDB,warc:WARCParser,parse:ContentParser) {
        return new Promise((success,failure) -> {
            var doNothing = false;
            function parseResult(result:Outcome<WARCResult,Error>) {
                if (doNothing) return;
                switch (result) {
                    case Success(data):
                        if (data == null) {
                            success(Noise);
                        } else {
                            parse.parse(dbConnection,data).handle((outcome) -> {
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

    
    static function existsWarc(find:String):String {
        return if (Fs.existsSync('$find$WARC_EXT')) {
            '$find$WARC_EXT';
        } else if (Fs.existsSync('$find$WARC_EXT_ZIPPED')) {
            '$find$WARC_EXT_ZIPPED';
        } else {
            null;
        }
    }

    static function findAvaliableWarcs():Array<String> {
        var avaliable = [];
        for (i in 1...100) {
            var resultExists = existsWarc('${WARC_NAME}_$i');
            if (resultsExists != null) {
                avaliable.push(resultExists);
            } else {
                break;
            }
        }
        return avaliable;
    }
    
    //hmmmmm...?
    

    public static function main() {
        #if missingJson
        MissingJson.produceMissingJson();
        #else
        mainOthers();
        #end

    }
    
    public static function mainOthers() {
        #if (!linkage && !keepPrev)
        if (Fs.existsSync("wikidb.sqlite")) {
            Fs.unlinkSync("wikidb.sqlite");
        }
        #end
        var driver = new tink.sql.drivers.Sqlite(s -> "wikidb.sqlite");
        var db = new WikiDB("wiki_db",driver);
        createDBs(db).handle(_ -> {
            for (i in findAvaliableWarcs()) {

            }
            #if linkage
            linkMain(db);
            #elseif test
            var contentParser = Creation.contentParserTest();
            parse.parseTest(db).handle(_ -> {

            });
            #else
            var contentParser = Creation.contentParser();
            parseWorker(db,warc,parse).handle((outcome) -> {
                switch (outcome) {
                    case Success(_):
                        linkMain(db);
                        trace("Poggers completed");
                    case Failure(failure):
                        trace(failure.callStack);
                        trace('grr failure $failure');
                }
            });
            #end
        });
        // linkMain(db);
        
    }
}
