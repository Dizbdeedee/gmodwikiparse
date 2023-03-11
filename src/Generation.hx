package;

using tink.CoreApi;
import Util.PromiseArray;
import js.node.Fs;
import haxe.Template;
import haxe.io.Path;

@:await class Generation {

    static final LOCATION_LOCATIONS = "locations";
    static final LOCATION_TEMPLATES = "templates";
    static final LOCATION_TRANSFORMATIONS = "transformations";

    static final HEAD_PREFIX = "gmod_";
    static final HEAD_CLIENT = '#if ${HEAD_PREFIX}client';
    static final HEAD_SERVER = '#if ${HEAD_PREFIX}server';
    static final HEAD_MENU = '#if ${HEAD_PREFIX}menu';

    static final gclassTemplate = _gclassTemplate();
    static function _gclassTemplate() {
        var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES,"GClass.template"])).toString();
        return new haxe.Template(file);
    }
    static final funcArgTemplate = _funcArgTemplate();
    static function _funcArgTemplate() {
        var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES,"Variable.template"])).toString();
        return new haxe.Template(file);
    }

    static final locations = {
        var effectsLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"effects.txt"]));
        var enumLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"enum.txt"]));
        var gclassLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"gclass.txt"]));
        var globalsLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"globals.txt"]));
        var structLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"struct.txt"]));
        var libraryLoc = Fs.readFileSync(Path.join([LOCATION_LOCATIONS,"library.txt"]));
        {
            effects: effectsLoc,
            genum: enumLoc,
            gclass: gclassLoc,
            globals: globalsLoc,
            struct: structLoc,
            library: libraryLoc
        }
    }

    static final transformations = {
        var transformations:Map<String,String> = [];
        var readDir = Fs.readdirSync(Path.join([LOCATION_TRANSFORMATIONS]));
        for (fileName in readDir) {
            var contents = Fs.readFileSync(Path.join([LOCATION_TRANSFORMATIONS,fileName])).toString();
            transformations.set(StringTools.replace(fileName,".tf",""),contents);
        }
        transformations;
    }

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
        var allFunctionsProm = new PromiseArray();
        var generatedFunctionsProm = new PromiseArray();
        trace(gclass);
        var linksArr = @:await dbConnection.Link_GClassOwns.where(Link_GClassOwns.gclassID == gclass.id).all();
        for (link in linksArr) {
            allFunctionsProm.add(dbConnection.Function.where(Function.id == link.funcID).first());
        }
        var allFunctionsArr = @:await allFunctionsProm.inSequence();
        for (func in allFunctionsArr) {
            generatedFunctionsProm.add(generateFunction(dbConnection,func));
        }
        var results = @:await generatedFunctionsProm.inSequence();
        return Noise;
    }

    @:async static function generateFunction(dbConnection:data.WikiDB,func:data.WikiDB.Function) {
        var allFuncArgsProm = new PromiseArray();
        var funcArgs = @:await dbConnection.FunctionArg.where(FunctionArg.funcid == func.id).all();
        var funcRets = @:await dbConnection.FunctionRet.where(FunctionRet.funcid == func.id).all();
        for (funcArg in funcArgs) {
            allFuncArgsProm.add(getTypeFromFuncArg(dbConnection,funcArg));
        }
        var result = @:await allFuncArgsProm.inSequence();
        return Noise;
    }

    @:async static function getTypeFromFuncArg(dbConnection:data.WikiDB,funcArg:data.WikiDB.FunctionArg) {
        var typeLink = @:await dbConnection.Link_FunctionArgTypeResolve.where(Link_FunctionArgTypeResolve.funcArgNo == funcArg.id).first();
        var type = @:await dbConnection.Link_ResolvedTypes.where(Link_ResolvedTypes.typeID == typeLink.typeID).first();
        var typeNameCanoc = switch (transformations.get(type.name)) {
            case null:
                type.name;
            case newTypeName:
                newTypeName;
        }
        var result = funcArgTemplate.execute({
            varName: funcArg.name,
            type: typeNameCanoc
        });
        trace(result);
        return Noise;
    }

    static function generateHeader(server:Bool,client:Bool,menu:Bool) {

    }
}

enum DisplayType {
    NoMenu;
    Menu;
}