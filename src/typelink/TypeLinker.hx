package typelink;

import js.node.Path;
import data.WikiDB;
import js.node.Fs;
using tink.CoreApi;

class TypeLinker {
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

    public static function typeLinkage(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.GClass.all().next(
        (arr) -> {
            var resolvedTypes:Array<data.WikiDB.Link_ResolvedTypes> = arr.map(
                (gclass) -> {
                    return {
                        typeID: null,
                        name: gclass.name,
                        url: gclass.url
                    }
                }
            );
            return dbConnection.Link_ResolvedTypes.insertMany(resolvedTypes);
        });
        // dbConnection.Link_ResolvedTypes.insertMany()
    }

    public static function typeNext(dbConnection:data.WikiDB):Promise<Noise> {
        return dbConnection.FunctionArg.all().next(
        (arr) -> {
            // trace(arr);
            var resolvedTypes = [for (funcArg in arr) resolveType(funcArg,dbConnection)];
            return Promise.inSequence(resolvedTypes);
            // var typeLinks:Array<Link_FunctionArgTypeResolve> = arr.map((funcArg) -> {
            //     var resolvedType = dbConnection.Link_ResolvedTypes
            //     return {
            //         funcArgNo: funcArg.argumentNo,
            //         funcid: funcArg.funcid,
            //         typeID: 
            //     }
            // });
            // return Promise.NOISE;
        });
    }

    static function resolveType(funcArg:data.WikiDB.FunctionArg,dbConnection:data.WikiDB):Promise<Noise> {
        // trace(funcArg);
        return dbConnection.Link_ResolvedTypes.select({
            typeID: Link_ResolvedTypes.typeID
        }).where(funcArg.typeURL == Link_ResolvedTypes.url).first()
        .next((result) -> {
            // trace(result);
            return Promise.NOISE;
        }).recover((err) -> {
            trace(funcArg.typeURL);
            // trace(err);
            return Future.NOISE;
        });
    }
}