package generators.desc;
import cheerio.lib.cheerio.Cheerio;
import cheerio.lib.load.CheerioAPI;

using Lambda;

import data.WikiDB.DescItem;

abstract class DescSelector {

    public abstract function testElement(elem:Cheerio<Dynamic>):Bool;

    public function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
            {
                id: null,
                textValue: "placeholder",
                type: 999
            }
        ];
    };

    /**
        How many elements are we going to traverse. How many siblings of elements make up this selector?
    **/
    public function getNoTraversalElements() {
        return 1;
    }
}

class PSelector extends DescSelector {
    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("p");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [{id : null, textValue : null,type : DESCRIPTION_BREAK_ABOVE, }],
            descParser.parseDescNode(elem,jq),
            [{id : null, textValue : null,type : DESCRIPTION_BREAK_BELOW, }]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class NoteSelector extends DescSelector {
    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".note");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_NOTE,
                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_NOTE,
                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class WarnSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".warning");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_WARNING,

                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_WARNING,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class BugSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".bug");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_BUG,

                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_BUG,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class DeprecatedSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".deprecated");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_DEPRECATED,

                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_DEPRECATED,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class RemovedSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".removed");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_REMOVED,

                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_REMOVED,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class InternalSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".internal");
    }
    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_INTERNAL,

                }
            ],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_INTERNAL,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class ListSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("ul");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return ([
            [
                {
                    id: null,
                    textValue: null,
                    type: BEGIN_LIST,

                }
            ],
            descParser.parseDescNode(elem,jq),
            [
                {
                    id: null,
                    textValue: null,
                    type: END_LIST,

                }
            ]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class ListItemSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("li");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [{
            id : null,
            textValue: elem.text(),
            type : LIST_ITEM,

        }];
    }
}

class LuaCodeSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".code.code-lua");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {

        return ([
        [{
            id : null,
            textValue : null,
            type : BEGIN_LUA_CODE
        }],
        descParser.parseDescNode(elem,jq),
        [{
            id : null,
            textValue : null,
            type : END_LUA_CODE

        }]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class HeadingWithSectionSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("h2 + div");
    }

    override function getNoTraversalElements() {
        return 2;
    }
}

class ValidateSelector extends DescSelector {

    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".validate");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return ([
            [{
                id : null,
                textValue : null,
                type : BEGIN_VALIDATE,

            }],
            descParser.parseDescNode(elem.children("div.inner"),jq),
            [{
                id : null,
                textValue : null,
                type : END_VALIDATE,

            }]
        ] : Array<Array<DescItem>>).flatten();
    }
}

class TitleSelector extends DescSelector {

    public function new () {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("h1");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [{
            id : null,
            textValue : elem.text(),
            type : TITLE,

        }];
    }
}

class HeadingSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("h2");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [{
            id : null,
            textValue : elem.text(),
            type : HEADING,

        }];
    }
}

class AnchorSelector extends DescSelector {
    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("a.anchor_offset");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return [];
    }
}

class ImageSelector extends DescSelector {
    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("div.image");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return [];
    }
}

class ImgSelector extends DescSelector {

    public function new () {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("img");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return [];
    }
}

class TextSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.get(0).type == "text";
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        // trace(elem);
        return [
            {
                id: null,
                textValue: elem.get(0).data,
                type: DESCRIPTION,

            }
        ];
    }
}

class LinkSelector extends DescSelector {

    public function new () {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is('a[class!="anchor_offset"]');
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
            {
                id: null,
                textValue: elem.text(),
                type: LINK_TEXT,

            },
            {
                id: null,
                textValue: elem.attr("href"),
                type: LINK_URL,

            }
        ];
    }
}

class TableSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("table");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return [];
    }
}

class CodeTagSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("code");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
        {
            id : null,
            textValue : null,
            type : BEGIN_CODE,

        },
        {
            id : null,
            textValue : elem.text(),
            type : DESCRIPTION,

        },
        {
            id : null,
            textValue : null,
            type : END_CODE,

        }
        ];
    }
}

class StrongSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("strong");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
            {
                id : null,
                textValue : null,
                type : BEGIN_STRONG,

            },
            {
                id : null,
                textValue : elem.text(),
                type : DESCRIPTION,

            },
            {
                id : null,
                textValue : elem.text(),
                type : END_STRONG,

            }
        ];
    }
}

class BRSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("br");
    }
}

class JSCodeSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is(".code.code-javascript");
    }
}

class BoldSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("b");
    }
}

class KeySelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("span.key");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
            {
                id : null,
                textValue : elem.text(),
                type : DESCRIPTION,
            }
        ];
    }
}

class CodeFeatureSelector extends DescSelector {
    final descParser:DescriptionParser;

    public function new(_descParser:DescriptionParser) {
        descParser = _descParser;
    }

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("span") && elem.parent().is(".code");
    }

    //we don't care about these span elements currently. at least for my use case, markdown will handle the difficult stuff
    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI) {
        return descParser.parseDescNode(elem,jq);
    }
}

class ItalicsSelector extends DescSelector {

    public function new() {}

    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("em");
    }

    override function parse(elem:Cheerio<Dynamic>,jq:CheerioAPI):Array<DescItem> {
        return [
            {
                id : null,
                textValue : elem.text(),
                type : DESCRIPTION,
            }
        ];
    }
}
