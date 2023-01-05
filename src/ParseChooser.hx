
import haxe.ds.Option;
import ParseUtil;
using StringTools;

enum ParseChoice {
    NoMatch;
    Function;
    Enum;
    Struct;
    Panel;
    GClass;
    Hooks;
}

interface ParseChooser {
    function choose(jq:CheerioAPI,url:String):ParseChoice;
}

class ParseChooserDef implements ParseChooser {

    public function new() {}

    public function choose(jq:CheerioAPI,url:String):ParseChoice {
        var isFunc = getOptCheer(jq,"div.function");
        var isEnum = getOptCheer(jq,"div.enum");
        var isStruct = getOptCheer(jq,"div.struct");
        var isPanel = getOptCheer(jq,"div.panel");
        var isHooks = url.endsWith("_Hooks");
        var isGClass:Option<CheerioD> = if (isPanel.match(Some(_)) || isHooks) {
            None;
        } else {
            getOptCheer(jq,"div.type");
        }

        return switch [isFunc,isEnum,isStruct,isGClass,isPanel,isHooks] {
            case [None,None,None,None,None,false]:
                NoMatch;
            case [Some(_),None,None,None,None,false]:
                Function;

            case [None,Some(_),None,None,None,false]:
                Enum;
            case [None,None,Some(_),None,None,false]:
                Struct;
            case [None,None,None,Some(_),None,false]:
                GClass;
            case [None,None,None,None,Some(_),false]:
                Panel;
            case [None,None,None,None,None,true]:
                Hooks;
            default:
                trace('$isFunc $isEnum $isStruct $isGClass $isPanel $isHooks');
                throw "Multiple page types matched!!";
        }
    }
}