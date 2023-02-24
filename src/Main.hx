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

final WARC_NAME = "gmodwiki";

final WARC_EXT = ".warc";

final WARC_EXT_ZIPPED = ".warc.gz";

//append to warc
class Main {

    static function parseWorker(dbConnection:data.WikiDB,warcParse:WARCParser,contentParse:ContentParser) {
        function processWARC(data:WARCResult) {
            return if (data != null) {
                contentParse.parse(dbConnection,data).next(_ -> warcParse.parse().toPromise().next(processWARC));
            } else {
                Promise.resolve(true);
            }
        }
        return warcParse.parse().toPromise().next(processWARC);
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
            if (resultExists != null) {
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
        var dbConnection = new WikiDB("wiki_db",driver);
        createDBs(dbConnection).handle(_ -> {
            #if linkage
            linkMain(dbConnection);
            #elseif test
            var contentParser = Creation.contentParserTest();
            contentParser.parseTest(dbConnection).handle(_ -> {
            });
            #else
            var contentParser = Creation.contentParser();
            for (warcFileName in findAvaliableWarcs()) {
                var warc = new WARCParser(Fs.createReadStream(warcFileName));
                parseWorker(dbConnection,warc,contentParser).handle((outcome) -> {
                    switch (outcome) {
                        case Success(_):
                            linkMain(dbConnection);
                            trace("Poggers completed");
                        case Failure(failure):
                            trace(failure.callStack);
                            trace('grr failure $failure');
                    }
                });
            }
            #end
        });
    }
}
