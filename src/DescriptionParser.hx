import cheerio.lib.load.CheerioAPI;
import js.Lib;
import js.Syntax;
using Lambda;
import cheerio.lib.cheerio.Cheerio;
import DescSelector;
import WikiDB.DescLink;
using js.lib.HaxeIterator;
typedef ParseResult = {
    traverseElements : Int,
    generatedDescs : Array<DescLink>
}

class DescriptionParser {

    final selectors:Array<DescSelector>;

    //will forget to update. macros are tempting
    public static function makeDescParser2() {
        return new DescriptionParser([
            new PSelector(),
            new NoteSelector(),
            new WarnSelector(),
            new BugSelector(),
            new DeprecatedSelector(),
            new RemovedSelector(),
            new ListSelector(),
            new LuaCodeSelector(),
            new HeadingSelector(),
            new HeadingWithSectionSelector(),
            new ValidateSelector(),
            new TitleSelector(),
            new AnchorSelector(),
            new ImageSelector(),
            new TextSelector(),
            new LinkSelector(),
            new TableSelector(),
            new CodeTagSelector(), 
            new StrongSelector(),
            new BRSelector(),
            new JSCodeSelector(),
            new KeySelector(),
            new InternalSelector(),
            new ItalicsSelector(),
            new ImgSelector(),
            new ListItemSelector(),
            new CodeFeatureSelector(),
            new BoldSelector()
        ]);
    }

    public function new(_selectors:Array<DescSelector>) {
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
            throw "No elements matched!";
        }
        var chosenSelector = selectors[results[0]];
        return {
            generatedDescs : chosenSelector.parse(node),
            traverseElements : chosenSelector.getNoTraversalElements()
        }
    }

    public function parseDescNode(descNode:Cheerio<Dynamic>):Array<DescLink> {
        var curNode:Cheerio<Dynamic> = descNode.contents();
        var allDescriptions:Array<DescLink> = [];
        var skipElements = 1;
        curNode.each(function (_,el) {
            if (skipElements > 1) {
                skipElements--;
                return null;
            }
            var cheerEl = ContentParser.jq.call(el);
            final results = parse(cheerEl);
            allDescriptions = allDescriptions.concat(results.generatedDescs);
            skipElements = results.traverseElements;
            return true;
        });
        return allDescriptions;
    }
}