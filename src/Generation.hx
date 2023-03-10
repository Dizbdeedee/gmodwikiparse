package;

using tink.CoreApi;

import Util.PromiseArray;
@:await class Generation {

    @:async public static function writeGClasses(dbConnection:data.WikiDB) {
        var allOwnsProm:PromiseArray<Array<Any>> = new PromiseArray();
        var allGClassProcessProm = new PromiseArray();
        var ownedFuncsProm = new PromiseArray();
        var allGClass = @:await dbConnection.GClass.all();
        trace(allGClass);
        for (gclass in allGClass) {
            allGClassProcessProm.add(processGClass(dbConnection,gclass));
        }
        var _ = @:await allGClassProcessProm.inSequence();
        // var allOwnsArr:Array<Array<Any>> = @:await allOwnsProm.inSequence();
        // for (owns in allOwnsArr) {
        //     ownedFuncsProm.add(dbConnection.Function.where(Function.id == owns.funcID).first());
        // }
        // var ownedFuncsArr = @:await ownedFuncsProm.inSequence();
        // trace(ownedFuncsArr);
        // return Noise;
        return Noise;

    }

    @:async static function processGClass(dbConnection:data.WikiDB,gclass:data.WikiDB.GClass) {
        var allFunctionsPro = new PromiseArray();
        trace(gclass);
        var linksArr = @:await dbConnection.Link_GClassOwns.select({funcID: Link_GClassOwns.funcID}).where(Link_GClassOwns.gclassID == gclass.id).all();
        for (link in linksArr) {
            allFunctionsPro.add(dbConnection.Function.select({name: Function.name}).where(Function.id == link.funcID).first());
        }
        var allFunctionsArr = @:await allFunctionsPro.inSequence();
        for (func in allFunctionsArr) {
            trace('${gclass.name} ${func.name}');
        }
        return Noise;
    }


}