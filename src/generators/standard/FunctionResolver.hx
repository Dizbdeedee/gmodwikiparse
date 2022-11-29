package generators.standard;



function parseMultipleReturns(rets:Cheerio<Dynamic>):Promise<Array<WikiDB.FunctionRet>> {
    var funcRets:Array<Promise<WikiDB.FunctionRet>> = [];
    rets.children().each((_,el) -> {
        var cheerEl = ContentParser.jq.call(el);
        funcRets.push(parseReturn(cheerEl));
        return true;
    });
    return Promise.inSequence(funcRets);
}