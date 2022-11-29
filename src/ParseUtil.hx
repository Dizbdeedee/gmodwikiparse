package;

import cheerio.lib.cheerio.Cheerio;
import cheerio.lib.load.CheerioAPI;
import haxe.ds.Option;

// and verify
function getCheer(jq:CheerioAPI,select:String):Cheerio<Dynamic> {
    var cheer = jq.call(select);
    try {
        verifySelector(cheer);
    } catch (e) {
        trace(select);
        throw "No cheer";
        // throw e;
    }
    return cheer;
}

//and verify
function getOptCheer(jq:CheerioAPI,select:String):Option<Cheerio<Dynamic>> {
    var cheer = jq.call(select);
    verifyOptionalSelector(cheer);
    return if (cheer.length > 0) {
        Some(cheer);
    } else {
        None;
    };
}

function getChildCheer(node:Cheerio<Dynamic>,select:String):Cheerio<Dynamic> {
    var cheer = node.children(select);
    verifySelector(cheer);
    return cheer;
}

function getChildOptCheer(node:Cheerio<Dynamic>,select:String):Option<Cheerio<Dynamic>> {
    var cheer = node.children(select);
    verifyOptionalSelector(cheer);
    return if (cheer.length > 0) {
        Some(cheer);
    } else {
        None;
    };
}

function verifySelector(node:Cheerio<Dynamic>) {
    if (node.length > 1) {
        trace("Too many selected!");
        // trace(node);
        throw new haxe.Exception("Too many selected");
    } else if (node.length < 1) {
        trace("Not enough selected!");
        // trace(node);
        throw new haxe.Exception("Not enough selected!");
    }
}

function verifyOptionalSelector(node:Cheerio<Dynamic>) {
    if (node.length > 1) {
        trace("Too many selected!");
        // trace(node);
        throw "Too many selected!";
    }
}

function toBool(select:Option<Dynamic>) {
    return switch(select) {
        case Some(_):
            true;
        case None:
            false;
    }
}
