package;

using tink.CoreApi;
import Util.PromiseArray;
import js.node.Fs;
import haxe.Template;
import haxe.io.Path;
import typelink.HaxeTypeCategories;
import StringBuf;

@:await class Generation {


    static final LOCATION_LOCATIONS = "locations";
    static final LOCATION_TRANSFORMATIONS = "transformations";
    static final LOCATION_HAXETYPECATEGORIES = "haxetypecategories";

    static final HEAD_PREFIX = "gmod_";
    static final HEAD_CLIENT = '#if ${HEAD_PREFIX}client';
    static final HEAD_SERVER = '#if ${HEAD_PREFIX}server';
    static final HEAD_MENU = '#if ${HEAD_PREFIX}menu';

    final templates:Templates;

    public function new(_templates:Templates) {
        templates = _templates;
    }

    public function readTypeCategories(dbConnection:data.WikiDB) {
        var processSQLProm = new PromiseArray();
        var readDir = Fs.readdirSync(LOCATION_HAXETYPECATEGORIES);
        for (sqlFileName in readDir) {
            var sqlBuf = Fs.readFileSync(Path.join([LOCATION_HAXETYPECATEGORIES,sqlFileName]));
            var sql = sqlBuf.toString();
            processSQLProm.add(dbConnection.__pool.executeSql(sql));
        }
        return @:await processSQLProm.inSequence().noise();
    }

    @:async public function writeGClasses(dbConnection:data.WikiDB) {
        var allGClassProcessProm = new PromiseArray();
        var allGClass = @:await dbConnection.GClass.all();
        for (gclass in allGClass) {
            allGClassProcessProm.add(processGClass(dbConnection,gclass));
        }
        var awaitResult = @:await allGClassProcessProm.inSequence();
        return Noise;
    }

    @:async public function writeAllLibraries(dbConnection:data.WikiDB) {
        var allLibrariesProcessProm = new PromiseArray();
        var allLibraries = @:await dbConnection.Library.all();
        for (library in allLibraries) {
            allLibrariesProcessProm.add(processLibrary(dbConnection,library));
        }
        var awaitResult = @:await allLibrariesProcessProm.inSequence();
        return Noise;
    }

    @:async function processGClass(dbConnection:data.WikiDB,gclass:data.WikiDB.GClass) {
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

    @:async function processLibrary(dbConnection:data.WikiDB,library:data.WikiDB.Library):Noise {
        var allFunctionsProm = new PromiseArray();
        var generatedFunctionsProm = new PromiseArray();
        var linksArr = @:await dbConnection.Link_LibraryOwns.where(Link_LibraryOwns.libraryID == library.id).all();
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

    @:async function generateFunction(dbConnection:data.WikiDB,func:data.WikiDB.Function):Noise {
        var allFuncArgsProm = new PromiseArray();
        var allFuncRetsProm = new PromiseArray();
        var funcArgs = @:await dbConnection.FunctionArg.where(FunctionArg.funcid == func.id).all();
        var funcRets = @:await dbConnection.FunctionRet.where(FunctionRet.funcid == func.id).all();
        for (funcArg in funcArgs) {
            allFuncArgsProm.add(preGenerateFuncArg(dbConnection,funcArg));
        }
        for (funcRet in funcRets) {
            allFuncRetsProm.add(preGenerateFuncRet(dbConnection,funcRet));
        }
        var preGenFuncArgsArr = @:await allFuncArgsProm.inSequence();
        var lenFuncArgs = preGenFuncArgsArr.length;
        var varListBuilder = new StringBuf();
        for (i in 0...lenFuncArgs) {
            var partialStr = if (i == lenFuncArgs - 1) {
                templates.funcArgEndTemplate.execute(preGenFuncArgsArr[i]);
            } else {
                templates.funcArgTemplate.execute(preGenFuncArgsArr[i]);
            }
            varListBuilder.add(partialStr);
        }
        var varList = varListBuilder.toString();
        var preGenFuncRetsArr = @:await allFuncRetsProm.inSequence();
        trace(varList);
        return Noise;
    }

    @:async function preGenerateFuncArg(dbConnection:data.WikiDB,funcArg:data.WikiDB.FunctionArg):PreGeneratedFuncArg {
        var typeLink = @:await dbConnection.Link_FunctionArgTypeResolve.where(Link_FunctionArgTypeResolve.funcArgNo == funcArg.id).first();
        var type = @:await dbConnection.Link_ResolvedTypes.where(Link_ResolvedTypes.typeID == typeLink.typeID).first();
        var typeNameCanoc = @:await processTypeName(dbConnection,type.name,type.typeCategory);
        // var result = funcArgTemplate.execute({
        //     varName: funcArg.name,
        //     type: typeNameCanoc
        // });
        return {
            varName: funcArg.name,
            type: typeNameCanoc
        };
    }

    @:async function preGenerateFuncRet(dbConnection:data.WikiDB,funcRet:data.WikiDB.FunctionRet):Noise {
        var typeLink = @:await dbConnection.Link_FunctionRetTypeResolve.where(Link_FunctionRetTypeResolve.funcRetID == funcRet.id).first();
        var type = @:await dbConnection.Link_ResolvedTypes.where(Link_ResolvedTypes.typeID == typeLink.typeID).first();
        var typeNameCanoc = @:await processTypeName(dbConnection,type.name,type.typeCategory);
        return Noise;
    }

    @:async function processTypeName(dbConnection:data.WikiDB,typeName:String,typeCat:Int):String {
        var typeCategory = @:await dbConnection.Link_HaxeTypeCategory.where(Link_HaxeTypeCategory.id == typeCat).first();
        return switch (typeCategory) {
            case {isReplacement: false, location: loc}:
                '$loc$typeName';
            case {isReplacement: true, location: newType}:
                newType;
        }
    }

}

enum DisplayType {
    NoMenu;
    Menu;
}

typedef GeneratedLibrary = {
    beginHeader : String,
    allPartialContent : String,
    libraryName : String,
    endHeader : String
}

typedef GeneratedGClass = {
    comment : String,
    beginHeader : String,
    allPartialContent : String,
    gclassName : String,
    endHeader : String
}

typedef GeneratedGClassFunction = {
    beginHeader : String,
    isPrivate : String,
    funcName : String,
    varList : String,
    typeOutput : String,
    endHeader : String
}

typedef GeneratedLibraryFunction = {
    beginHeader : String,
    funcName : String,
    varList : String,
    typeOutput : String,
    endHeader : String
}

typedef PreGeneratedLibrary = {
    beginHeader : String,
    allPartialContent : Array<PreGeneratedLibraryFunction>,
    libraryName : String,
    endHeader : String
}

typedef PreGeneratedGClass = {
    beginHeader : String,
    allPartialContent : Array<PreGeneratedGClassFunction>,
    libraryName : String,
    endHeader : String
}

typedef PreGeneratedGClassFunction = {
    beginHeader : String,
    isPrivate : String,
    funcName : String,
    varList : String,
    typeOutput : String,
    endHeader : String,

}

typedef PreGeneratedLibraryFunction = {
    beginHeader : String,
    funcName : String,
    varList : String,
    typeOutput : String,
    endHeader : String
}

typedef PreGeneratedFuncArg = {
    varName : String,
    type : String
}