import js.html.Text;
import ts.Undefined;
import js.Syntax;
import js.lib.RegExp;
import haxe.ds.Option;
import ParseUtil;

using StringTools;
using haxe.EnumTools;

enum ParseChoice {
	NoMatch;
	Function;
	Enum;
	Struct;
	Panel;
	GClass;
	Hooks;
	Library;
}

interface ParseChooser {
	function choose(jq:CheerioAPI, url:String):ParseChoice;
}

class ParseChooserDef implements ParseChooser {
	public function new() {}

	public function choose(jq:CheerioAPI, url:String):ParseChoice {
		var isFunc = getOptCheer(jq, "div.function");
		var isEnum = getOptCheer(jq, "div.enum");
		var isStruct = getOptCheer(jq, "div.struct");
		var isPanel = getOptCheer(jq, "div.panel");
		var isHooks = url.endsWith("_Hooks");
		var libOrGClass:LibOrGClass = if (isHooks || isPanel.getIndex() == 0) {
			None;
		} else {
			liborGClass(jq, url);
		}
		return switch [isFunc, isEnum, isStruct, isPanel, isHooks, libOrGClass] {
			case [None, None, None, None, false, None]:
				NoMatch;
			case [Some(_), None, None, None, false, None]:
				Function;
			case [None, Some(_), None, None, false, None]:
				Enum;
			case [None, None, Some(_), None, false, None]:
				Struct;
			case [None, None, None, Some(_), false, None]:
				Panel;
			case [None, None, None, None, true, None]:
				Hooks;
			case [None, None, None, None, false, Lib]:
				Library;
			case [None, None, None, None, false, GClass]:
				GClass;
			default:
				trace('$isFunc $isEnum $isStruct $isPanel $isHooks');
				throw "Multiple page types matched!!";
		}
	}

	// an age old question. all together now
	function liborGClass(jq:CheerioAPI, url:String):LibOrGClass {
		if (getOptCheer(jq, "div.type") == None)
			return None;
		var matchText = jq.call("h1:contains('Methods') ~ div.section > div.member_line > a.subject")
			.first()
			.attr("href");
		var pageName = getPageName(url);
		var regexLib = new RegExp('$pageName[.]');
		var regexGClass = new RegExp('$pageName[:]');
		// var matchText = firstMember.data;
		// return None;
		return if (regexLib.exec(matchText) != null) {
			Lib;
		} else if (regexGClass.exec(matchText) != null) {
			GClass;
		} else {
			None;
		}
	}
}

enum LibOrGClass {
	Lib;
	GClass;
	None;
}
