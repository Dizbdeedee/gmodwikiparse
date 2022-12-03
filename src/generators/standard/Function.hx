package generators.standard;

class Function {}

interface FunctionPublisher {
    function publishFunction(funcCreate:WikiDB.FunctionCreation):Promise<Noise>;
}

class FunctionPublisherDef {
    final dbConnection:WikiDB;

    final functionParser:FunctionParser;

    public function new(_dbConnection:WikiDB,_functionParser:FunctionParser) {
        dbConnection = _dbConnection;
    }

    @:async public function publishFunction(url:String,jq:CheerioAPI) {
        var create = @:await parseFunction(url,jq);
        var funcID = @:await dbConnection.Function.insertOne(create.func);
        var mappedFuncArgs = create.funcargs.map((funcarg) -> {
            var copy = Reflect.copy(funcarg);
            untyped copy.funcid = funcID;
            return copy;
        });
        var mappedFuncRets = create.funcrets.map((funcret) -> {
            var copy = Reflect.copy(funcret);
            untyped copy.funcid = funcID;
            return copy;
        });
        var mappedLuaExamples = create.luaexamples.map((luaexample) -> {
            var copy = Reflect.copy(luaexample);
            untyped copy.funcid = funcID;
            return copy;
        });
        @:await dbConnection.FunctionArg.insertMany(mappedFuncArgs).eager();
        @:await dbConnection.FunctionRet.insertMany(mappedFuncRets).eager();
        @:await dbConnection.LuaExample.insertMany(mappedLuaExamples).eager();
        return Noise;
    }

}
