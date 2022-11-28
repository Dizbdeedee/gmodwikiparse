package generators.standard;

class FunctionRetParserDef {

    public function new(descParser:DescriptionParser) {

    }

    public function parse(jq:CheerioAPI) {
        var retNode = getOptCheer(jq,".function_returns");
        var retsArr:Array<WikiDB.FunctionRet> = @:await switch (retNode) {
            case Some(retNode):
                parseMultipleReturns(retNode);
            default:
                Promise.resolve([]);
        }
    }

}