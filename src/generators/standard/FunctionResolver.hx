package generators.standard;

import generators.desc.UnresolvedDescription;
import generators.standard.UnresolvedFunctionParse.UnresolvedFunction;
import generators.desc.DescriptionPublisher;
import generators.standard.UnresolvedFunctionArgParse.UnresolvedFunctionArg;
import generators.standard.UnresolvedFunctionRetParse.UnresolvedFunctionRet;
import data.Id;
using tink.CoreApi;


interface FunctionResolver {
    function resolve(url:String,jq:CheerioAPI):UnresolvedFunctionPage;
    function publish(conn:data.WikiDB,page:UnresolvedFunctionPage):Promise<Noise>;
}

@:await
class FunctionResolverDef implements FunctionResolver {

    final funcParser:UnresolvedFunctionParse;

    final argParser:UnresolvedFunctionArgParse;

    final retParser:UnresolvedFunctionRetParse;

    final descPublisher:DescriptionPublisher;
    
    public function new(_funcParser:UnresolvedFunctionParse,
        _argParser:UnresolvedFunctionArgParse,
        _retParser:UnresolvedFunctionRetParse,
        _descPublisher:DescriptionPublisher) {
            funcParser = _funcParser;
            argParser = _argParser;
            retParser = _retParser;
            descPublisher = _descPublisher;
        }

    public function resolve(url:String,jq:CheerioAPI) {
        final unresolvedFunc = funcParser.parse(url,jq);
        final unresolvedArgs = argParser.parse(jq);
        final unresolvedRets = retParser.parse(jq);
        return {
            func : unresolvedFunc,
            args : unresolvedArgs,
            rets : unresolvedRets
        };
    }

    @:async public function publish(conn:data.WikiDB,page:UnresolvedFunctionPage) {
        var funcID = @:await publishFunction(conn,page.func);
        var promiseArgs = page.args.map((x) -> 
            publishFuncArg(conn,funcID,x));
        var promiseRets = page.rets.map((x) -> publishFuncRet(conn,funcID,x));
        var cumulativePromiseArgs:Promise<Noise> = Promise.NOISE;
        for (p in promiseArgs) {
            cumulativePromiseArgs = cumulativePromiseArgs.next((_) -> p.noise());
        }
        @:await cumulativePromiseArgs.eager();
        var cumulativePromiseRets:Promise<Noise> = Promise.NOISE;
        for (p in promiseRets) {
            cumulativePromiseRets = cumulativePromiseRets.next((_) -> p.noise());
        }
        @:await cumulativePromiseRets.eager();
        // trace("wait forargs");
        // @:await Promise.inSequence(promiseArgs).eager();
        // trace("wait for rets");
        // @:await Promise.inSequence(promiseRets).eager();
        return Noise;
    }

    @:async function publishFunction(conn:data.WikiDB,x:UnresolvedFunction) {
        var descID = @:await publishDescOrNull(conn,x.description);
        return @:await conn.Function.insertOne({
            id : null,
            name : x.name,
            url : x.url,
            description: descID,
            isHook : x.isHook,
            stateClient : x.stateClient,
            stateMenu : x.stateMenu,
            stateServer : x.stateServer
        });
    }

    function publishDescOrNull(conn:data.WikiDB,x:UnresolvedDescription):Promise<Null<data.Id<data.WikiDB.DescriptionStorage>>> {
        return if (x.length < 1) {
            Promise.resolve(null);
        } else {
            descPublisher.publish(conn,x);
        }
    }

    function publishFuncArg(conn:data.WikiDB,funcID:Int,unresolvedArg:UnresolvedFunctionArg) {
        return publishDescOrNull(conn,unresolvedArg.description)
        .next((descID) -> {
            conn.FunctionArg.insertOne({
                argumentNo : unresolvedArg.argumentNo,
                funcid : funcID,
                name : unresolvedArg.name,
                type : unresolvedArg.type,
                typeURL : unresolvedArg.typeURL,
                def : unresolvedArg.def,
                description : descID
            });
        });
    }

    function publishFuncRet(conn:data.WikiDB,funcID:Int,unresolvedRet:UnresolvedFunctionRet) {
        return publishDescOrNull(conn,unresolvedRet.description).next(
        (descID) -> 
            conn.FunctionRet.insertOne({
                returnNo : unresolvedRet.returnNo,
                funcid : funcID,
                type : unresolvedRet.type,
                typeURL : unresolvedRet.typeURL,
                desc : descID
            }));
        
    }
}

typedef UnresolvedFunctionPage = {
    func : UnresolvedFunction,
    args : Array<UnresolvedFunctionArg>,
    rets : Array<UnresolvedFunctionRet>
}