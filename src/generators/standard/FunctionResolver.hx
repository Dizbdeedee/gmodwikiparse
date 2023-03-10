package generators.standard;

import generators.desc.UnresolvedDescription;
import generators.standard.UnresolvedFunctionParse.UnresolvedFunction;
import generators.desc.DescriptionPublisher;
import generators.standard.UnresolvedFunctionArgParse.UnresolvedFunctionArg;
import generators.standard.UnresolvedFunctionRetParse.UnresolvedFunctionRet;
import data.Id;
import Util.PromiseArray;
using tink.CoreApi;


interface FunctionResolver {
    function resolve(url:String,jq:CheerioAPI):UnresolvedFunctionPage;
    function publish(conn:data.WikiDB,page:UnresolvedFunctionPage):Promise<Noise>;
}

@:await class FunctionResolverDef implements FunctionResolver {

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

    @:async public function publish(dbConnection:data.WikiDB,page:UnresolvedFunctionPage) {
        var funcArgsPublishProm = new PromiseArray();
        var funcRetsPublishProm = new PromiseArray();
        var funcID = @:await publishFunction(dbConnection,page.func);
        for (pageArg in page.args) {
            funcArgsPublishProm.add(publishFuncArg(dbConnection,funcID,pageArg));
        }
        for (pageRet in page.rets) {
            funcRetsPublishProm.add(publishFuncRet(dbConnection,funcID,pageRet));
        }
        return @:await funcArgsPublishProm.inSequence().next(_ -> funcRetsPublishProm.inSequence()).noise();
    }

    @:async function publishFunction(dbConnection:data.WikiDB,func:UnresolvedFunction) {
        var descID = @:await publishDescOrNull(dbConnection,func.description);
        var insertFunc:data.WikiDB.Function = {
            id: null,
            name: func.name,
            url: func.url,
            description: descID,
            isHook: func.isHook,
            stateClient: func.stateClient,
            stateServer: func.stateServer,
            stateMenu: func.stateMenu,
            isInternal: func.isInternal,
            isDeprecated: func.isDeprecated
        };
        return @:await dbConnection.Function.insertOne(insertFunc);
    }


    function publishDescOrNull(dbConnection:data.WikiDB,unDesc:UnresolvedDescription):Promise<Null<data.Id<data.WikiDB.DescriptionStorage>>> {
        return if (unDesc.length < 1) {
            Promise.resolve(null);
        } else {
            descPublisher.publish(dbConnection,unDesc);
        }
    }

    @:async function publishFuncArg(dbConnection:data.WikiDB,funcID:Int,arg:UnresolvedFunctionArg) {
        var descID = @:await publishDescOrNull(dbConnection,arg.description);
        var insertArg:data.WikiDB.FunctionArg = {
            id: null,
            argumentNo: arg.argumentNo,
            funcid: funcID,
            name: arg.name,
            type: arg.type,
            typeURL: arg.typeURL,
            def: arg.def,
            description: descID
        };
        return @:await dbConnection.FunctionArg.insertOne(insertArg);
    }

    @:async function publishFuncRet(dbConnection:data.WikiDB,funcID:Int,ret:UnresolvedFunctionRet) {
        var descID = @:await publishDescOrNull(dbConnection,ret.description);
        var insertRet:data.WikiDB.FunctionRet = {
            id: null,
            returnNo: ret.returnNo,
            funcid: funcID,
            type: ret.type,
            typeURL: ret.typeURL,
            desc: descID
        };
        return @:await dbConnection.FunctionRet.insertOne(insertRet);
    }
}

typedef UnresolvedFunctionPage = {
    func : UnresolvedFunction,
    args : Array<UnresolvedFunctionArg>,
    rets : Array<UnresolvedFunctionRet>
}