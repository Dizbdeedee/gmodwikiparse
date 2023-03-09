package typelink;

import js.node.Path;
import data.WikiDB;
import js.node.Fs;
using tink.CoreApi;
import Util.FutureArray;
import Util.PromiseArray;

@:await class TypeLinker {

    public function new() {

    }

    public static function addLuaTypes(db:WikiDB) {
        return new Promise(function (success,failure) {
            var str = Fs.readdirSync("luatypes");
            var it = str.iterator();
            var cancel = false;
            function iterate(prevOutcome) {
                if (cancel) return;
                switch(prevOutcome) {
                    case null:
                    case Failure(fail):
                        failure(fail);
                    case Success(_):
                }
                if (!it.hasNext()) {
                    success(Noise);
                } else {
                    var sqlFilename = it.next();
                    var sql = Fs.readFileSync(Path.join("luatypes",sqlFilename)).toString();
                    db.__pool.executeSql(sql).handle(iterate);
                }
            }
            iterate(null);
            return () -> cancel = true;
        });
    }

    public static function addGClasses(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.GClass.all()
        .next((arr) -> {
            var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> =
                arr.map((gclass) ->
                    {
                        typeID: null,
                        name: gclass.name,
                        url: gclass.url
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
                    url: panel.url
                });
            return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
        });
    }

    @:async
    static function getFunctionFromLibraryURL(dbConnection:data.WikiDB,liburl:data.WikiDB.LibraryURL):data.Id<Function> {
        var res = @:await dbConnection.Function.select({
            functionID: Function.id
        }).where(Function.url == liburl.url).first();
        return res.functionID;
    }

    @:async
    static function insertLibraryOwns(dbConnection:data.WikiDB,funcID:Int) {
        return Noise;
    }

    @:async public static function resolveLibraryOwns(dbConnection:data.WikiDB) {
        var libraryURLS = @:await dbConnection.LibraryURL.all();
        var funcIDArrPro = [];
        for (libURL in libraryURLS) {
            funcIDArrPro.push(Promise.lazy(() -> getFunctionFromLibraryURL(dbConnection,libURL)));
        }
        var funcIDArr = @:await Promise.inSequence(funcIDArrPro);
        var allLibrariesInserted = [];
        for (funcID in funcIDArr) {
            allLibrariesInserted.push(Promise.lazy(() -> insertLibraryOwns(dbConnection,funcID)));
        }
        var noise = @:await Promise.inSequence(allLibrariesInserted).noise();
        return noise;
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
        var allLinksAdded = @:await addLinkProm.inSequence();
        return allLinksAdded;
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
        return dbConnection.Link_ResolvedTypes.select({
            typeID: Link_ResolvedTypes.typeID
        }).where(funcArg.typeURL == Link_ResolvedTypes.url).first()
        .next((result) -> {
            return Some({typeID: result.typeID, itemID: funcArg.id});
        }).recover((err) -> {
            trace('Unmatched funcArg: ${funcArg.typeURL}');
            // trace(err);
            return None;
        });
    }

    static function linkFunctionRetToType(funcRet:data.WikiDB.FunctionRet,dbConnection:data.WikiDB):Future<haxe.ds.Option<ItemAndType>> {
        return dbConnection.Link_ResolvedTypes.select({
            typeID: Link_ResolvedTypes.typeID
        }).where(funcRet.typeURL == Link_ResolvedTypes.url).first()
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