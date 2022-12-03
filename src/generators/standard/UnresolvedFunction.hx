package generators.standard;


interface FunctionArgResolver {
    function resolve(inp:Cheerio<Dynamic>):Array<UnresolvedFunctionArg>;
}

interface FunctionRetResolver {
    function resolve(inp:Cheerio<Dynamic>):Array<UnresolvedFunctionRet>;
}

typedef UnresolvedFunction = {
    // var id:Null<Id<Function>>;
    var name:VarChar<255>;
    var url:VarChar<1024>;
    var ?description:DescriptionResolver;
    var isHook:Bool;
    var stateClient:Bool;
    var stateMenu:Bool;
    var stateServer:Bool;

}

typedef UnresolvedFunctionArg = {
    var argumentNo:SmallInt;
    // var funcid:Promise<Id<Function>>;
    var name:VarChar<255>;
    var type:VarChar<255>;
    var typeURL:VarChar<255>;
    var ?def:VarChar<255>;
    var ?description:DescriptionResolver;
}

typedef UnresolvedFunctionRet = {
    var returnNo:SmallInt;
    // var funcid:Promise<Id<Function>>;
    var type:VarChar<255>;
    var typeURL:VarChar<255>;
    var ?desc:DescriptionResolver;
}