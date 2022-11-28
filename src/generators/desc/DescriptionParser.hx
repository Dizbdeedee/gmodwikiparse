package generators.desc;

using Lambda;
import cheerio.lib.cheerio.Cheerio;
import DescSelector;
import WikiDB.DescItem;
using js.lib.HaxeIterator;


private typedef ParseResult = {
    traverseElements : Int,
    generatedDescs : Array<DescItem>
}

interface DescriptionParser {
    function parseDescNode(descNode:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem>;
}

class DescriptionParserDef {

    final selectors:Array<DescSelector>;

    // //will forget to update. macros are tempting
    // public static function defaultDescParser():DescriptionParser {
    //     return new DescriptionParser(defaultDescParser());
    // }

    public function new(selectors:Array<DescSelector>) {
        // selectors = _selectors();
        selectors = _selectors;
    }

    function parse(node:Cheerio<Dynamic>):ParseResult {
        var results:Array<Int> = [];
        for (i in 0...selectors.length) {
            if (selectors[i].testElement(node)) {
                results.push(i);
            }
        }
        if (results.length > 1) {
            trace("Too many elements matched!");
            trace(node);
            for (selectorI in results) {
                trace(Type.getClassName(Type.getClass(selectors[selectorI])));
            }
            throw "Too many elements matched!";
        } else if (results.length == 0) {
            trace("No elements matched!");
            trace(node);
            throw "No elements matched!;
        }
        var chosenSelector = selectors[results[0]];
        return {
            generatedDescs : chosenSelector.parse(node),
            traverseElements : chosenSelector.getNoTraversalElements()
        }
    }

    public function parseDescNode(descNode:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        var curNode:Cheerio<Dynamic> = descNode.contents();
        var allDescriptions:Array<DescItem> = [];
        var skipElements = 1;
        curNode.each(function (_,el) {
            if (skipElements > 1) {
                skipElements--;
                return null;
            }
            var cheerEl = jq.call(el);
            final results = parse(cheerEl);
            allDescriptions = allDescriptions.concat(results.generatedDescs);
            skipElements = results.traverseElements;
            return true;
        });
        return allDescriptions;
    }


}