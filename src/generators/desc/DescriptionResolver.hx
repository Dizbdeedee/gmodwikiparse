package generators.desc;

import cheerio.lib.cheerio.Cheerio;
import cheerio.lib.load.CheerioAPI;

interface DescriptionResolver {
    function setParse(inp:Cheerio<Dynamic>):Void;
    function resolve(jq:CheerioAPI):Promise<Id<DescriptionStorage>>;
}

class DescriptionResoverDef {

    final descParser:DescriptionParser;

    final descPublisher:DescriptionPublisher;

    var parseInput:Cheerio<Dynamic>;

    public function new(_descParser:DescriptionParser,_descPublisher:DescriptionPublisher) {
        descParser = _descParser;
        descPublisher = _descPublisher;
    }

    public function setParse(inp:Cheerio<Dynamic>):Void {
        parseInput = inp;
    }

    public function resolve(jq:CheerioAPI):Promise<Id<DescriptionStorage>> {
        return descPublisher.publish(descParser.parseDescNode(parseInput,jq));
    }
}