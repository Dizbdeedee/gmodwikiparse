package typelink;

import js.node.Path;
import data.WikiDB;
import js.node.Fs;
using tink.CoreApi;

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

    static function getFunctionFromLibraryURL(dbConnection:data.WikiDB,liburl:data.WikiDB.LibraryURL):Promise<data.Id<Function>> {
        return dbConnection
        .Function.select({
            functionID: Function.id
        }).where(Function.url == liburl.url)
        .first().next((res) -> {
            return res.functionID;
        });
    }

    // static function insertLibraryOwns():Promise<Noise> {

    // }

    @:async public static function resolveLibraryOwns(dbConnection:data.WikiDB):Promise<Noise> {
        var libraryURLS = @:await dbConnection.LibraryURL.all();
        var funcResults = libraryURLS.map((libURL) ->
        Future.lazy(() -> getFunctionFromLibraryURL(dbConnection,libURL)));
        return Promise.NOISE;
    }


    public static function typeFunctionRets(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.FunctionRet.all()
        .next((functionRetArr) -> {
            var resolvedTypesFuncRet = functionRetArr.map(resolveFuncRetType.bind(_,dbConnection));
            return Promise.inSequence(resolvedTypesFuncRet);
        });
    }

    public static function typeFunctionArgs(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.FunctionArg.all()
        .next((functionArgArr) -> {
            var itemAndTypesFut = functionArgArr.map(linkFunctionArgToType.bind(_,dbConnection));
            return Future.inSequence(itemAndTypesFut);
        })
        .next((itemAndTypeOptArr) -> {
            var itemLinkPromiseArr = [];
            for (i in itemAndTypeOptArr) {
                switch (i) {
                    case Some({typeID : typeID, itemID: funcArgID}):
                        var addLinkPromise = Promise.lazy(() ->
                            dbConnection.Link_FunctionArgTypeResolve.insertOne({funcArgNo: funcArgID, typeID: typeID}));
                        itemAndTypePromiseArr.push(addLinkPromise);
                    default:
                }
            }
            return Promise.inSequence(itemLinkPromiseArr);
        }).noise();
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

    static function resolveFuncRetType(funcRet:data.WikiDB.FunctionRet,dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.Link_ResolvedTypes.select({
            typeID: Link_ResolvedTypes.typeID
        }).where(funcRet.typeURL == Link_ResolvedTypes.url).first()
        .next((result) -> {
            return Promise.NOISE;
        }).recover((err) -> {
            trace('Unmatched funcRet: ${funcRet.typeURL}');
            return Future.NOISE;
        });

    }


}

typedef ItemAndType = {
    itemID : Int,
    typeID : Int
}