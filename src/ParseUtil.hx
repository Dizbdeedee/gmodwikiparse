package;

using tink.CoreApi;
import generators.desc.DescriptionPublisher;
import generators.desc.UnresolvedDescription;
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
        throw e;
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
    try {
        verifySelector(cheer);

    } catch (e) {
        trace(select);
        throw e;
    }
    return cheer;
}

function getChildCheerTraverse(node:Cheerio<Dynamic>,select:String):Cheerio<Dynamic> {
    var cheer = node.find(select);
    try {
        verifySelector(cheer);

    } catch (e) {
        trace(select);
        throw e;
    }
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
        trace(node.length);
        // trace(node.toArray());
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

function isPageInternal(jq:CheerioAPI) {
    return jq.call("div.internal").length > 0;
}

function isPageDeprecated(jq:CheerioAPI) {
    return jq.call("div.deprecated").length > 0;
}

function getPageName(url:String) {
    var regex = ~/gmod\/(.*)/;
    regex.match(url);
    return regex.matched(1);
}

function mapChildren<T>(node:CheerioD,jq:CheerioAPI,map:(node:CheerioD) -> T):Array<T> {
    var arr = [];
    node.children().each((_,el) -> {
        var cheerEl = jq.call(el);
        arr.push(map(cheerEl));
        return true;
    });
    return arr;
}

function publishOrNull(descPublisher:DescriptionPublisher,conn:data.WikiDB,desc:UnresolvedDescription):Promise<Null<data.Id<data.WikiDB.DescriptionStorage>>> {
    return if (desc.length > 0) {
        descPublisher.publish(conn,desc);
    } else {
        Promise.resolve(null);
    }
}