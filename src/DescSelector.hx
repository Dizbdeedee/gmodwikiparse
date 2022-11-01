import cheerio.lib.cheerio.Cheerio;

using Lambda;

import WikiDB.DescLink;

abstract class DescSelector {
	public function new() {};

	public abstract function testElement(elem:Cheerio<Dynamic>):Bool;

	public function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
			{
				id: 999,
				textValue: "placeholder",
				type: 999,
				nextDesc: 999
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
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("p");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
            [{id : null, textValue : null,type : DESCRIPTION_BREAK_ABOVE, nextDesc : null}],
            DescriptionParser2.makeDescParser2().parseDescNode(elem),
            [{id : null, textValue : null,type : DESCRIPTION_BREAK_BELOW, nextDesc : null}]
        ] : Array<Array<DescLink>>).flatten();
        // return if (elem.contents().length > 0) {
        //     ([
        //         [{
        //         id : null,
        //         textValue : null,
        //         type : DESCRIPTION_BREAK_ABOVE,
        //         nextDesc: null
        //     }],DescriptionParser2.makeDescParser2().parseDescNode(elem)] 
        //     : Array<Array<DescLink>> ).flatten();
        // } else {
        //     [{
		// 		id: null,
		// 		textValue: elem.text(),
		// 		type: DESCRIPTION_BREAK,
		// 		nextDesc: null
		// 	}];
        // }
	}
}

class NoteSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".note");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_NOTE,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_NOTE,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class WarnSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".warning");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_WARNING,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_WARNING,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class BugSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".bug");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_BUG,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_BUG,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class DeprecatedSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".deprecated");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_DEPRECATED,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_DEPRECATED,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class RemovedSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".removed");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_REMOVED,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_REMOVED,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class InternalSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".internal");
	}
	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_INTERNAL,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[
				{
					id: null,
					textValue: null,
					type: END_INTERNAL,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class ListSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("ul");
	}
	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return ([
			[
				{
					id: null,
					textValue: null,
					type: BEGIN_LIST,
					nextDesc: null
				}
			],
			DescriptionParser2.makeDescParser2().parseDescNode(elem),
			[
				{
					id: null,
					textValue: null,
					type: END_LIST,
					nextDesc: null
				}
			]
		] : Array<Array<DescLink>>).flatten();
	}
}

class ListItemSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("li");
	}
	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [{
			id : null,
			textValue: elem.text(),
			type : LIST_ITEM,
			nextDesc : null
		}];
	}
}

class LuaCodeSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".code.code-lua");
	}

	override function parse(elem:Cheerio<Dynamic>) {
		
		return ([
		[{
			id : null,
			textValue : null,
			type : BEGIN_LUA_CODE,
			nextDesc : null,
		}],
		DescriptionParser2.makeDescParser2().parseDescNode(elem),
		[{
			id : null,
			textValue : null,
			type : END_LUA_CODE,
			nextDesc : null
		}]
		] : Array<Array<DescLink>>).flatten();
	}
}

class HeadingWithSectionSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("h2 + div");
	}

	override function getNoTraversalElements() {
		return 2;
	}
}

class ValidateSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".validate");
	}

	override function parse(elem:Cheerio<Dynamic>) {
		return ([
			[{
				id : null,
				textValue : null,
				type : BEGIN_VALIDATE,
				nextDesc : null
			}],
			DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner")),
			[{
				id : null,
				textValue : null,
				type : END_VALIDATE,
				nextDesc : null
			}]
		] : Array<Array<DescLink>>).flatten();
	}
}

class TitleSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("h1");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [{
			id : null,
			textValue : elem.text(),
			type : TITLE,
			nextDesc : null
		}];
	}
}

class HeadingSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("h2");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [{
			id : null,
			textValue : elem.text(),
			type : HEADING,
			nextDesc : null
		}];
	}
}

class AnchorSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("a.anchor_offset");
	}

	override function parse(elem:Cheerio<Dynamic>) {
		return [];
	}
}

class ImageSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("div.image");
	}

	override function parse(elem:Cheerio<Dynamic>) {
		return [];
	}
}

class ImgSelector extends DescSelector {
    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("img");
    }

	override function parse(elem:Cheerio<Dynamic>) { 
		return [];
	}
}

class TextSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.get(0).type == "text";
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		// trace(elem);
		return [
			{
				id: null,
				textValue: elem.get(0).data,
				type: DESCRIPTION,
				nextDesc: null
			}
		];
	}
}

class LinkSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is('a[class!="anchor_offset"]');
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
			{
				id: null,
				textValue: elem.text(),
				type: LINK_TEXT,
				nextDesc: null
			},
			{
				id: null,
				textValue: elem.attr("href"),
				type: LINK_URL,
				nextDesc: null
			}
		];
	}
}

class TableSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("table");
	}

	override function parse(elem:Cheerio<Dynamic>) {
		return [];
	}
}

class CodeTagSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("code");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
		{
			id : null,
			textValue : null, 
			type : BEGIN_CODE,
			nextDesc : null
		},
		{
			id : null,
			textValue : elem.text(),
			type : DESCRIPTION,
			nextDesc : null
		},
		{
			id : null,
			textValue : null,
			type : END_CODE,
			nextDesc : null
		}
		];
	}
}

class StrongSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("strong");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
			{
				id : null,
				textValue : null,
				type : BEGIN_STRONG,
				nextDesc : null
			},
			{
				id : null,
				textValue : elem.text(),
				type : DESCRIPTION,
				nextDesc : null
			},
			{
				id : null,
				textValue : elem.text(),
				type : END_STRONG,
				nextDesc : null
			}
		];
	}
}

class BRSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("br");
	}
}

class JSCodeSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is(".code.code-javascript");
	}
}

class BoldSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("b");
	}
}

class KeySelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("span.key");
	}

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
			{
				id : null,
				textValue : elem.text(),
				type : DESCRIPTION,
				nextDesc : null
			}
		];
	}
}

class CodeFeatureSelector extends DescSelector {
	function testElement(elem:Cheerio<Dynamic>) {
		return elem.is("span") && elem.parent().is(".code");
	}

	//we don't care about these span elements currently. at least for my use case, markdown will handle the difficult stuff
	override function parse(elem:Cheerio<Dynamic>) {
		return DescriptionParser2.makeDescParser2().parseDescNode(elem);
	}
}

class ItalicsSelector extends DescSelector {
    function testElement(elem:Cheerio<Dynamic>) {
        return elem.is("em");
    }

	override function parse(elem:Cheerio<Dynamic>):Array<DescLink> {
		return [
			{
				id : null,
				textValue : elem.text(),
				type : DESCRIPTION,
				nextDesc : null
			}
		];
	}
}
