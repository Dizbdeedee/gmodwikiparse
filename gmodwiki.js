(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Cheerio = require("cheerio");
var ContentParser = function() {
	this.descParser = DescriptionParser2.makeDescParser2();
};
ContentParser.__name__ = "ContentParser";
ContentParser.prototype = {
	parse: function(content) {
		var _gthis = this;
		if(content.warcType != "response") {
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
		}
		var readPromise = tink_core_Future.ofJsPromise(content.readFully());
		var handledPromise = tink_core_Promise.next(readPromise,function(data) {
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(_gthis.loadHTML(content))));
		});
		return tink_core_Promise.noise(handledPromise);
	}
	,loadHTML: function(parsedWarc) {
		ContentParser.jq = Cheerio.load(node_buffer_Buffer.from(parsedWarc.payload));
		var isFunc = ContentParser.jq("div.function").length > 0;
		var isEnum = ContentParser.jq("div.enum").length > 0;
		var isStruct = ContentParser.jq("div.struct").length > 0;
		if(isFunc) {
			if(isEnum == false) {
				if(isStruct == false) {
					this.parseFunction(parsedWarc.warcTargetURI,ContentParser.jq);
				} else {
					haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 53, className : "ContentParser", methodName : "loadHTML"});
					haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 54, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
					throw haxe_Exception.thrown("Multiple page types matched!!");
				}
			} else {
				haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 53, className : "ContentParser", methodName : "loadHTML"});
				haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 54, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
				throw haxe_Exception.thrown("Multiple page types matched!!");
			}
		} else if(isEnum) {
			if(isStruct == false) {
				this.parseEnum(parsedWarc.warcTargetURI,ContentParser.jq);
			} else {
				haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 53, className : "ContentParser", methodName : "loadHTML"});
				haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 54, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
				throw haxe_Exception.thrown("Multiple page types matched!!");
			}
		} else if(isStruct) {
			this.parseStruct(parsedWarc.warcTargetURI,ContentParser.jq);
		} else {
			haxe_Log.trace("Unmatched... " + parsedWarc.warcTargetURI,{ fileName : "src/ContentParser.hx", lineNumber : 45, className : "ContentParser", methodName : "loadHTML"});
		}
		return null;
	}
	,toBool: function(select) {
		switch(select._hx_index) {
		case 0:
			var _g = select.v;
			return true;
		case 1:
			return false;
		}
	}
	,parseStruct: function(url,jq) {
		return null;
	}
	,parseEnum: function(url,jq) {
		var title = this.getCheer(jq,"h1#pagetitle.pagetitle").text();
		var desc = this.getCheer(jq,".function_description");
		var enums = this.getCheer(jq,"h1 + table > tbody");
		haxe_Log.trace(enums,{ fileName : "src/ContentParser.hx", lineNumber : 80, className : "ContentParser", methodName : "parseEnum"});
		return null;
	}
	,parseFunction: function(url,jq) {
		var title = this.getCheer(jq,"h1#pagetitle.pagetitle").text();
		var isHook = this.toBool(this.getOptCheer(jq,".hook"));
		var isClient = this.toBool(this.getOptCheer(jq,".realm-client"));
		var isServer = this.toBool(this.getOptCheer(jq,".realm-server"));
		var isMenu = this.toBool(this.getOptCheer(jq,".realm-menu"));
		var funcNameReg = new EReg("[.:](.*)","");
		var funcName = funcNameReg.match(title) ? funcNameReg.matched(1) : title;
		haxe_Log.trace(funcName,{ fileName : "src/ContentParser.hx", lineNumber : 96, className : "ContentParser", methodName : "parseFunction"});
		var descNode = this.getOptCheer(jq,".description_section");
		if(descNode._hx_index == 0) {
			var descNode1 = descNode.v;
			this.descParser.parseDescNode(descNode1);
		}
		var funcArgsNode = this.getOptCheer(jq,".function_arguments");
		if(funcArgsNode._hx_index == 0) {
			var funcArgsNode1 = funcArgsNode.v;
			this.parseMultipleFuncArgs(funcArgsNode1);
		}
		var retNode = this.getOptCheer(jq,".function_returns");
		if(retNode._hx_index == 0) {
			var retNode1 = retNode.v;
			this.parseMultipleReturns(retNode1);
		}
		this.parseMultipleLuaExamples(jq);
		var this1 = -1;
		var this2 = -1;
		return { id : this1, name : funcName, url : url, description : this2, isHook : isHook, stateClient : isClient, stateServer : isServer, stateMenu : isMenu};
	}
	,getCheer: function(jq,select) {
		var cheer = jq(select);
		try {
			this.verifySelector(cheer);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g);
			haxe_Log.trace(select,{ fileName : "src/ContentParser.hx", lineNumber : 135, className : "ContentParser", methodName : "getCheer"});
			throw haxe_Exception.thrown(e);
		}
		return cheer;
	}
	,getOptCheer: function(jq,select) {
		var cheer = jq(select);
		this.verifyOptionalSelector(cheer);
		if(cheer.length > 0) {
			return haxe_ds_Option.Some(cheer);
		} else {
			return haxe_ds_Option.None;
		}
	}
	,getChildCheer: function(node,select) {
		var cheer = node.children(select);
		this.verifySelector(cheer);
		return cheer;
	}
	,getChildOptCheer: function(node,select) {
		var cheer = node.children(select);
		this.verifyOptionalSelector(cheer);
		if(cheer.length > 0) {
			return haxe_ds_Option.Some(cheer);
		} else {
			return haxe_ds_Option.None;
		}
	}
	,verifySelector: function(node) {
		if(node.length > 1) {
			haxe_Log.trace("Too many selected!",{ fileName : "src/ContentParser.hx", lineNumber : 170, className : "ContentParser", methodName : "verifySelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 171, className : "ContentParser", methodName : "verifySelector"});
			throw haxe_Exception.thrown(node);
		} else if(node.length < 1) {
			haxe_Log.trace("Not enough selected!",{ fileName : "src/ContentParser.hx", lineNumber : 174, className : "ContentParser", methodName : "verifySelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 175, className : "ContentParser", methodName : "verifySelector"});
			throw new haxe_Exception("Not enough selected!");
		}
	}
	,verifyOptionalSelector: function(node) {
		if(node.length > 1) {
			haxe_Log.trace("Too many selected!",{ fileName : "src/ContentParser.hx", lineNumber : 182, className : "ContentParser", methodName : "verifyOptionalSelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 183, className : "ContentParser", methodName : "verifyOptionalSelector"});
			throw haxe_Exception.thrown(node);
		}
	}
	,parseMultipleLuaExamples: function(jq) {
		var _gthis = this;
		jq("h2 + .example").each(function(_,el) {
			var cheerEl = jq(el);
			_gthis.parseLuaExample(cheerEl);
			return true;
		});
	}
	,parseLuaExample: function(node) {
		var desc = this.getChildOptCheer(node,"div.description");
		var code = this.getChildCheer(node,"div.code");
		var output = this.getChildOptCheer(node,"div.output");
		if(desc._hx_index == 0) {
			var descNode = desc.v;
			this.descParser.parseDescNode(descNode);
		} else {
			haxe_Log.trace("No description??",{ fileName : "src/ContentParser.hx", lineNumber : 205, className : "ContentParser", methodName : "parseLuaExample"});
		}
		haxe_Log.trace(this.descParser.parseDescNode(code),{ fileName : "src/ContentParser.hx", lineNumber : 207, className : "ContentParser", methodName : "parseLuaExample"});
		if(output._hx_index == 0) {
			var outputNode = output.v;
			this.descParser.parseDescNode(outputNode);
		} else {
			haxe_Log.trace("No output",{ fileName : "src/ContentParser.hx", lineNumber : 212, className : "ContentParser", methodName : "parseLuaExample"});
		}
	}
	,parseMultipleFuncArgs: function(funcArgs) {
		var _gthis = this;
		funcArgs.children().each(function(_,el) {
			var cheerEl = ContentParser.jq(el);
			_gthis.parseFuncArg(cheerEl);
			return true;
		});
	}
	,parseMultipleReturns: function(rets) {
		var _gthis = this;
		rets.children().each(function(_,el) {
			var cheerEl = ContentParser.jq(el);
			_gthis.parseReturn(cheerEl);
			return true;
		});
	}
	,parseReturn: function(node) {
		var typeNode = this.getChildCheer(node,"a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var returnNo = Std.parseInt(this.getChildCheer(node,"span.numbertag").text());
		var desc = this.getChildOptCheer(node,"div.numbertagindent");
		var results;
		switch(desc._hx_index) {
		case 0:
			var descNode = desc.v;
			results = this.descParser.parseDescNode(descNode);
			break;
		case 1:
			results = null;
			break;
		}
		var funcRet_returnNo = returnNo;
		var funcRet_typeURL = typeURL;
		var funcRet_type = type;
		var this1 = -1;
		var funcRet_desc = this1;
		var this1 = -1;
		var funcRet_funcid = this1;
	}
	,parseFuncArg: function(node) {
		var typeNode = this.getChildCheer(node,"a");
		var type = typeNode.text();
		var typeURL = typeNode.attr("href");
		var argumentNo = Std.parseInt(this.getChildCheer(node,"span.numbertag").text());
		var name = this.getChildCheer(node,"span.name").text();
		var desc = this.getChildCheer(node,"div.numbertagindent");
		var defResult = this.getChildOptCheer(node,"span.default");
		var results = this.descParser.parseDescNode(desc);
		var created_def;
		var created_argumentNo = argumentNo;
		var created_typeURL = typeURL;
		var created_type = type;
		var created_name = name;
		var this1 = -1;
		var created_description = this1;
		var this1 = -1;
		var created_funcid = this1;
		switch(defResult._hx_index) {
		case 0:
			var cheer = defResult.v;
			created_def = cheer.text();
			break;
		case 1:
			created_def = null;
			break;
		}
	}
	,__class__: ContentParser
};
var DescSelector = function() {
};
DescSelector.__name__ = "DescSelector";
DescSelector.prototype = {
	parse: function(elem) {
		var this1 = 999;
		var this2 = 999;
		return [{ id : this1, textValue : "placeholder", type : 999, nextDesc : this2}];
	}
	,getNoTraversalElements: function() {
		return 1;
	}
	,__class__: DescSelector
};
var PSelector = function() {
	DescSelector.call(this);
};
PSelector.__name__ = "PSelector";
PSelector.__super__ = DescSelector;
PSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("p");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 1, nextDesc : null}],it,[{ id : null, textValue : null, type : 2, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: PSelector
});
var NoteSelector = function() {
	DescSelector.call(this);
};
NoteSelector.__name__ = "NoteSelector";
NoteSelector.__super__ = DescSelector;
NoteSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".note");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 5, nextDesc : null}],it,[{ id : null, textValue : null, type : 6, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: NoteSelector
});
var WarnSelector = function() {
	DescSelector.call(this);
};
WarnSelector.__name__ = "WarnSelector";
WarnSelector.__super__ = DescSelector;
WarnSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".warning");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 7, nextDesc : null}],it,[{ id : null, textValue : null, type : 8, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: WarnSelector
});
var BugSelector = function() {
	DescSelector.call(this);
};
BugSelector.__name__ = "BugSelector";
BugSelector.__super__ = DescSelector;
BugSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".bug");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 11, nextDesc : null}],it,[{ id : null, textValue : null, type : 12, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: BugSelector
});
var DeprecatedSelector = function() {
	DescSelector.call(this);
};
DeprecatedSelector.__name__ = "DeprecatedSelector";
DeprecatedSelector.__super__ = DescSelector;
DeprecatedSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".deprecated");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 13, nextDesc : null}],it,[{ id : null, textValue : null, type : 14, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: DeprecatedSelector
});
var RemovedSelector = function() {
	DescSelector.call(this);
};
RemovedSelector.__name__ = "RemovedSelector";
RemovedSelector.__super__ = DescSelector;
RemovedSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".removed");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 33, nextDesc : null}],it,[{ id : null, textValue : null, type : 34, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: RemovedSelector
});
var InternalSelector = function() {
	DescSelector.call(this);
};
InternalSelector.__name__ = "InternalSelector";
InternalSelector.__super__ = DescSelector;
InternalSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".internal");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 9, nextDesc : null}],it,[{ id : null, textValue : null, type : 10, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: InternalSelector
});
var ListSelector = function() {
	DescSelector.call(this);
};
ListSelector.__name__ = "ListSelector";
ListSelector.__super__ = DescSelector;
ListSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("ul");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 20, nextDesc : null}],it,[{ id : null, textValue : null, type : 22, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: ListSelector
});
var ListItemSelector = function() {
	DescSelector.call(this);
};
ListItemSelector.__name__ = "ListItemSelector";
ListItemSelector.__super__ = DescSelector;
ListItemSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("li");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 21, nextDesc : null}];
	}
	,__class__: ListItemSelector
});
var LuaCodeSelector = function() {
	DescSelector.call(this);
};
LuaCodeSelector.__name__ = "LuaCodeSelector";
LuaCodeSelector.__super__ = DescSelector;
LuaCodeSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".code.code-lua");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 15, nextDesc : null}],it,[{ id : null, textValue : null, type : 17, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: LuaCodeSelector
});
var HeadingWithSectionSelector = function() {
	DescSelector.call(this);
};
HeadingWithSectionSelector.__name__ = "HeadingWithSectionSelector";
HeadingWithSectionSelector.__super__ = DescSelector;
HeadingWithSectionSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("h2 + div");
	}
	,getNoTraversalElements: function() {
		return 2;
	}
	,__class__: HeadingWithSectionSelector
});
var ValidateSelector = function() {
	DescSelector.call(this);
};
ValidateSelector.__name__ = "ValidateSelector";
ValidateSelector.__super__ = DescSelector;
ValidateSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".validate");
	}
	,parse: function(elem) {
		var it = DescriptionParser2.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 25, nextDesc : null}],it,[{ id : null, textValue : null, type : 26, nextDesc : null}]]);
		while(e.hasNext()) {
			var e1 = e.next();
			var x = $getIterator(e1);
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(x1);
			}
		}
		return _g;
	}
	,__class__: ValidateSelector
});
var TitleSelector = function() {
	DescSelector.call(this);
};
TitleSelector.__name__ = "TitleSelector";
TitleSelector.__super__ = DescSelector;
TitleSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("h1");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 24, nextDesc : null}];
	}
	,__class__: TitleSelector
});
var HeadingSelector = function() {
	DescSelector.call(this);
};
HeadingSelector.__name__ = "HeadingSelector";
HeadingSelector.__super__ = DescSelector;
HeadingSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("h2");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 23, nextDesc : null}];
	}
	,__class__: HeadingSelector
});
var AnchorSelector = function() {
	DescSelector.call(this);
};
AnchorSelector.__name__ = "AnchorSelector";
AnchorSelector.__super__ = DescSelector;
AnchorSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("a.anchor_offset");
	}
	,parse: function(elem) {
		return [];
	}
	,__class__: AnchorSelector
});
var ImageSelector = function() {
	DescSelector.call(this);
};
ImageSelector.__name__ = "ImageSelector";
ImageSelector.__super__ = DescSelector;
ImageSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("div.image");
	}
	,parse: function(elem) {
		return [];
	}
	,__class__: ImageSelector
});
var ImgSelector = function() {
	DescSelector.call(this);
};
ImgSelector.__name__ = "ImgSelector";
ImgSelector.__super__ = DescSelector;
ImgSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("img");
	}
	,parse: function(elem) {
		return [];
	}
	,__class__: ImgSelector
});
var TextSelector = function() {
	DescSelector.call(this);
};
TextSelector.__name__ = "TextSelector";
TextSelector.__super__ = DescSelector;
TextSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.get(0).type == "text";
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.get(0).data, type : 0, nextDesc : null}];
	}
	,__class__: TextSelector
});
var LinkSelector = function() {
	DescSelector.call(this);
};
LinkSelector.__name__ = "LinkSelector";
LinkSelector.__super__ = DescSelector;
LinkSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("a[class!=\"anchor_offset\"]");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 3, nextDesc : null},{ id : null, textValue : elem.attr("href"), type : 4, nextDesc : null}];
	}
	,__class__: LinkSelector
});
var TableSelector = function() {
	DescSelector.call(this);
};
TableSelector.__name__ = "TableSelector";
TableSelector.__super__ = DescSelector;
TableSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("table");
	}
	,parse: function(elem) {
		return [];
	}
	,__class__: TableSelector
});
var CodeTagSelector = function() {
	DescSelector.call(this);
};
CodeTagSelector.__name__ = "CodeTagSelector";
CodeTagSelector.__super__ = DescSelector;
CodeTagSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("code");
	}
	,parse: function(elem) {
		var tmp = elem.text();
		return [{ id : null, textValue : null, type : 27, nextDesc : null},{ id : null, textValue : tmp, type : 0, nextDesc : null},{ id : null, textValue : null, type : 28, nextDesc : null}];
	}
	,__class__: CodeTagSelector
});
var StrongSelector = function() {
	DescSelector.call(this);
};
StrongSelector.__name__ = "StrongSelector";
StrongSelector.__super__ = DescSelector;
StrongSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("strong");
	}
	,parse: function(elem) {
		var tmp = { id : null, textValue : elem.text(), type : 0, nextDesc : null};
		var tmp1 = elem.text();
		return [{ id : null, textValue : null, type : 29, nextDesc : null},tmp,{ id : null, textValue : tmp1, type : 30, nextDesc : null}];
	}
	,__class__: StrongSelector
});
var BRSelector = function() {
	DescSelector.call(this);
};
BRSelector.__name__ = "BRSelector";
BRSelector.__super__ = DescSelector;
BRSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("br");
	}
	,__class__: BRSelector
});
var JSCodeSelector = function() {
	DescSelector.call(this);
};
JSCodeSelector.__name__ = "JSCodeSelector";
JSCodeSelector.__super__ = DescSelector;
JSCodeSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is(".code.code-javascript");
	}
	,__class__: JSCodeSelector
});
var BoldSelector = function() {
	DescSelector.call(this);
};
BoldSelector.__name__ = "BoldSelector";
BoldSelector.__super__ = DescSelector;
BoldSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("b");
	}
	,__class__: BoldSelector
});
var KeySelector = function() {
	DescSelector.call(this);
};
KeySelector.__name__ = "KeySelector";
KeySelector.__super__ = DescSelector;
KeySelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("span.key");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 0, nextDesc : null}];
	}
	,__class__: KeySelector
});
var CodeFeatureSelector = function() {
	DescSelector.call(this);
};
CodeFeatureSelector.__name__ = "CodeFeatureSelector";
CodeFeatureSelector.__super__ = DescSelector;
CodeFeatureSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		if(elem.is("span")) {
			return elem.parent().is(".code");
		} else {
			return false;
		}
	}
	,parse: function(elem) {
		return DescriptionParser2.makeDescParser2().parseDescNode(elem);
	}
	,__class__: CodeFeatureSelector
});
var ItalicsSelector = function() {
	DescSelector.call(this);
};
ItalicsSelector.__name__ = "ItalicsSelector";
ItalicsSelector.__super__ = DescSelector;
ItalicsSelector.prototype = $extend(DescSelector.prototype,{
	testElement: function(elem) {
		return elem.is("em");
	}
	,parse: function(elem) {
		return [{ id : null, textValue : elem.text(), type : 0, nextDesc : null}];
	}
	,__class__: ItalicsSelector
});
var DescriptionParser2 = function(_selectors) {
	this.selectors = _selectors;
};
DescriptionParser2.__name__ = "DescriptionParser2";
DescriptionParser2.makeDescParser2 = function() {
	return new DescriptionParser2([new PSelector(),new NoteSelector(),new WarnSelector(),new BugSelector(),new DeprecatedSelector(),new RemovedSelector(),new ListSelector(),new LuaCodeSelector(),new HeadingSelector(),new HeadingWithSectionSelector(),new ValidateSelector(),new TitleSelector(),new AnchorSelector(),new ImageSelector(),new TextSelector(),new LinkSelector(),new TableSelector(),new CodeTagSelector(),new StrongSelector(),new BRSelector(),new JSCodeSelector(),new KeySelector(),new InternalSelector(),new ItalicsSelector(),new ImgSelector(),new ListItemSelector(),new CodeFeatureSelector(),new BoldSelector()]);
};
DescriptionParser2.prototype = {
	parse: function(node) {
		var results = [];
		var _g = 0;
		var _g1 = this.selectors.length;
		while(_g < _g1) {
			var i = _g++;
			if(this.selectors[i].testElement(node)) {
				results.push(i);
			}
		}
		if(results.length > 1) {
			haxe_Log.trace("Too many elements matched!",{ fileName : "src/DescriptionParser2.hx", lineNumber : 64, className : "DescriptionParser2", methodName : "parse"});
			haxe_Log.trace(node,{ fileName : "src/DescriptionParser2.hx", lineNumber : 65, className : "DescriptionParser2", methodName : "parse"});
			var _g = 0;
			while(_g < results.length) {
				var selectorI = results[_g];
				++_g;
				var c = js_Boot.getClass(this.selectors[selectorI]);
				haxe_Log.trace(c.__name__,{ fileName : "src/DescriptionParser2.hx", lineNumber : 67, className : "DescriptionParser2", methodName : "parse"});
			}
			throw haxe_Exception.thrown("Too many elements matched!");
		} else if(results.length == 0) {
			haxe_Log.trace("No elements matched!",{ fileName : "src/DescriptionParser2.hx", lineNumber : 71, className : "DescriptionParser2", methodName : "parse"});
			haxe_Log.trace(node,{ fileName : "src/DescriptionParser2.hx", lineNumber : 72, className : "DescriptionParser2", methodName : "parse"});
			throw haxe_Exception.thrown("No elements matched!");
		}
		var chosenSelector = this.selectors[results[0]];
		return { generatedDescs : chosenSelector.parse(node), traverseElements : chosenSelector.getNoTraversalElements()};
	}
	,parseDescNode: function(descNode) {
		var _gthis = this;
		var curNode = descNode.contents();
		var allDescriptions = [];
		var skipElements = 1;
		curNode.each(function(_,el) {
			if(skipElements > 1) {
				skipElements -= 1;
				return null;
			}
			var cheerEl = ContentParser.jq(el);
			var results = _gthis.parse(cheerEl);
			allDescriptions = allDescriptions.concat(results.generatedDescs);
			skipElements = results.traverseElements;
			return true;
		});
		return allDescriptions;
	}
	,__class__: DescriptionParser2
};
var EReg = function(r,opt) {
	this.r = new RegExp(r,opt.split("u").join(""));
};
EReg.__name__ = "EReg";
EReg.prototype = {
	match: function(s) {
		if(this.r.global) {
			this.r.lastIndex = 0;
		}
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) {
			return this.r.m[n];
		} else {
			throw haxe_Exception.thrown("EReg::matched");
		}
	}
	,__class__: EReg
};
var WARCParser = require("warcio").WARCParser;
var Main = function() { };
Main.__name__ = "Main";
Main.parseWorker = function(warc,parse) {
	var f = function(success,failure) {
		var doNothing = false;
		var parseResult = null;
		parseResult = function(result) {
			if(doNothing) {
				return;
			}
			switch(result._hx_index) {
			case 0:
				var data = result.data;
				if(data == null) {
					success(null);
				} else {
					parse.parse(data).handle(function(outcome) {
						switch(outcome._hx_index) {
						case 0:
							var _g = outcome.data;
							tink_core_Future.ofJsPromise(warc.parse()).handle(parseResult);
							break;
						case 1:
							var err = outcome.failure;
							failure(err);
							break;
						}
					});
				}
				break;
			case 1:
				var err = result.failure;
				failure(err);
				break;
			}
		};
		tink_core_Future.ofJsPromise(warc.parse()).handle(parseResult);
		var this1 = new tink_core_SimpleLink(function() {
			doNothing = true;
			return doNothing;
		});
		return this1;
	};
	var this1 = new tink_core__$Future_SuspendableFuture(function(cb) {
		return f(function(v) {
			cb(tink_core_Outcome.Success(v));
		},function(e) {
			cb(tink_core_Outcome.Failure(e));
		});
	});
	var this2 = this1;
	return this2;
};
Main.main = function() {
	var driver = new tink_sql_drivers_node_Sqlite3(function(s) {
		return "wikidb";
	});
	var db = new tink_sql_Database0("wiki_db",driver);
	var warc = new WARCParser(js_node_Fs.createReadStream("gmodwiki.warc.gz"));
	var parse = new ContentParser();
	Main.parseWorker(warc,parse).handle(function(outcome) {
		switch(outcome._hx_index) {
		case 0:
			var _g = outcome.data;
			haxe_Log.trace("Poggers completed",{ fileName : "src/Main.hx", lineNumber : 76, className : "Main", methodName : "main"});
			break;
		case 1:
			var failure = outcome.failure;
			haxe_Log.trace("grr failure " + Std.string(failure),{ fileName : "src/Main.hx", lineNumber : 78, className : "Main", methodName : "main"});
			break;
		}
	});
};
Math.__name__ = "Math";
var Std = function() { };
Std.__name__ = "Std";
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	if(x != null) {
		var _g = 0;
		var _g1 = x.length;
		while(_g < _g1) {
			var i = _g++;
			var c = x.charCodeAt(i);
			if(c <= 8 || c >= 14 && c != 32 && c != 45) {
				var nc = x.charCodeAt(i + 1);
				var v = parseInt(x,nc == 120 || nc == 88 ? 16 : 10);
				if(isNaN(v)) {
					return null;
				} else {
					return v;
				}
			}
		}
	}
	return null;
};
var haxe_StackItem = $hxEnums["haxe.StackItem"] = { __ename__:true,__constructs__:null
	,CFunction: {_hx_name:"CFunction",_hx_index:0,__enum__:"haxe.StackItem",toString:$estr}
	,Module: ($_=function(m) { return {_hx_index:1,m:m,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="Module",$_.__params__ = ["m"],$_)
	,FilePos: ($_=function(s,file,line,column) { return {_hx_index:2,s:s,file:file,line:line,column:column,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="FilePos",$_.__params__ = ["s","file","line","column"],$_)
	,Method: ($_=function(classname,method) { return {_hx_index:3,classname:classname,method:method,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="Method",$_.__params__ = ["classname","method"],$_)
	,LocalFunction: ($_=function(v) { return {_hx_index:4,v:v,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="LocalFunction",$_.__params__ = ["v"],$_)
};
haxe_StackItem.__constructs__ = [haxe_StackItem.CFunction,haxe_StackItem.Module,haxe_StackItem.FilePos,haxe_StackItem.Method,haxe_StackItem.LocalFunction];
var haxe_Exception = function(message,previous,native) {
	Error.call(this,message);
	this.message = message;
	this.__previousException = previous;
	this.__nativeException = native != null ? native : this;
};
haxe_Exception.__name__ = "haxe.Exception";
haxe_Exception.caught = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value;
	} else if(((value) instanceof Error)) {
		return new haxe_Exception(value.message,null,value);
	} else {
		return new haxe_ValueException(value,null,value);
	}
};
haxe_Exception.thrown = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value.get_native();
	} else if(((value) instanceof Error)) {
		return value;
	} else {
		var e = new haxe_ValueException(value);
		return e;
	}
};
haxe_Exception.__super__ = Error;
haxe_Exception.prototype = $extend(Error.prototype,{
	toString: function() {
		return this.get_message();
	}
	,get_message: function() {
		return this.message;
	}
	,get_native: function() {
		return this.__nativeException;
	}
	,__class__: haxe_Exception
});
var haxe__$Int64__$_$_$Int64 = function() { };
haxe__$Int64__$_$_$Int64.__name__ = "haxe._Int64.___Int64";
var haxe_Log = function() { };
haxe_Log.__name__ = "haxe.Log";
haxe_Log.formatOutput = function(v,infos) {
	var str = Std.string(v);
	if(infos == null) {
		return str;
	}
	var pstr = infos.fileName + ":" + infos.lineNumber;
	if(infos.customParams != null) {
		var _g = 0;
		var _g1 = infos.customParams;
		while(_g < _g1.length) {
			var v = _g1[_g];
			++_g;
			str += ", " + Std.string(v);
		}
	}
	return pstr + ": " + str;
};
haxe_Log.trace = function(v,infos) {
	var str = haxe_Log.formatOutput(v,infos);
	if(typeof(console) != "undefined" && console.log != null) {
		console.log(str);
	}
};
var haxe_ValueException = function(value,previous,native) {
	haxe_Exception.call(this,String(value),previous,native);
	this.value = value;
};
haxe_ValueException.__name__ = "haxe.ValueException";
haxe_ValueException.__super__ = haxe_Exception;
haxe_ValueException.prototype = $extend(haxe_Exception.prototype,{
	__class__: haxe_ValueException
});
var haxe_ds_Option = $hxEnums["haxe.ds.Option"] = { __ename__:true,__constructs__:null
	,Some: ($_=function(v) { return {_hx_index:0,v:v,__enum__:"haxe.ds.Option",toString:$estr}; },$_._hx_name="Some",$_.__params__ = ["v"],$_)
	,None: {_hx_name:"None",_hx_index:1,__enum__:"haxe.ds.Option",toString:$estr}
};
haxe_ds_Option.__constructs__ = [haxe_ds_Option.Some,haxe_ds_Option.None];
var haxe_ds_StringMap = function() {
	this.h = Object.create(null);
};
haxe_ds_StringMap.__name__ = "haxe.ds.StringMap";
haxe_ds_StringMap.prototype = {
	iterator: function() {
		return new haxe_ds__$StringMap_StringMapValueIterator(this.h);
	}
	,__class__: haxe_ds_StringMap
};
var haxe_ds__$StringMap_StringMapValueIterator = function(h) {
	this.h = h;
	this.keys = Object.keys(h);
	this.length = this.keys.length;
	this.current = 0;
};
haxe_ds__$StringMap_StringMapValueIterator.__name__ = "haxe.ds._StringMap.StringMapValueIterator";
haxe_ds__$StringMap_StringMapValueIterator.prototype = {
	hasNext: function() {
		return this.current < this.length;
	}
	,next: function() {
		return this.h[this.keys[this.current++]];
	}
	,__class__: haxe_ds__$StringMap_StringMapValueIterator
};
var haxe_io_Bytes = function() { };
haxe_io_Bytes.__name__ = "haxe.io.Bytes";
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.__name__ = "haxe.iterators.ArrayIterator";
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
	,__class__: haxe_iterators_ArrayIterator
};
var js_Boot = function() { };
js_Boot.__name__ = "js.Boot";
js_Boot.getClass = function(o) {
	if(o == null) {
		return null;
	} else if(((o) instanceof Array)) {
		return Array;
	} else {
		var cl = o.__class__;
		if(cl != null) {
			return cl;
		}
		var name = js_Boot.__nativeClassName(o);
		if(name != null) {
			return js_Boot.__resolveNativeClass(name);
		}
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o.__enum__) {
			var e = $hxEnums[o.__enum__];
			var con = e.__constructs__[o._hx_index];
			var n = con._hx_name;
			if(con.__params__) {
				s = s + "\t";
				return n + "(" + ((function($this) {
					var $r;
					var _g = [];
					{
						var _g1 = 0;
						var _g2 = con.__params__;
						while(true) {
							if(!(_g1 < _g2.length)) {
								break;
							}
							var p = _g2[_g1];
							_g1 = _g1 + 1;
							_g.push(js_Boot.__string_rec(o[p],s));
						}
					}
					$r = _g;
					return $r;
				}(this))).join(",") + ")";
			} else {
				return n;
			}
		}
		if(((o) instanceof Array)) {
			var str = "[";
			s += "\t";
			var _g = 0;
			var _g1 = o.length;
			while(_g < _g1) {
				var i = _g++;
				str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( _g ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		var k = null;
		for( k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) {
			str += ", \n";
		}
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") {
		return null;
	}
	return name;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var js_node_Fs = require("fs");
var node_buffer_Buffer = require("buffer").Buffer;
var tink_core_Callback = {};
tink_core_Callback.invoke = function(this1,data) {
	if(tink_core_Callback.depth < 500) {
		tink_core_Callback.depth++;
		this1(data);
		tink_core_Callback.depth--;
	} else {
		tink_core_Callback.defer(function() {
			this1(data);
		});
	}
};
tink_core_Callback.defer = function(f) {
	process.nextTick(f);
};
var tink_core_CallbackLinkRef = function() {
};
tink_core_CallbackLinkRef.__name__ = "tink.core.CallbackLinkRef";
tink_core_CallbackLinkRef.prototype = {
	cancel: function() {
		var this1 = this.link;
		if(this1 != null) {
			this1.cancel();
		}
	}
	,__class__: tink_core_CallbackLinkRef
};
var tink_core_SimpleLink = function(f) {
	this.f = f;
};
tink_core_SimpleLink.__name__ = "tink.core.SimpleLink";
tink_core_SimpleLink.prototype = {
	cancel: function() {
		if(this.f != null) {
			this.f();
			this.f = null;
		}
	}
	,__class__: tink_core_SimpleLink
};
var tink_core__$Callback_LinkPair = function(a,b) {
	this.dissolved = false;
	this.a = a;
	this.b = b;
};
tink_core__$Callback_LinkPair.__name__ = "tink.core._Callback.LinkPair";
tink_core__$Callback_LinkPair.prototype = {
	cancel: function() {
		if(!this.dissolved) {
			this.dissolved = true;
			var this1 = this.a;
			if(this1 != null) {
				this1.cancel();
			}
			var this1 = this.b;
			if(this1 != null) {
				this1.cancel();
			}
			this.a = null;
			this.b = null;
		}
	}
	,__class__: tink_core__$Callback_LinkPair
};
var tink_core__$Callback_ListCell = function(cb,list) {
	if(cb == null) {
		throw haxe_Exception.thrown("callback expected but null received");
	}
	this.cb = cb;
	this.list = list;
};
tink_core__$Callback_ListCell.__name__ = "tink.core._Callback.ListCell";
tink_core__$Callback_ListCell.prototype = {
	cancel: function() {
		if(this.list != null) {
			var list = this.list;
			this.cb = null;
			this.list = null;
			if(--list.used <= list.cells.length >> 1) {
				list.compact();
			}
		}
	}
	,__class__: tink_core__$Callback_ListCell
};
var tink_core_SimpleDisposable = function(dispose) {
	this.disposeHandlers = [];
	this.f = dispose;
};
tink_core_SimpleDisposable.__name__ = "tink.core.SimpleDisposable";
tink_core_SimpleDisposable.noop = function() {
};
tink_core_SimpleDisposable.prototype = {
	dispose: function() {
		var _g = this.disposeHandlers;
		if(_g != null) {
			var v = _g;
			this.disposeHandlers = null;
			var f = this.f;
			this.f = tink_core_SimpleDisposable.noop;
			f();
			var _g = 0;
			while(_g < v.length) {
				var h = v[_g];
				++_g;
				h();
			}
		}
	}
	,__class__: tink_core_SimpleDisposable
};
var tink_core_CallbackList = function(destructive) {
	if(destructive == null) {
		destructive = false;
	}
	this.onfill = function() {
	};
	this.ondrain = function() {
	};
	this.busy = false;
	this.queue = [];
	this.used = 0;
	var _gthis = this;
	tink_core_SimpleDisposable.call(this,function() {
		if(!_gthis.busy) {
			_gthis.destroy();
		}
	});
	this.destructive = destructive;
	this.cells = [];
};
tink_core_CallbackList.__name__ = "tink.core.CallbackList";
tink_core_CallbackList.__super__ = tink_core_SimpleDisposable;
tink_core_CallbackList.prototype = $extend(tink_core_SimpleDisposable.prototype,{
	destroy: function() {
		var _g = 0;
		var _g1 = this.cells;
		while(_g < _g1.length) {
			var c = _g1[_g];
			++_g;
			c.cb = null;
			c.list = null;
		}
		this.queue = null;
		this.cells = null;
		if(this.used > 0) {
			this.used = 0;
			var fn = this.ondrain;
			if(tink_core_Callback.depth < 500) {
				tink_core_Callback.depth++;
				fn();
				tink_core_Callback.depth--;
			} else {
				tink_core_Callback.defer(fn);
			}
		}
	}
	,invoke: function(data) {
		var _gthis = this;
		if(tink_core_Callback.depth < 500) {
			tink_core_Callback.depth++;
			if(_gthis.disposeHandlers != null) {
				if(_gthis.busy) {
					if(_gthis.destructive != true) {
						var _g = $bind(_gthis,_gthis.invoke);
						var data1 = data;
						var tmp = function() {
							_g(data1);
						};
						_gthis.queue.push(tmp);
					}
				} else {
					_gthis.busy = true;
					if(_gthis.destructive) {
						_gthis.dispose();
					}
					var length = _gthis.cells.length;
					var _g1 = 0;
					var _g2 = length;
					while(_g1 < _g2) {
						var i = _g1++;
						var _this = _gthis.cells[i];
						if(_this.list != null) {
							_this.cb(data);
						}
					}
					_gthis.busy = false;
					if(_gthis.disposeHandlers == null) {
						_gthis.destroy();
					} else {
						if(_gthis.used < _gthis.cells.length) {
							_gthis.compact();
						}
						if(_gthis.queue.length > 0) {
							(_gthis.queue.shift())();
						}
					}
				}
			}
			tink_core_Callback.depth--;
		} else {
			tink_core_Callback.defer(function() {
				if(_gthis.disposeHandlers != null) {
					if(_gthis.busy) {
						if(_gthis.destructive != true) {
							var _g = $bind(_gthis,_gthis.invoke);
							var data1 = data;
							var tmp = function() {
								_g(data1);
							};
							_gthis.queue.push(tmp);
						}
					} else {
						_gthis.busy = true;
						if(_gthis.destructive) {
							_gthis.dispose();
						}
						var length = _gthis.cells.length;
						var _g1 = 0;
						var _g2 = length;
						while(_g1 < _g2) {
							var i = _g1++;
							var _this = _gthis.cells[i];
							if(_this.list != null) {
								_this.cb(data);
							}
						}
						_gthis.busy = false;
						if(_gthis.disposeHandlers == null) {
							_gthis.destroy();
						} else {
							if(_gthis.used < _gthis.cells.length) {
								_gthis.compact();
							}
							if(_gthis.queue.length > 0) {
								(_gthis.queue.shift())();
							}
						}
					}
				}
			});
		}
	}
	,compact: function() {
		if(this.busy) {
			return;
		} else if(this.used == 0) {
			this.resize(0);
			var fn = this.ondrain;
			if(tink_core_Callback.depth < 500) {
				tink_core_Callback.depth++;
				fn();
				tink_core_Callback.depth--;
			} else {
				tink_core_Callback.defer(fn);
			}
		} else {
			var compacted = 0;
			var _g = 0;
			var _g1 = this.cells.length;
			while(_g < _g1) {
				var i = _g++;
				var _g2 = this.cells[i];
				var _g3 = _g2.list;
				if(_g2.cb != null) {
					var v = _g2;
					if(compacted != i) {
						this.cells[compacted] = v;
					}
					if(++compacted == this.used) {
						break;
					}
				}
			}
			this.resize(this.used);
		}
	}
	,resize: function(length) {
		this.cells.length = length;
	}
	,__class__: tink_core_CallbackList
});
var tink_core_TypedError = function(code,message,pos) {
	if(code == null) {
		code = 500;
	}
	this.code = code;
	this.message = message;
	this.pos = pos;
	this.exceptionStack = [];
	this.callStack = [];
};
tink_core_TypedError.__name__ = "tink.core.TypedError";
tink_core_TypedError.withData = function(code,message,data,pos) {
	return tink_core_TypedError.typed(code,message,data,pos);
};
tink_core_TypedError.typed = function(code,message,data,pos) {
	var ret = new tink_core_TypedError(code,message,pos);
	ret.data = data;
	return ret;
};
tink_core_TypedError.prototype = {
	printPos: function() {
		return this.pos.className + "." + this.pos.methodName + ":" + this.pos.lineNumber;
	}
	,toString: function() {
		var ret = "Error#" + this.code + ": " + this.message;
		if(this.pos != null) {
			ret += " @ " + this.printPos();
		}
		return ret;
	}
	,__class__: tink_core_TypedError
};
var tink_core__$Future_NeverFuture = function() {
};
tink_core__$Future_NeverFuture.__name__ = "tink.core._Future.NeverFuture";
tink_core__$Future_NeverFuture.prototype = {
	getStatus: function() {
		return tink_core_FutureStatus.NeverEver;
	}
	,handle: function(callback) {
		return null;
	}
	,__class__: tink_core__$Future_NeverFuture
};
var tink_core__$Lazy_LazyConst = function(value) {
	this.value = value;
};
tink_core__$Lazy_LazyConst.__name__ = "tink.core._Lazy.LazyConst";
tink_core__$Lazy_LazyConst.prototype = {
	get: function() {
		return this.value;
	}
	,compute: function() {
	}
	,__class__: tink_core__$Lazy_LazyConst
};
var tink_core__$Future_SyncFuture = function(value) {
	this.value = value;
};
tink_core__$Future_SyncFuture.__name__ = "tink.core._Future.SyncFuture";
tink_core__$Future_SyncFuture.prototype = {
	getStatus: function() {
		return tink_core_FutureStatus.Ready(this.value);
	}
	,handle: function(cb) {
		tink_core_Callback.invoke(cb,tink_core_Lazy.get(this.value));
		return null;
	}
	,__class__: tink_core__$Future_SyncFuture
};
var tink_core_Future = {};
tink_core_Future.flatMap = function(this1,next,gather) {
	var _g = this1.getStatus();
	switch(_g._hx_index) {
	case 3:
		var l = _g.result;
		return new tink_core__$Future_SuspendableFuture(function(fire) {
			return next(tink_core_Lazy.get(l)).handle(function(v) {
				fire(v);
			});
		});
	case 4:
		return tink_core_Future.NEVER;
	default:
		return new tink_core__$Future_SuspendableFuture(function($yield) {
			var inner = new tink_core_CallbackLinkRef();
			var outer = this1.handle(function(v) {
				var outer = next(v).handle($yield);
				inner.link = outer;
			});
			return new tink_core__$Callback_LinkPair(outer,inner);
		});
	}
};
tink_core_Future.ofJsPromise = function(promise) {
	return tink_core_Future.irreversible(function(cb) {
		promise.then(function(a) {
			var _g = cb;
			var a1 = tink_core_Outcome.Success(a);
			tink_core_Callback.defer(function() {
				_g(a1);
			});
		},function(e) {
			cb(tink_core_Outcome.Failure(tink_core_TypedError.withData(null,e.message,e,{ fileName : "tink/core/Future.hx", lineNumber : 158, className : "tink.core._Future.Future_Impl_", methodName : "ofJsPromise"})));
		});
	});
};
tink_core_Future.irreversible = function(init) {
	return new tink_core__$Future_SuspendableFuture(function($yield) {
		init($yield);
		return null;
	});
};
var tink_core_FutureStatus = $hxEnums["tink.core.FutureStatus"] = { __ename__:true,__constructs__:null
	,Suspended: {_hx_name:"Suspended",_hx_index:0,__enum__:"tink.core.FutureStatus",toString:$estr}
	,Awaited: {_hx_name:"Awaited",_hx_index:1,__enum__:"tink.core.FutureStatus",toString:$estr}
	,EagerlyAwaited: {_hx_name:"EagerlyAwaited",_hx_index:2,__enum__:"tink.core.FutureStatus",toString:$estr}
	,Ready: ($_=function(result) { return {_hx_index:3,result:result,__enum__:"tink.core.FutureStatus",toString:$estr}; },$_._hx_name="Ready",$_.__params__ = ["result"],$_)
	,NeverEver: {_hx_name:"NeverEver",_hx_index:4,__enum__:"tink.core.FutureStatus",toString:$estr}
};
tink_core_FutureStatus.__constructs__ = [tink_core_FutureStatus.Suspended,tink_core_FutureStatus.Awaited,tink_core_FutureStatus.EagerlyAwaited,tink_core_FutureStatus.Ready,tink_core_FutureStatus.NeverEver];
var tink_core__$Future_SuspendableFuture = function(wakeup) {
	this.status = tink_core_FutureStatus.Suspended;
	var _gthis = this;
	this.wakeup = wakeup;
	this.callbacks = new tink_core_CallbackList(true);
	this.callbacks.ondrain = function() {
		if(_gthis.status == tink_core_FutureStatus.Awaited) {
			_gthis.status = tink_core_FutureStatus.Suspended;
			var this1 = _gthis.link;
			if(this1 != null) {
				this1.cancel();
			}
			_gthis.link = null;
		}
	};
	this.callbacks.onfill = function() {
		if(_gthis.status == tink_core_FutureStatus.Suspended) {
			_gthis.status = tink_core_FutureStatus.Awaited;
			_gthis.arm();
		}
	};
};
tink_core__$Future_SuspendableFuture.__name__ = "tink.core._Future.SuspendableFuture";
tink_core__$Future_SuspendableFuture.prototype = {
	getStatus: function() {
		return this.status;
	}
	,trigger: function(value) {
		var _g = this.status;
		if(_g._hx_index == 3) {
			var _g1 = _g.result;
		} else {
			this.status = tink_core_FutureStatus.Ready(new tink_core__$Lazy_LazyConst(value));
			var link = this.link;
			this.link = null;
			this.wakeup = null;
			this.callbacks.invoke(value);
			if(link != null) {
				link.cancel();
			}
		}
	}
	,handle: function(callback) {
		var _g = this.status;
		if(_g._hx_index == 3) {
			var result = _g.result;
			tink_core_Callback.invoke(callback,tink_core_Lazy.get(result));
			return null;
		} else {
			var _this = this.callbacks;
			if(_this.disposeHandlers == null) {
				return null;
			} else {
				var node = new tink_core__$Callback_ListCell(callback,_this);
				_this.cells.push(node);
				if(_this.used++ == 0) {
					var fn = _this.onfill;
					if(tink_core_Callback.depth < 500) {
						tink_core_Callback.depth++;
						fn();
						tink_core_Callback.depth--;
					} else {
						tink_core_Callback.defer(fn);
					}
				}
				return node;
			}
		}
	}
	,arm: function() {
		var _gthis = this;
		this.link = this.wakeup(function(x) {
			_gthis.trigger(x);
		});
	}
	,__class__: tink_core__$Future_SuspendableFuture
};
var tink_core_Lazy = {};
tink_core_Lazy.get = function(this1) {
	this1.compute();
	return this1.get();
};
var tink_core_Outcome = $hxEnums["tink.core.Outcome"] = { __ename__:true,__constructs__:null
	,Success: ($_=function(data) { return {_hx_index:0,data:data,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Success",$_.__params__ = ["data"],$_)
	,Failure: ($_=function(failure) { return {_hx_index:1,failure:failure,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Failure",$_.__params__ = ["failure"],$_)
};
tink_core_Outcome.__constructs__ = [tink_core_Outcome.Success,tink_core_Outcome.Failure];
var tink_core_Promise = {};
tink_core_Promise.noise = function(this1) {
	if(this1.getStatus()._hx_index == 4) {
		return tink_core_Promise.NEVER;
	} else {
		return tink_core_Promise.next(this1,function(v) {
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
		});
	}
};
tink_core_Promise.next = function(this1,f,gather) {
	return tink_core_Future.flatMap(this1,function(o) {
		switch(o._hx_index) {
		case 0:
			var d = o.data;
			return f(d);
		case 1:
			var f1 = o.failure;
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Failure(f1)));
		}
	});
};
var tink_sql_TransactionObject = function(cnx) {
	this.__cnx = cnx;
};
tink_sql_TransactionObject.__name__ = "tink.sql.TransactionObject";
tink_sql_TransactionObject.prototype = {
	__class__: tink_sql_TransactionObject
};
var tink_sql_Dataset = function(cnx) {
	this.cnx = cnx;
};
tink_sql_Dataset.__name__ = "tink.sql.Dataset";
tink_sql_Dataset.prototype = {
	__class__: tink_sql_Dataset
};
var tink_sql_Limitable = function(cnx) {
	tink_sql_Dataset.call(this,cnx);
};
tink_sql_Limitable.__name__ = "tink.sql.Limitable";
tink_sql_Limitable.__super__ = tink_sql_Dataset;
tink_sql_Limitable.prototype = $extend(tink_sql_Dataset.prototype,{
	__class__: tink_sql_Limitable
});
var tink_sql_Selected = function(cnx,fields,target,toCondition,condition,selection,grouped,order) {
	this.condition = { };
	tink_sql_Limitable.call(this,cnx);
	this.fields = fields;
	this.target = target;
	this.toCondition = toCondition;
	this.condition = condition == null ? { } : condition;
	this.selection = selection;
	this.grouped = grouped;
	this.order = order;
};
tink_sql_Selected.__name__ = "tink.sql.Selected";
tink_sql_Selected.__super__ = tink_sql_Limitable;
tink_sql_Selected.prototype = $extend(tink_sql_Limitable.prototype,{
	__class__: tink_sql_Selected
});
var tink_sql_Orderable = function(cnx,fields,target,toCondition,condition,selection,grouped,order) {
	tink_sql_Selected.call(this,cnx,fields,target,toCondition,condition,selection,grouped,order);
};
tink_sql_Orderable.__name__ = "tink.sql.Orderable";
tink_sql_Orderable.__super__ = tink_sql_Selected;
tink_sql_Orderable.prototype = $extend(tink_sql_Selected.prototype,{
	__class__: tink_sql_Orderable
});
var tink_sql_FilterableWhere = function(cnx,fields,target,toCondition,condition,selection,grouped,order) {
	tink_sql_Orderable.call(this,cnx,fields,target,toCondition,condition,selection,grouped,order);
};
tink_sql_FilterableWhere.__name__ = "tink.sql.FilterableWhere";
tink_sql_FilterableWhere.__super__ = tink_sql_Orderable;
tink_sql_FilterableWhere.prototype = $extend(tink_sql_Orderable.prototype,{
	__class__: tink_sql_FilterableWhere
});
var tink_sql_Selectable = function(cnx,fields,target,toCondition,condition,selection,grouped,order) {
	tink_sql_FilterableWhere.call(this,cnx,fields,target,toCondition,condition,selection,grouped,order);
};
tink_sql_Selectable.__name__ = "tink.sql.Selectable";
tink_sql_Selectable.__super__ = tink_sql_FilterableWhere;
tink_sql_Selectable.prototype = $extend(tink_sql_FilterableWhere.prototype,{
	__class__: tink_sql_Selectable
});
var tink_sql_TableSource = function(cnx,name,alias,fields,info) {
	this.name = name;
	this.alias = alias;
	this.fields = fields;
	this.info = info;
	tink_sql_Selectable.call(this,cnx,fields,tink_sql_Target.TTable(info),function(f) {
		return f(fields);
	});
};
tink_sql_TableSource.__name__ = "tink.sql.TableSource";
tink_sql_TableSource.__super__ = tink_sql_Selectable;
tink_sql_TableSource.prototype = $extend(tink_sql_Selectable.prototype,{
	__class__: tink_sql_TableSource
});
var tink_sql_DataType = $hxEnums["tink.sql.DataType"] = { __ename__:true,__constructs__:null
	,DBool: ($_=function(byDefault) { return {_hx_index:0,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DBool",$_.__params__ = ["byDefault"],$_)
	,DInt: ($_=function(size,signed,autoIncrement,byDefault) { return {_hx_index:1,size:size,signed:signed,autoIncrement:autoIncrement,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DInt",$_.__params__ = ["size","signed","autoIncrement","byDefault"],$_)
	,DDouble: ($_=function(byDefault) { return {_hx_index:2,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DDouble",$_.__params__ = ["byDefault"],$_)
	,DString: ($_=function(maxLength,byDefault) { return {_hx_index:3,maxLength:maxLength,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DString",$_.__params__ = ["maxLength","byDefault"],$_)
	,DText: ($_=function(size,byDefault) { return {_hx_index:4,size:size,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DText",$_.__params__ = ["size","byDefault"],$_)
	,DJson: {_hx_name:"DJson",_hx_index:5,__enum__:"tink.sql.DataType",toString:$estr}
	,DBlob: ($_=function(maxLength) { return {_hx_index:6,maxLength:maxLength,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DBlob",$_.__params__ = ["maxLength"],$_)
	,DDate: ($_=function(byDefault) { return {_hx_index:7,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DDate",$_.__params__ = ["byDefault"],$_)
	,DDateTime: ($_=function(byDefault) { return {_hx_index:8,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DDateTime",$_.__params__ = ["byDefault"],$_)
	,DTimestamp: ($_=function(byDefault) { return {_hx_index:9,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DTimestamp",$_.__params__ = ["byDefault"],$_)
	,DPoint: {_hx_name:"DPoint",_hx_index:10,__enum__:"tink.sql.DataType",toString:$estr}
	,DLineString: {_hx_name:"DLineString",_hx_index:11,__enum__:"tink.sql.DataType",toString:$estr}
	,DPolygon: {_hx_name:"DPolygon",_hx_index:12,__enum__:"tink.sql.DataType",toString:$estr}
	,DMultiPoint: {_hx_name:"DMultiPoint",_hx_index:13,__enum__:"tink.sql.DataType",toString:$estr}
	,DMultiLineString: {_hx_name:"DMultiLineString",_hx_index:14,__enum__:"tink.sql.DataType",toString:$estr}
	,DMultiPolygon: {_hx_name:"DMultiPolygon",_hx_index:15,__enum__:"tink.sql.DataType",toString:$estr}
	,DUnknown: ($_=function(type,byDefault) { return {_hx_index:16,type:type,byDefault:byDefault,__enum__:"tink.sql.DataType",toString:$estr}; },$_._hx_name="DUnknown",$_.__params__ = ["type","byDefault"],$_)
};
tink_sql_DataType.__constructs__ = [tink_sql_DataType.DBool,tink_sql_DataType.DInt,tink_sql_DataType.DDouble,tink_sql_DataType.DString,tink_sql_DataType.DText,tink_sql_DataType.DJson,tink_sql_DataType.DBlob,tink_sql_DataType.DDate,tink_sql_DataType.DDateTime,tink_sql_DataType.DTimestamp,tink_sql_DataType.DPoint,tink_sql_DataType.DLineString,tink_sql_DataType.DPolygon,tink_sql_DataType.DMultiPoint,tink_sql_DataType.DMultiLineString,tink_sql_DataType.DMultiPolygon,tink_sql_DataType.DUnknown];
var tink_sql_IntSize = $hxEnums["tink.sql.IntSize"] = { __ename__:true,__constructs__:null
	,Tiny: {_hx_name:"Tiny",_hx_index:0,__enum__:"tink.sql.IntSize",toString:$estr}
	,Small: {_hx_name:"Small",_hx_index:1,__enum__:"tink.sql.IntSize",toString:$estr}
	,Medium: {_hx_name:"Medium",_hx_index:2,__enum__:"tink.sql.IntSize",toString:$estr}
	,Default: {_hx_name:"Default",_hx_index:3,__enum__:"tink.sql.IntSize",toString:$estr}
	,Big: {_hx_name:"Big",_hx_index:4,__enum__:"tink.sql.IntSize",toString:$estr}
};
tink_sql_IntSize.__constructs__ = [tink_sql_IntSize.Tiny,tink_sql_IntSize.Small,tink_sql_IntSize.Medium,tink_sql_IntSize.Default,tink_sql_IntSize.Big];
var tink_sql_TextSize = $hxEnums["tink.sql.TextSize"] = { __ename__:true,__constructs__:null
	,Tiny: {_hx_name:"Tiny",_hx_index:0,__enum__:"tink.sql.TextSize",toString:$estr}
	,Default: {_hx_name:"Default",_hx_index:1,__enum__:"tink.sql.TextSize",toString:$estr}
	,Medium: {_hx_name:"Medium",_hx_index:2,__enum__:"tink.sql.TextSize",toString:$estr}
	,Long: {_hx_name:"Long",_hx_index:3,__enum__:"tink.sql.TextSize",toString:$estr}
};
tink_sql_TextSize.__constructs__ = [tink_sql_TextSize.Tiny,tink_sql_TextSize.Default,tink_sql_TextSize.Medium,tink_sql_TextSize.Long];
var tink_sql_TableStaticInfo = function(columns,keys) {
	this.columns = columns;
	this.keys = keys;
};
tink_sql_TableStaticInfo.__name__ = "tink.sql.TableStaticInfo";
tink_sql_TableStaticInfo.prototype = {
	__class__: tink_sql_TableStaticInfo
};
var tink_sql_Table0 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "nextDesc";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"nextDesc",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "textValue";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DText(tink_sql_TextSize.Medium,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"textValue",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "type";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"type",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table0.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ id : this1, nextDesc : this2, textValue : this3, type : this4},tmp);
};
tink_sql_Table0.__name__ = "tink.sql.Table0";
tink_sql_Table0.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table0.INFO.columns,tink_sql_Table0.INFO.keys);
};
tink_sql_Table0.__super__ = tink_sql_TableSource;
tink_sql_Table0.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table0
});
var tink_sql_TableInstanceInfo = function(name,alias,columns,keys) {
	tink_sql_TableStaticInfo.call(this,columns,keys);
	this.name = name;
	this.alias = alias;
};
tink_sql_TableInstanceInfo.__name__ = "tink.sql.TableInstanceInfo";
tink_sql_TableInstanceInfo.__super__ = tink_sql_TableStaticInfo;
tink_sql_TableInstanceInfo.prototype = $extend(tink_sql_TableStaticInfo.prototype,{
	__class__: tink_sql_TableInstanceInfo
});
var tink_sql_Table1 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "description";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "isHook";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DBool(null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"isHook",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "stateClient";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DBool(null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"stateClient",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "stateMenu";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DBool(null);
	var inlobj_writable = true;
	var this6 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"stateMenu",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "stateServer";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DBool(null);
	var inlobj_writable = true;
	var this7 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"stateServer",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "url";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this8 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"url",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table1.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ description : this1, id : this2, isHook : this3, name : this4, stateClient : this5, stateMenu : this6, stateServer : this7, url : this8},tmp);
};
tink_sql_Table1.__name__ = "tink.sql.Table1";
tink_sql_Table1.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table1.INFO.columns,tink_sql_Table1.INFO.keys);
};
tink_sql_Table1.__super__ = tink_sql_TableSource;
tink_sql_Table1.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table1
});
var tink_sql_Table2 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "argumentNo";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"argumentNo",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "def";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"def",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "description";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "funcid";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"funcid",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "type";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this6 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"type",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "typeURL";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this7 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"typeURL",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table2.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ argumentNo : this1, def : this2, description : this3, funcid : this4, name : this5, type : this6, typeURL : this7},tmp);
};
tink_sql_Table2.__name__ = "tink.sql.Table2";
tink_sql_Table2.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table2.INFO.columns,tink_sql_Table2.INFO.keys);
};
tink_sql_Table2.__super__ = tink_sql_TableSource;
tink_sql_Table2.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table2
});
var tink_sql_Table3 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "desc";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"desc",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "funcid";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"funcid",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "returnNo";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"returnNo",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "type";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"type",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "typeURL";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"typeURL",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table3.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ desc : this1, funcid : this2, returnNo : this3, type : this4, typeURL : this5},tmp);
};
tink_sql_Table3.__name__ = "tink.sql.Table3";
tink_sql_Table3.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table3.INFO.columns,tink_sql_Table3.INFO.keys);
};
tink_sql_Table3.__super__ = tink_sql_TableSource;
tink_sql_Table3.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table3
});
var tink_sql_DatabaseStaticInfo = function(tables) {
	this.tables = tables;
};
tink_sql_DatabaseStaticInfo.__name__ = "tink.sql.DatabaseStaticInfo";
tink_sql_DatabaseStaticInfo.prototype = {
	instantiate: function(name) {
		return new tink_sql_DatabaseInstanceInfo(name,this.tables);
	}
	,__class__: tink_sql_DatabaseStaticInfo
};
var tink_sql_Transaction0 = function(cnx) {
	tink_sql_TransactionObject.call(this,cnx);
	this.DescLink = new tink_sql_Table0(cnx,"DescLink","DescLink");
	this.Function = new tink_sql_Table1(cnx,"Function","Function");
	this.FunctionArg = new tink_sql_Table2(cnx,"FunctionArg","FunctionArg");
	this.FunctionRet = new tink_sql_Table3(cnx,"FunctionRet","FunctionRet");
};
tink_sql_Transaction0.__name__ = "tink.sql.Transaction0";
tink_sql_Transaction0.__super__ = tink_sql_TransactionObject;
tink_sql_Transaction0.prototype = $extend(tink_sql_TransactionObject.prototype,{
	__class__: tink_sql_Transaction0
});
var tink_sql_Database0 = function(name,driver) {
	tink_sql_Transaction0.call(this,this.__pool = (this.__driver = driver).open(this.__name = name,this.__info = tink_sql_Database0.INFO.instantiate(name)));
};
tink_sql_Database0.__name__ = "tink.sql.Database0";
tink_sql_Database0.__super__ = tink_sql_Transaction0;
tink_sql_Database0.prototype = $extend(tink_sql_Transaction0.prototype,{
	__class__: tink_sql_Database0
});
var tink_sql_DatabaseInstanceInfo = function(name,tables) {
	tink_sql_DatabaseStaticInfo.call(this,tables);
	this.name = name;
};
tink_sql_DatabaseInstanceInfo.__name__ = "tink.sql.DatabaseInstanceInfo";
tink_sql_DatabaseInstanceInfo.__super__ = tink_sql_DatabaseStaticInfo;
tink_sql_DatabaseInstanceInfo.prototype = $extend(tink_sql_DatabaseStaticInfo.prototype,{
	__class__: tink_sql_DatabaseInstanceInfo
});
var tink_sql_ExprData = $hxEnums["tink.sql.ExprData"] = { __ename__:true,__constructs__:null
	,EUnOp: ($_=function(op,a,postfix) { return {_hx_index:0,op:op,a:a,postfix:postfix,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EUnOp",$_.__params__ = ["op","a","postfix"],$_)
	,EBinOp: ($_=function(op,a,b) { return {_hx_index:1,op:op,a:a,b:b,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EBinOp",$_.__params__ = ["op","a","b"],$_)
	,EField: ($_=function(table,name,type) { return {_hx_index:2,table:table,name:name,type:type,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EField",$_.__params__ = ["table","name","type"],$_)
	,ECall: ($_=function(name,args,type,parenthesis) { return {_hx_index:3,name:name,args:args,type:type,parenthesis:parenthesis,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="ECall",$_.__params__ = ["name","args","type","parenthesis"],$_)
	,EValue: ($_=function(value,type) { return {_hx_index:4,value:value,type:type,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EValue",$_.__params__ = ["value","type"],$_)
	,EReturning: ($_=function(type) { return {_hx_index:5,type:type,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EReturning",$_.__params__ = ["type"],$_)
	,EQuery: ($_=function(query,type) { return {_hx_index:6,query:query,type:type,__enum__:"tink.sql.ExprData",toString:$estr}; },$_._hx_name="EQuery",$_.__params__ = ["query","type"],$_)
};
tink_sql_ExprData.__constructs__ = [tink_sql_ExprData.EUnOp,tink_sql_ExprData.EBinOp,tink_sql_ExprData.EField,tink_sql_ExprData.ECall,tink_sql_ExprData.EValue,tink_sql_ExprData.EReturning,tink_sql_ExprData.EQuery];
var tink_sql_ExprType = $hxEnums["tink.sql.ExprType"] = { __ename__:true,__constructs__:null
	,VString: {_hx_name:"VString",_hx_index:0,__enum__:"tink.sql.ExprType",toString:$estr}
	,VJson: {_hx_name:"VJson",_hx_index:1,__enum__:"tink.sql.ExprType",toString:$estr}
	,VBool: {_hx_name:"VBool",_hx_index:2,__enum__:"tink.sql.ExprType",toString:$estr}
	,VFloat: {_hx_name:"VFloat",_hx_index:3,__enum__:"tink.sql.ExprType",toString:$estr}
	,VInt: {_hx_name:"VInt",_hx_index:4,__enum__:"tink.sql.ExprType",toString:$estr}
	,VInt64: {_hx_name:"VInt64",_hx_index:5,__enum__:"tink.sql.ExprType",toString:$estr}
	,VArray: ($_=function(type) { return {_hx_index:6,type:type,__enum__:"tink.sql.ExprType",toString:$estr}; },$_._hx_name="VArray",$_.__params__ = ["type"],$_)
	,VBytes: {_hx_name:"VBytes",_hx_index:7,__enum__:"tink.sql.ExprType",toString:$estr}
	,VDate: {_hx_name:"VDate",_hx_index:8,__enum__:"tink.sql.ExprType",toString:$estr}
	,VGeometry: ($_=function(type) { return {_hx_index:9,type:type,__enum__:"tink.sql.ExprType",toString:$estr}; },$_._hx_name="VGeometry",$_.__params__ = ["type"],$_)
	,VTypeOf: ($_=function(expr) { return {_hx_index:10,expr:expr,__enum__:"tink.sql.ExprType",toString:$estr}; },$_._hx_name="VTypeOf",$_.__params__ = ["expr"],$_)
};
tink_sql_ExprType.__constructs__ = [tink_sql_ExprType.VString,tink_sql_ExprType.VJson,tink_sql_ExprType.VBool,tink_sql_ExprType.VFloat,tink_sql_ExprType.VInt,tink_sql_ExprType.VInt64,tink_sql_ExprType.VArray,tink_sql_ExprType.VBytes,tink_sql_ExprType.VDate,tink_sql_ExprType.VGeometry,tink_sql_ExprType.VTypeOf];
var tink_sql_BinOp = $hxEnums["tink.sql.BinOp"] = { __ename__:true,__constructs__:null
	,Add: {_hx_name:"Add",_hx_index:0,__enum__:"tink.sql.BinOp",toString:$estr}
	,Subt: {_hx_name:"Subt",_hx_index:1,__enum__:"tink.sql.BinOp",toString:$estr}
	,Mult: {_hx_name:"Mult",_hx_index:2,__enum__:"tink.sql.BinOp",toString:$estr}
	,Mod: {_hx_name:"Mod",_hx_index:3,__enum__:"tink.sql.BinOp",toString:$estr}
	,Div: {_hx_name:"Div",_hx_index:4,__enum__:"tink.sql.BinOp",toString:$estr}
	,Greater: {_hx_name:"Greater",_hx_index:5,__enum__:"tink.sql.BinOp",toString:$estr}
	,GreaterOrEquals: {_hx_name:"GreaterOrEquals",_hx_index:6,__enum__:"tink.sql.BinOp",toString:$estr}
	,LessThan: {_hx_name:"LessThan",_hx_index:7,__enum__:"tink.sql.BinOp",toString:$estr}
	,LessThanOrEquals: {_hx_name:"LessThanOrEquals",_hx_index:8,__enum__:"tink.sql.BinOp",toString:$estr}
	,Equals: {_hx_name:"Equals",_hx_index:9,__enum__:"tink.sql.BinOp",toString:$estr}
	,And: {_hx_name:"And",_hx_index:10,__enum__:"tink.sql.BinOp",toString:$estr}
	,Or: {_hx_name:"Or",_hx_index:11,__enum__:"tink.sql.BinOp",toString:$estr}
	,Like: {_hx_name:"Like",_hx_index:12,__enum__:"tink.sql.BinOp",toString:$estr}
	,In: {_hx_name:"In",_hx_index:13,__enum__:"tink.sql.BinOp",toString:$estr}
};
tink_sql_BinOp.__constructs__ = [tink_sql_BinOp.Add,tink_sql_BinOp.Subt,tink_sql_BinOp.Mult,tink_sql_BinOp.Mod,tink_sql_BinOp.Div,tink_sql_BinOp.Greater,tink_sql_BinOp.GreaterOrEquals,tink_sql_BinOp.LessThan,tink_sql_BinOp.LessThanOrEquals,tink_sql_BinOp.Equals,tink_sql_BinOp.And,tink_sql_BinOp.Or,tink_sql_BinOp.Like,tink_sql_BinOp.In];
var tink_sql_UnOp = $hxEnums["tink.sql.UnOp"] = { __ename__:true,__constructs__:null
	,Not: {_hx_name:"Not",_hx_index:0,__enum__:"tink.sql.UnOp",toString:$estr}
	,IsNull: {_hx_name:"IsNull",_hx_index:1,__enum__:"tink.sql.UnOp",toString:$estr}
	,Neg: {_hx_name:"Neg",_hx_index:2,__enum__:"tink.sql.UnOp",toString:$estr}
};
tink_sql_UnOp.__constructs__ = [tink_sql_UnOp.Not,tink_sql_UnOp.IsNull,tink_sql_UnOp.Neg];
var tink_sql_Expr = {};
tink_sql_Expr.ofData = function(d) {
	var this1 = d;
	return this1;
};
var tink_sql_Key = $hxEnums["tink.sql.Key"] = { __ename__:true,__constructs__:null
	,Primary: ($_=function(fields) { return {_hx_index:0,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Primary",$_.__params__ = ["fields"],$_)
	,Unique: ($_=function(name,fields) { return {_hx_index:1,name:name,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Unique",$_.__params__ = ["name","fields"],$_)
	,Index: ($_=function(name,fields) { return {_hx_index:2,name:name,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Index",$_.__params__ = ["name","fields"],$_)
};
tink_sql_Key.__constructs__ = [tink_sql_Key.Primary,tink_sql_Key.Unique,tink_sql_Key.Index];
var tink_sql_Query = $hxEnums["tink.sql.Query"] = { __ename__:true,__constructs__:null
	,Union: ($_=function(union) { return {_hx_index:0,union:union,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Union",$_.__params__ = ["union"],$_)
	,Select: ($_=function(select) { return {_hx_index:1,select:select,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Select",$_.__params__ = ["select"],$_)
	,Insert: ($_=function(insert) { return {_hx_index:2,insert:insert,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Insert",$_.__params__ = ["insert"],$_)
	,Update: ($_=function(update) { return {_hx_index:3,update:update,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Update",$_.__params__ = ["update"],$_)
	,Delete: ($_=function($delete) { return {_hx_index:4,$delete:$delete,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Delete",$_.__params__ = ["$delete"],$_)
	,CallProcedure: ($_=function(call) { return {_hx_index:5,call:call,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="CallProcedure",$_.__params__ = ["call"],$_)
	,CreateTable: ($_=function(table,ifNotExists) { return {_hx_index:6,table:table,ifNotExists:ifNotExists,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="CreateTable",$_.__params__ = ["table","ifNotExists"],$_)
	,DropTable: ($_=function(table) { return {_hx_index:7,table:table,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="DropTable",$_.__params__ = ["table"],$_)
	,TruncateTable: ($_=function(table) { return {_hx_index:8,table:table,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="TruncateTable",$_.__params__ = ["table"],$_)
	,AlterTable: ($_=function(table,changes) { return {_hx_index:9,table:table,changes:changes,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="AlterTable",$_.__params__ = ["table","changes"],$_)
	,ShowColumns: ($_=function(from) { return {_hx_index:10,from:from,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="ShowColumns",$_.__params__ = ["from"],$_)
	,ShowIndex: ($_=function(from) { return {_hx_index:11,from:from,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="ShowIndex",$_.__params__ = ["from"],$_)
	,Transaction: ($_=function(transaction) { return {_hx_index:12,transaction:transaction,__enum__:"tink.sql.Query",toString:$estr}; },$_._hx_name="Transaction",$_.__params__ = ["transaction"],$_)
};
tink_sql_Query.__constructs__ = [tink_sql_Query.Union,tink_sql_Query.Select,tink_sql_Query.Insert,tink_sql_Query.Update,tink_sql_Query.Delete,tink_sql_Query.CallProcedure,tink_sql_Query.CreateTable,tink_sql_Query.DropTable,tink_sql_Query.TruncateTable,tink_sql_Query.AlterTable,tink_sql_Query.ShowColumns,tink_sql_Query.ShowIndex,tink_sql_Query.Transaction];
var tink_sql_AlterTableOperation = $hxEnums["tink.sql.AlterTableOperation"] = { __ename__:true,__constructs__:null
	,AddColumn: ($_=function(col) { return {_hx_index:0,col:col,__enum__:"tink.sql.AlterTableOperation",toString:$estr}; },$_._hx_name="AddColumn",$_.__params__ = ["col"],$_)
	,AddKey: ($_=function(key) { return {_hx_index:1,key:key,__enum__:"tink.sql.AlterTableOperation",toString:$estr}; },$_._hx_name="AddKey",$_.__params__ = ["key"],$_)
	,AlterColumn: ($_=function(to,from) { return {_hx_index:2,to:to,from:from,__enum__:"tink.sql.AlterTableOperation",toString:$estr}; },$_._hx_name="AlterColumn",$_.__params__ = ["to","from"],$_)
	,DropColumn: ($_=function(col) { return {_hx_index:3,col:col,__enum__:"tink.sql.AlterTableOperation",toString:$estr}; },$_._hx_name="DropColumn",$_.__params__ = ["col"],$_)
	,DropKey: ($_=function(key) { return {_hx_index:4,key:key,__enum__:"tink.sql.AlterTableOperation",toString:$estr}; },$_._hx_name="DropKey",$_.__params__ = ["key"],$_)
};
tink_sql_AlterTableOperation.__constructs__ = [tink_sql_AlterTableOperation.AddColumn,tink_sql_AlterTableOperation.AddKey,tink_sql_AlterTableOperation.AlterColumn,tink_sql_AlterTableOperation.DropColumn,tink_sql_AlterTableOperation.DropKey];
var tink_sql_TransactionOperation = $hxEnums["tink.sql.TransactionOperation"] = { __ename__:true,__constructs__:null
	,Start: {_hx_name:"Start",_hx_index:0,__enum__:"tink.sql.TransactionOperation",toString:$estr}
	,Commit: {_hx_name:"Commit",_hx_index:1,__enum__:"tink.sql.TransactionOperation",toString:$estr}
	,Rollback: {_hx_name:"Rollback",_hx_index:2,__enum__:"tink.sql.TransactionOperation",toString:$estr}
};
tink_sql_TransactionOperation.__constructs__ = [tink_sql_TransactionOperation.Start,tink_sql_TransactionOperation.Commit,tink_sql_TransactionOperation.Rollback];
var tink_sql_Target = $hxEnums["tink.sql.Target"] = { __ename__:true,__constructs__:null
	,TTable: ($_=function(table) { return {_hx_index:0,table:table,__enum__:"tink.sql.Target",toString:$estr}; },$_._hx_name="TTable",$_.__params__ = ["table"],$_)
	,TJoin: ($_=function(left,right,type,c) { return {_hx_index:1,left:left,right:right,type:type,c:c,__enum__:"tink.sql.Target",toString:$estr}; },$_._hx_name="TJoin",$_.__params__ = ["left","right","type","c"],$_)
	,TQuery: ($_=function(alias,query) { return {_hx_index:2,alias:alias,query:query,__enum__:"tink.sql.Target",toString:$estr}; },$_._hx_name="TQuery",$_.__params__ = ["alias","query"],$_)
};
tink_sql_Target.__constructs__ = [tink_sql_Target.TTable,tink_sql_Target.TJoin,tink_sql_Target.TQuery];
var tink_sql_drivers_node_Sqlite3 = function(fileForName) {
	this.fileForName = fileForName;
};
tink_sql_drivers_node_Sqlite3.__name__ = "tink.sql.drivers.node.Sqlite3";
tink_sql_drivers_node_Sqlite3.prototype = {
	open: function(name,info) {
		var _g = this.fileForName;
		var cnx;
		if(_g == null) {
			cnx = name;
		} else {
			var f = _g;
			cnx = f(name);
		}
		var cnx1 = new tink_sql_drivers_node__$Sqlite3_Sqlite3Database(cnx);
		return new tink_sql_drivers_node_Sqlite3Connection(info,cnx1);
	}
	,__class__: tink_sql_drivers_node_Sqlite3
};
var tink_sql_drivers_node_Sqlite3Connection = function(info,cnx) {
	this.info = info;
	this.cnx = cnx;
	this.parser = new tink_sql_parse_ResultParser();
};
tink_sql_drivers_node_Sqlite3Connection.__name__ = "tink.sql.drivers.node.Sqlite3Connection";
tink_sql_drivers_node_Sqlite3Connection.prototype = {
	__class__: tink_sql_drivers_node_Sqlite3Connection
};
var tink_sql_drivers_node__$Sqlite3_Sqlite3Database = require("sqlite3").Database;
var tink_sql_expr_ExprTyper = function() { };
tink_sql_expr_ExprTyper.__name__ = "tink.sql.expr.ExprTyper";
tink_sql_expr_ExprTyper.typeColumn = function(type) {
	switch(type._hx_index) {
	case 0:
		var _g = type.byDefault;
		return tink_sql_ExprType.VBool;
	case 1:
		var _g = type.signed;
		var _g = type.autoIncrement;
		var _g = type.byDefault;
		if(type.size._hx_index == 4) {
			return tink_sql_ExprType.VInt64;
		} else {
			return tink_sql_ExprType.VInt;
		}
		break;
	case 2:
		var _g = type.byDefault;
		return tink_sql_ExprType.VFloat;
	case 3:
		var _g = type.maxLength;
		var _g = type.byDefault;
		return tink_sql_ExprType.VString;
	case 4:
		var _g = type.size;
		var _g = type.byDefault;
		return tink_sql_ExprType.VString;
	case 5:
		return tink_sql_ExprType.VJson;
	case 6:
		var _g = type.maxLength;
		return tink_sql_ExprType.VBytes;
	case 7:
		var _g = type.byDefault;
		return tink_sql_ExprType.VDate;
	case 8:
		var _g = type.byDefault;
		return tink_sql_ExprType.VDate;
	case 9:
		var _g = type.byDefault;
		return tink_sql_ExprType.VDate;
	case 10:
		return tink_sql_ExprType.VGeometry(1);
	case 11:
		return tink_sql_ExprType.VGeometry(2);
	case 12:
		return tink_sql_ExprType.VGeometry(3);
	case 13:
		return tink_sql_ExprType.VGeometry(4);
	case 14:
		return tink_sql_ExprType.VGeometry(5);
	case 15:
		return tink_sql_ExprType.VGeometry(6);
	case 16:
		var _g = type.type;
		var _g = type.byDefault;
		return null;
	}
};
var tink_sql_parse_ResultParser = function() {
};
tink_sql_parse_ResultParser.__name__ = "tink.sql.parse.ResultParser";
tink_sql_parse_ResultParser.prototype = {
	__class__: tink_sql_parse_ResultParser
};
function $getIterator(o) { if( o instanceof Array ) return new haxe_iterators_ArrayIterator(o); else return o.iterator(); }
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $global.$haxeUID++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = m.bind(o); o.hx__closures__[m.__id__] = f; } return f; }
$global.$haxeUID |= 0;
String.prototype.__class__ = String;
String.__name__ = "String";
Array.__name__ = "Array";
Date.prototype.__class__ = Date;
Date.__name__ = "Date";
js_Boot.__toStr = ({ }).toString;
tink_core_Callback.depth = 0;
tink_core_Future.NEVER = new tink_core__$Future_NeverFuture();
tink_core_Promise.NEVER = tink_core_Future.NEVER;
tink_sql_Table0.COLUMNS = [{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "nextDesc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "textValue", nullable : false, type : tink_sql_DataType.DText(tink_sql_TextSize.Medium,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true}];
tink_sql_Table0.KEYS = [];
tink_sql_Table0.INFO = new tink_sql_TableStaticInfo(tink_sql_Table0.COLUMNS,tink_sql_Table0.KEYS);
tink_sql_Table1.COLUMNS = [{ name : "description", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "isHook", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "stateClient", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "stateMenu", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "stateServer", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table1.KEYS = [];
tink_sql_Table1.INFO = new tink_sql_TableStaticInfo(tink_sql_Table1.COLUMNS,tink_sql_Table1.KEYS);
tink_sql_Table2.COLUMNS = [{ name : "argumentNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "def", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "description", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "funcid", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "typeURL", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true}];
tink_sql_Table2.KEYS = [];
tink_sql_Table2.INFO = new tink_sql_TableStaticInfo(tink_sql_Table2.COLUMNS,tink_sql_Table2.KEYS);
tink_sql_Table3.COLUMNS = [{ name : "desc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "funcid", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "returnNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "typeURL", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true}];
tink_sql_Table3.KEYS = [];
tink_sql_Table3.INFO = new tink_sql_TableStaticInfo(tink_sql_Table3.COLUMNS,tink_sql_Table3.KEYS);
tink_sql_Transaction0.INFO = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	{
		var value = tink_sql_Table0.makeInfo("DescLink",null);
		_g.h["DescLink"] = value;
	}
	{
		var value = tink_sql_Table1.makeInfo("Function",null);
		_g.h["Function"] = value;
	}
	{
		var value = tink_sql_Table2.makeInfo("FunctionArg",null);
		_g.h["FunctionArg"] = value;
	}
	{
		var value = tink_sql_Table3.makeInfo("FunctionRet",null);
		_g.h["FunctionRet"] = value;
	}
	$r = new tink_sql_DatabaseStaticInfo(_g);
	return $r;
}(this));
tink_sql_Database0.INFO = tink_sql_Transaction0.INFO;
Main.main();
})(typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
