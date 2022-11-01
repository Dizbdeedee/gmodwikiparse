package;

import WikiDB.DescLink;
import cheerio.lib.cheerio.Cheerio;
using tink.CoreApi;

class DescriptionParser {



    static function parseP(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseNote(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseWarn(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }
    
    static function parseInternal(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseBug(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseDeprecated(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseRemoved(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseList(elem:Cheerio<Dynamic>):DescLink {
        // trace(elem.text());
        return null;
    }

    static function parseLuaExample(elem:Cheerio<Dynamic>):DescLink {
        trace("LUAEXAMPLE");
        // trace(elem.text());
        return null;
    }

    static function parseHeading(elem:Cheerio<Dynamic>,div:Cheerio<Dynamic>):DescLink {
        trace("HEADING");
        return null;
    }

    static function parseValidate(elem:Cheerio<Dynamic>):DescLink {
        trace("Validate");
        return null;
    }

    static function parseTitle(elem:Cheerio<Dynamic>):DescLink {
        trace("title");
        return null;
    }
    static function parseText(elem:Cheerio<Dynamic>):DescLink {
        trace("TEXT");
        trace(elem.text());
        return null;
    }

    static function parseLink(elem:Cheerio<Dynamic>):DescLink {
        trace("link!");
        return null;
    }

    //simplicity killed the cat
    static function parseChoose(elem:Cheerio<Dynamic>):Cheerio<Dynamic> {
        var p = elem.is("p");
        var note = elem.is(".note");
        var warn = elem.is(".warning");
        var internal = elem.is(".internal");
        var bug = elem.is(".bug");
        var deprecated = elem.is(".deprecated");
        var removed = elem.is(".removed");
        var list = elem.is("ul"); // https://wiki.facepunch.com/gmod/DNumberScratch:GetFraction
        var luaExample = elem.is(".code.code-lua"); //https://wiki.facepunch.com/gmod/Entity:GetSaveTable
        var heading = if (elem.next() != null) { //https://wiki.facepunch.com/gmod/ENTITY:OnRemove 
            elem.next().is("h2 + div");
        } else {
            false;
        }
        var validate = elem.is(".validate"); //https://wiki.facepunch.com/gmod/Entity:SetPreventTransmit
        var title = elem.is("h1"); //https://wiki.facepunch.com/gmod/Global.Either
        var anchor = elem.is("a.anchor_offset"); //https://wiki.facepunch.com/gmod/Global.Either -- an anchor link. we need to be careful here
        var image = elem.is("div.image"); //https://wiki.facepunch.com/gmod/surface.DrawTexturedRectUV -- ambitious aren't we?
        var text = if (elem.length == 1) {
            elem.get(0).type == "text";
        } else {
            false;
        }
        var link = elem.is("a.link-page");
        var table = elem.is("table");
        var nextNode = switch [p,note,warn,internal,bug,deprecated,
        removed,list,luaExample,heading,validate,
        title,anchor,image,text,link,
        table] {
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                trace("No elements matched!");
                trace(elem);
                throw "No elements matched!";
            case [p = true,false,false,false,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseP(elem);
                elem.next();
            case [false,note = true,false,false,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseNote(elem);
                elem.next();
            case [false,false,warn = true,false,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseWarn(elem);
                elem.next();
            case [false,false,false,internal = true,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseInternal(elem);
                elem.next();
            case [false,false,false,false,bug = true,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseBug(elem);
                elem.next();
            case [false,false,false,false,false,deprecated = true,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseDeprecated(elem);
                elem.next();
            case [false,false,false,false,false,false,
                removed = true,false,false,false,false,
                false,false,false,false,false,
                false]:
                parseRemoved(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,list = true,false,false,false,
                false,false,false,false,false,
                false]:
                parseList(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,luaExample = true,false,false,
                false,false,false,false,false,
                false]:
                parseList(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,false,heading = true,false,
                false,false,false,false,false,
                false]:
                parseHeading(elem,elem.next());
                elem.next().next();
            case [false,false,false,false,false,false,
                false,false,false,false,validate = true,
                false,false,false,false,false,
                false]:
                parseValidate(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                title = true,false,false,false,false,
                false]:
                parseTitle(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,anchor = true,false,false,false,
                false]:
                elem.next(); //ignore anchor
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,false,image = true,false,false,
                false]:
                elem.next(); //actually, we aren't
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,false,false,text = true,false,
                false]:
                parseText(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,false,false,false,link = true,
                false]:
                parseLink(elem);
                elem.next();
            case [false,false,false,false,false,false,
                false,false,false,false,false,
                false,false,false,false,false,
                false]:
                elem.next();
            default:
                trace("Too many elements!");
                throw elem;
        }
        return nextNode;
    }

    public static function parseDescription(descNode:Cheerio<Dynamic>) {
        var curNode:Cheerio<Dynamic> = descNode.contents();
        
        while (curNode.length > 0) {
            curNode = parseChoose(curNode);

            // curNode = curNode.next(); //is it a cheerio? is it not?? WHO KNOWS
        }
    }
    
}