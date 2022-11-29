package generators.desc;

import cheerio.lib.cheerio.Cheerio;
import cheerio.lib.load.CheerioAPI;
import generators.desc.DescSelector;
import data.WikiDB.DescItem;
using js.lib.HaxeIterator;
using Lambda;

private typedef ParseResult = {
    traverseElements : Int,
    generatedDescs : Array<DescItem>
}

interface DescriptionParser {
    function parseDescNode(descNode:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem>;
}

class DescriptionParserDef implements DescriptionParser {

    final selectors:Array<DescSelector>;

    public function new(_selectors:Array<DescSelector>) {
        selectors = _selectors;
    }

    function parse(node:Cheerio<Dynamic>,jq:CheerioAPI):ParseResult {
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
            throw "No elements matched!";
        }
        var chosenSelector = selectors[results[0]];
        return {
            generatedDescs : chosenSelector.parse(node,jq),
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
                return true;
            }
            var cheerEl = jq.call(el);
            final results = parse(cheerEl,jq);
            allDescriptions = allDescriptions.concat(results.generatedDescs);
            skipElements = results.traverseElements;
            return true;
        });
        return allDescriptions;
    }
}