package typelink;

import haxe.io.Path;
import data.WikiDB;
import js.node.Fs;
using tink.CoreApi;
import Util.FutureArray;
import Util.PromiseArray;
import typelink.HaxeTypeCategories;

@:await class TypeLinker {

    static final LOCATION_LUATYPES = "luatypes";

    public function new() {

    }

    @:async public static function addLuaTypes(dbConnection:data.WikiDB):Noise {
        var processSQLProm = new PromiseArray();
        var readDir = Fs.readdirSync(LOCATION_LUATYPES);
        for (sqlFilename in readDir) {
            var sqlBuf = Fs.readFileSync(Path.join([LOCATION_LUATYPES,sqlFilename]));
            var sql = sqlBuf.toString();
            processSQLProm.add(dbConnection.__pool.executeSql(sql));
        }
        return @:await processSQLProm.inSequence().noise();
    }

    public static function addGClasses(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.GClass.all()
        .next((arr) -> {
            var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> =
                arr.map((gclass) ->
                    {
                        typeID: null,
                        name: gclass.name,
                        url: gclass.url,
                        typeCategory: HaxeTypeCategories.gclass
                    }
                );
            return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
        });
    }

    public static function addPanels(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.Panel.all()
        .next((arr) -> {
            var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> =
                arr.map((panel) -> {
                    typeID: null,
                    name: panel.name,
                    url: panel.url,
                    typeCategory: HaxeTypeCategories.panel
                });
            return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
        });
    }

    static function getFunctionIDLibraryIDLink(dbConnection:data.WikiDB,libURL:data.WikiDB.LibraryURL):Future<Option<FunctionIDLibraryIDLink>> {
        return dbConnection.Function.select({
            functionID: Function.id
        }).where(Function.url == libURL.url)
        .first().next(res -> Some({functionID: res.functionID, libraryID: libURL.libraryID}))
        .recover(_ -> {trace('$libURL not found'); None;});
    }

    @:async
    static function insertLibraryOwns(dbConnection:data.WikiDB,link:FunctionIDLibraryIDLink) {
        return @:await dbConnection.Link_LibraryOwns.insertOne({
            libraryID: link.libraryID,
            funcID: link.functionID
        });
    }

    @:async public static function resolveLibraryOwns(dbConnection:data.WikiDB) {
        var functionIDLibraryIDLinkFut = new FutureArray();
        var librariesInsertedProm = new PromiseArray();

        var libraryURLS = @:await dbConnection.LibraryURL.all();
        for (libURL in libraryURLS) {
            functionIDLibraryIDLinkFut.add(getFunctionIDLibraryIDLink(dbConnection,libURL));
        }
        var linksOptArr = @:await functionIDLibraryIDLinkFut.inSequence();
        for (linkOpt in linksOptArr) {
            switch (linkOpt) {
                case Some(link):
                    librariesInsertedProm.add(insertLibraryOwns(dbConnection,link));
                default:
            }
        }
        return @:await librariesInsertedProm.inSequence().noise();
    }

    static function getFunctionIDGClassIDLink(dbConnection:data.WikiDB,gclassURL:data.WikiDB.GClassURL):Future<Option<FunctionIDGClassIDLink>> {
        return dbConnection.Function.select({
            functionID: Function.id
        }).where(Function.url == gclassURL.url)
        .first().next(res -> Some({functionID: res.functionID, gclassID: gclassURL.gclassID}))
        .recover(_ -> {trace('$gclassURL not found!!'); None;});
    }

    @:async
    static function insertGClassOwns(dbConnection:data.WikiDB,link:FunctionIDGClassIDLink) {
        return @:await dbConnection.Link_GClassOwns.insertOne({
            gclassID: link.gclassID,
            funcID: link.functionID
        });
    }

    @:async public static function resolveGClassOwns(dbConnection:data.WikiDB) {
        var functionIDGClassIDLinkFut = new FutureArray();
        var gclassInsertedProm = new PromiseArray();

        var gclassURLArr = @:await dbConnection.GClassURL.all();
        for (gclassURL in gclassURLArr) {
            functionIDGClassIDLinkFut.add(getFunctionIDGClassIDLink(dbConnection,gclassURL));
        }
        var linksOptArr = @:await functionIDGClassIDLinkFut.inSequence();
        for (linkOpt in linksOptArr) {
            switch (linkOpt) {
                case Some(link):
                    gclassInsertedProm.add(insertGClassOwns(dbConnection,link));
                default:
            }
        }
        return @:await gclassInsertedProm.inSequence().noise();
    }

    @:async public static function typeFunctionArgs(dbConnection:data.WikiDB) {
        var linkedFunctionArgsFut:FutureArray<Option<ItemAndType>> = new FutureArray();
        var addLinkProm = new PromiseArray();

        var allFunctionArgs = @:await dbConnection.FunctionArg.all();
        for (functionArg in allFunctionArgs) {
            linkedFunctionArgsFut.add(linkFunctionArgToType(functionArg,dbConnection));
        }
        var linkedFunctionArgs = @:await linkedFunctionArgsFut.inSequence();
        for (itemAndTypeRes in linkedFunctionArgs) {
            switch(itemAndTypeRes) {
                case Some({typeID : typeID, itemID : funcArgID}):
                    addLinkProm.add(dbConnection.Link_FunctionArgTypeResolve.insertOne({funcArgNo: funcArgID, typeID: typeID}));
                default:
            }
        }
        return addLinkProm.inSequence().noise();
    }

    @:async public static function typeFunctionRets(dbConnection:data.WikiDB) {
        var linkedFunctionRetsFut:FutureArray<Option<ItemAndType>> = new FutureArray();
        var addLinkProm = new PromiseArray();

        var allFunctionRets = @:await dbConnection.FunctionRet.all();
        for (functionRet in allFunctionRets) {
            linkedFunctionRetsFut.add(linkFunctionRetToType(functionRet,dbConnection));
        }
        var linkedFunctionRetsArr = @:await linkedFunctionRetsFut.inSequence();
        for (linkedFunctionRet in linkedFunctionRetsArr) {
            switch (linkedFunctionRet) {
                case Some({typeID : typeID, itemID: funcRetID}):
                    addLinkProm.add(dbConnection.Link_FunctionRetTypeResolve.insertOne({funcRetID: funcRetID, typeID: typeID}));
                default:

            }
        }
        return @:await addLinkProm.inSequence();
    }

    static function linkFunctionArgToType(funcArg:data.WikiDB.FunctionArg,dbConnection:data.WikiDB):Future<haxe.ds.Option<ItemAndType>> {
        return dbConnection.Link_ResolvedTypes.where(funcArg.typeURL == Link_ResolvedTypes.url).first()
        .next((result) -> {
            return Some({typeID: result.typeID, itemID: funcArg.id});
        }).recover((err) -> {
            trace('Unmatched funcArg: ${funcArg.typeURL}');
            // trace(err);
            return None;
        });
    }

    static function linkFunctionRetToType(funcRet:data.WikiDB.FunctionRet,dbConnection:data.WikiDB):Future<haxe.ds.Option<ItemAndType>> {
        return dbConnection.Link_ResolvedTypes.where(funcRet.typeURL == Link_ResolvedTypes.url).first()
        .next((result) -> {
            return Some({typeID: result.typeID, itemID: funcRet.id});
        }).recover((err) -> {
            trace('Unmatched funcRet: ${funcRet.typeURL}');
            // trace(err);
            return None;
        });
    }
}

typedef ItemAndType = {
    itemID : Int,
    typeID : Int
}

typedef FunctionIDLibraryIDLink = {
    functionID: Int,
    libraryID : Int
}

typedef FunctionIDGClassIDLink = {
    functionID: Int,
    gclassID : Int
}