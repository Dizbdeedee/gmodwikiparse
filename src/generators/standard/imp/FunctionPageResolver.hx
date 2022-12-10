package generators.standard.imp;

interface FunctionPageResolver {
    function pageResolve(url:String,jq:CheerioAPI):Promise<Noise>;
}


class FunctionPageResolver {

    public function new(_descriptionParser:DescriptionParser,_functionParser:FunctionParser) {

    }


    public function pageResolve(url:String,jq:CheerioAPI):Promise<Noise> {

    }

}
