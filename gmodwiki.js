(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Cheerio = require("cheerio");
var ContentParser = function(_dbConnection) {
	this.descParser = DescriptionParser.makeDescParser2();
	this.dbConnection = _dbConnection;
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
			return _gthis.loadHTML(content);
		});
		return tink_core_Promise.noise(handledPromise);
	}
	,loadHTML: function(parsedWarc) {
		ContentParser.jq = Cheerio.load(node_buffer_Buffer.from(parsedWarc.payload));
		var isFunc = ContentParser.jq("div.function").length > 0;
		var isEnum = ContentParser.jq("div.enum").length > 0;
		var isStruct = ContentParser.jq("div.struct").length > 0;
		var prom;
		if(isFunc) {
			if(isEnum == false) {
				if(isStruct == false) {
					prom = tink_core_Future.map(tink_core_Future.noise(this.parseFunction(parsedWarc.warcTargetURI,ContentParser.jq)),tink_core_Outcome.Success);
				} else {
					haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 62, className : "ContentParser", methodName : "loadHTML"});
					haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 63, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
					throw haxe_Exception.thrown("Multiple page types matched!!");
				}
			} else {
				haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 62, className : "ContentParser", methodName : "loadHTML"});
				haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 63, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
				throw haxe_Exception.thrown("Multiple page types matched!!");
			}
		} else if(isEnum) {
			if(isStruct == false) {
				prom = tink_core_Promise.noise(new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(this.parseEnum(parsedWarc.warcTargetURI,ContentParser.jq)))));
			} else {
				haxe_Log.trace("Multiple page types matched!!",{ fileName : "src/ContentParser.hx", lineNumber : 62, className : "ContentParser", methodName : "loadHTML"});
				haxe_Log.trace(isFunc,{ fileName : "src/ContentParser.hx", lineNumber : 63, className : "ContentParser", methodName : "loadHTML", customParams : [isEnum,isStruct]});
				throw haxe_Exception.thrown("Multiple page types matched!!");
			}
		} else if(isStruct) {
			prom = tink_core_Promise.noise(new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(this.parseStruct(parsedWarc.warcTargetURI,ContentParser.jq)))));
		} else {
			haxe_Log.trace("Unmatched... " + parsedWarc.warcTargetURI,{ fileName : "src/ContentParser.hx", lineNumber : 53, className : "ContentParser", methodName : "loadHTML"});
			prom = new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
		}
		return prom;
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
		haxe_Log.trace(enums,{ fileName : "src/ContentParser.hx", lineNumber : 90, className : "ContentParser", methodName : "parseEnum"});
		return null;
	}
	,parseFunction: function(url,jq) {
		var _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				var title = _gthis.getCheer(jq,"h1#pagetitle.pagetitle").text();
				var isHook = _gthis.toBool(_gthis.getOptCheer(jq,".hook"));
				var isClient = _gthis.toBool(_gthis.getOptCheer(jq,".realm-client"));
				var isServer = _gthis.toBool(_gthis.getOptCheer(jq,".realm-server"));
				var isMenu = _gthis.toBool(_gthis.getOptCheer(jq,".realm-menu"));
				var funcNameReg = new EReg("[.:](.*)","");
				var funcName = funcNameReg.match(title) ? funcNameReg.matched(1) : title;
				haxe_Log.trace(funcName,{ fileName : "src/ContentParser.hx", lineNumber : 106, className : "ContentParser", methodName : "parseFunction"});
				var descNode = _gthis.getOptCheer(jq,".description_section");
				var this1;
				if(descNode._hx_index == 0) {
					var descNode1 = descNode.v;
					var descNodes = _gthis.descParser.parseDescNode(descNode1);
					this1 = _gthis.publishDescToDB(descNodes);
				} else {
					this1 = null;
				}
				this1.handle(function(__t0) {
					try {
						var __t0_result;
						var _g = tink_await_OutcomeTools.getOutcome(__t0);
						switch(_g._hx_index) {
						case 0:
							var v = _g.data;
							__t0_result = v;
							break;
						case 1:
							var e = _g.failure;
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(e)));
							return;
						}
						var descID = __t0_result;
						var funcArgsNode = _gthis.getOptCheer(jq,".function_arguments");
						if(funcArgsNode._hx_index == 0) {
							var funcArgsNode1 = funcArgsNode.v;
							_gthis.parseMultipleFuncArgs(funcArgsNode1);
						}
						var retNode = _gthis.getOptCheer(jq,".function_returns");
						if(retNode._hx_index == 0) {
							var retNode1 = retNode.v;
							_gthis.parseMultipleReturns(retNode1);
						}
						_gthis.parseMultipleLuaExamples(jq);
						var this1 = -1;
						var this2 = -1;
						__return(tink_core_Outcome.Success({ id : this1, name : funcName, url : url, description : this2, isHook : isHook, stateClient : isClient, stateServer : isServer, stateMenu : isMenu}));
						return;
					} catch( _g ) {
						var e = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(e)));
					}
				});
			} catch( _g ) {
				var e = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(e)));
			}
		});
	}
	,getCheer: function(jq,select) {
		var cheer = jq(select);
		try {
			this.verifySelector(cheer);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g);
			haxe_Log.trace(select,{ fileName : "src/ContentParser.hx", lineNumber : 147, className : "ContentParser", methodName : "getCheer"});
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
			haxe_Log.trace("Too many selected!",{ fileName : "src/ContentParser.hx", lineNumber : 182, className : "ContentParser", methodName : "verifySelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 183, className : "ContentParser", methodName : "verifySelector"});
			throw haxe_Exception.thrown(node);
		} else if(node.length < 1) {
			haxe_Log.trace("Not enough selected!",{ fileName : "src/ContentParser.hx", lineNumber : 186, className : "ContentParser", methodName : "verifySelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 187, className : "ContentParser", methodName : "verifySelector"});
			throw new haxe_Exception("Not enough selected!");
		}
	}
	,verifyOptionalSelector: function(node) {
		if(node.length > 1) {
			haxe_Log.trace("Too many selected!",{ fileName : "src/ContentParser.hx", lineNumber : 194, className : "ContentParser", methodName : "verifyOptionalSelector"});
			haxe_Log.trace(node,{ fileName : "src/ContentParser.hx", lineNumber : 195, className : "ContentParser", methodName : "verifyOptionalSelector"});
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
			haxe_Log.trace("No description??",{ fileName : "src/ContentParser.hx", lineNumber : 217, className : "ContentParser", methodName : "parseLuaExample"});
		}
		if(output._hx_index == 0) {
			var outputNode = output.v;
			this.descParser.parseDescNode(outputNode);
		} else {
			haxe_Log.trace("No output",{ fileName : "src/ContentParser.hx", lineNumber : 224, className : "ContentParser", methodName : "parseLuaExample"});
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
	,giveDescItemsIDs: function(arr,maxIndex) {
		var _gthis = this;
		var nextID = maxIndex + 1;
		var result = new Array(arr.length);
		var _g = 0;
		var _g1 = arr.length;
		while(_g < _g1) {
			var i = _g++;
			var desc = arr[i];
			var this1 = nextID++;
			result[i] = _gthis.dbConnection.DescItem.insertOne({ id : this1, type : desc.type, textValue : desc.textValue});
		}
		var insertionDescriptions = result;
		return tink_core_Promise.inSequence(insertionDescriptions);
	}
	,getMaxID: function() {
		return tink_core_Promise.next(this.dbConnection.DescItem._select({ id : tink_sql_expr_Functions.max(this.dbConnection.DescItem.fields.id)}).first(),function(result) {
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(result.id)));
		});
	}
	,assignFirstDescriptionStorage: function(initial) {
		var _gthis = this;
		var this1 = -1;
		return tink_core_Promise.next(this.dbConnection.DescriptionStorage.insertOne({ id : this1, descItem : initial}),function(autoDescStoreID) {
			return tink_core_Promise.next(_gthis.dbConnection.DescriptionStorage.update(function(ds) {
				return [tink_sql_expr_Field.set(ds.id,tink_sql_Id.toExpr(autoDescStoreID))];
			},{ where : function(ds) {
				var this1 = -1;
				return tink_sql_expr_Field.eqFloat(ds.id,this1);
			}}),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(autoDescStoreID)));
			});
		});
	}
	,createDescriptionStorages: function(descItemIDSS) {
		var _gthis = this;
		return tink_core_Promise.next(this.assignFirstDescriptionStorage(descItemIDSS[0]),function(autoID) {
			var _this = descItemIDSS.slice(1);
			var result = new Array(_this.length);
			var _g = 0;
			var _g1 = _this.length;
			while(_g < _g1) {
				var i = _g++;
				result[i] = { id : autoID, descItem : _this[i]};
			}
			var $process = result;
			return tink_core_Promise.next(_gthis.dbConnection.DescriptionStorage.insertMany($process),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(autoID)));
			});
		});
	}
	,publishDescToDB: function(arr) {
		var _gthis = this;
		return tink_core_Promise.next(this.getMaxID(),function(maxID) {
			return tink_core_Promise.next(_gthis.giveDescItemsIDs(arr,maxID),$bind(_gthis,_gthis.createDescriptionStorages));
		});
	}
	,__class__: ContentParser
};
var DescSelector = function() {
};
DescSelector.__name__ = "DescSelector";
DescSelector.prototype = {
	parse: function(elem) {
		return [{ id : null, textValue : "placeholder", type : 999}];
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 1}],it,[{ id : null, textValue : null, type : 2}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 5}],it,[{ id : null, textValue : null, type : 6}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 7}],it,[{ id : null, textValue : null, type : 8}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 11}],it,[{ id : null, textValue : null, type : 12}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 13}],it,[{ id : null, textValue : null, type : 14}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 33}],it,[{ id : null, textValue : null, type : 34}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 9}],it,[{ id : null, textValue : null, type : 10}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 20}],it,[{ id : null, textValue : null, type : 22}]]);
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
		return [{ id : null, textValue : elem.text(), type : 21}];
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem);
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 15}],it,[{ id : null, textValue : null, type : 17}]]);
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
		var it = DescriptionParser.makeDescParser2().parseDescNode(elem.children("div.inner"));
		var _g = [];
		var e = $getIterator([[{ id : null, textValue : null, type : 25}],it,[{ id : null, textValue : null, type : 26}]]);
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
		return [{ id : null, textValue : elem.text(), type : 24}];
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
		return [{ id : null, textValue : elem.text(), type : 23}];
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
		return [{ id : null, textValue : elem.get(0).data, type : 0}];
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
		return [{ id : null, textValue : elem.text(), type : 3},{ id : null, textValue : elem.attr("href"), type : 4}];
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
		return [{ id : null, textValue : null, type : 27},{ id : null, textValue : tmp, type : 0},{ id : null, textValue : null, type : 28}];
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
		var tmp = { id : null, textValue : elem.text(), type : 0};
		var tmp1 = elem.text();
		return [{ id : null, textValue : null, type : 29},tmp,{ id : null, textValue : tmp1, type : 30}];
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
		return [{ id : null, textValue : elem.text(), type : 0}];
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
		return DescriptionParser.makeDescParser2().parseDescNode(elem);
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
		return [{ id : null, textValue : elem.text(), type : 0}];
	}
	,__class__: ItalicsSelector
});
var DescriptionParser = function(_selectors) {
	this.selectors = _selectors;
};
DescriptionParser.__name__ = "DescriptionParser";
DescriptionParser.makeDescParser2 = function() {
	return new DescriptionParser([new PSelector(),new NoteSelector(),new WarnSelector(),new BugSelector(),new DeprecatedSelector(),new RemovedSelector(),new ListSelector(),new LuaCodeSelector(),new HeadingSelector(),new HeadingWithSectionSelector(),new ValidateSelector(),new TitleSelector(),new AnchorSelector(),new ImageSelector(),new TextSelector(),new LinkSelector(),new TableSelector(),new CodeTagSelector(),new StrongSelector(),new BRSelector(),new JSCodeSelector(),new KeySelector(),new InternalSelector(),new ItalicsSelector(),new ImgSelector(),new ListItemSelector(),new CodeFeatureSelector(),new BoldSelector()]);
};
DescriptionParser.prototype = {
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
			haxe_Log.trace("Too many elements matched!",{ fileName : "src/DescriptionParser.hx", lineNumber : 64, className : "DescriptionParser", methodName : "parse"});
			haxe_Log.trace(node,{ fileName : "src/DescriptionParser.hx", lineNumber : 65, className : "DescriptionParser", methodName : "parse"});
			var _g = 0;
			while(_g < results.length) {
				var selectorI = results[_g];
				++_g;
				var c = js_Boot.getClass(this.selectors[selectorI]);
				haxe_Log.trace(c.__name__,{ fileName : "src/DescriptionParser.hx", lineNumber : 67, className : "DescriptionParser", methodName : "parse"});
			}
			throw haxe_Exception.thrown("Too many elements matched!");
		} else if(results.length == 0) {
			haxe_Log.trace("No elements matched!",{ fileName : "src/DescriptionParser.hx", lineNumber : 71, className : "DescriptionParser", methodName : "parse"});
			haxe_Log.trace(node,{ fileName : "src/DescriptionParser.hx", lineNumber : 72, className : "DescriptionParser", methodName : "parse"});
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
	,__class__: DescriptionParser
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
var HxOverrides = function() { };
HxOverrides.__name__ = "HxOverrides";
HxOverrides.strDate = function(s) {
	switch(s.length) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d["setTime"](0);
		d["setUTCHours"](k[0]);
		d["setUTCMinutes"](k[1]);
		d["setUTCSeconds"](k[2]);
		return d;
	case 10:
		var k = s.split("-");
		return new Date(k[0],k[1] - 1,k[2],0,0,0);
	case 19:
		var k = s.split(" ");
		var y = k[0].split("-");
		var t = k[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw haxe_Exception.thrown("Invalid date format : " + s);
	}
};
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
HxOverrides.now = function() {
	return Date.now();
};
var Lambda = function() { };
Lambda.__name__ = "Lambda";
Lambda.filter = function(it,f) {
	var _g = [];
	var x = $getIterator(it);
	while(x.hasNext()) {
		var x1 = x.next();
		if(f(x1)) {
			_g.push(x1);
		}
	}
	return _g;
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
Main.createDBs = function(db) {
	var databasePromises = [db.DescItem.create(true),db.DescriptionStorage.create(true),db.Function.create(true),db.FunctionArg.create(true),db.FunctionRet.create(true),db.LuaExample.create(true),db.Struct.create(true),db.GClass.create(true),db.Library.create(true),db.GEnum.create(true),db.GEnumMembers.create(true)];
	return tink_core_Promise.noise(tink_core_Promise.inParallel(databasePromises));
};
Main.main = function() {
	var driver = new tink_sql_drivers_node_Sqlite3(function(s) {
		return "wikidb";
	});
	var db = new tink_sql_Database0("wiki_db",driver);
	Main.createDBs(db).handle(function(out) {
		haxe_Log.trace(out,{ fileName : "src/Main.hx", lineNumber : 89, className : "Main", methodName : "main"});
	});
	var warc = new WARCParser(js_node_Fs.createReadStream("gmodwiki.warc.gz"));
	var parse = new ContentParser(db);
	Main.parseWorker(warc,parse).handle(function(outcome) {
		switch(outcome._hx_index) {
		case 0:
			var _g = outcome.data;
			haxe_Log.trace("Poggers completed",{ fileName : "src/Main.hx", lineNumber : 103, className : "Main", methodName : "main"});
			break;
		case 1:
			var failure = outcome.failure;
			haxe_Log.trace("grr failure " + Std.string(failure),{ fileName : "src/Main.hx", lineNumber : 105, className : "Main", methodName : "main"});
			break;
		}
	});
};
Math.__name__ = "Math";
var Reflect = function() { };
Reflect.__name__ = "Reflect";
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) {
			a.push(f);
		}
		}
	}
	return a;
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) {
		return false;
	}
	delete(o[field]);
	return true;
};
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
var StringTools = function() { };
StringTools.__name__ = "StringTools";
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	if(!(c > 8 && c < 14)) {
		return c == 32;
	} else {
		return true;
	}
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) ++r;
	if(r > 0) {
		return HxOverrides.substr(s,r,l - r);
	} else {
		return s;
	}
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) ++r;
	if(r > 0) {
		return HxOverrides.substr(s,0,l - r);
	} else {
		return s;
	}
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
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
	unwrap: function() {
		return this.__nativeException;
	}
	,toString: function() {
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
var haxe_Int32 = {};
haxe_Int32.ucompare = function(a,b) {
	if(a < 0) {
		if(b < 0) {
			return ~b - ~a | 0;
		} else {
			return 1;
		}
	}
	if(b < 0) {
		return -1;
	} else {
		return a - b | 0;
	}
};
var haxe_Int64 = {};
haxe_Int64.toString = function(this1) {
	var i = this1;
	var b_high = 0;
	var b_low = 0;
	if(i.high == b_high && i.low == b_low) {
		return "0";
	}
	var str = "";
	var neg = false;
	if(i.high < 0) {
		neg = true;
	}
	var this1 = new haxe__$Int64__$_$_$Int64(0,10);
	var ten = this1;
	while(true) {
		var b_high = 0;
		var b_low = 0;
		if(!(i.high != b_high || i.low != b_low)) {
			break;
		}
		var r = haxe_Int64.divMod(i,ten);
		if(r.modulus.high < 0) {
			var x = r.modulus;
			var high = ~x.high;
			var low = ~x.low + 1 | 0;
			if(low == 0) {
				var ret = high++;
				high = high | 0;
			}
			var this_high = high;
			var this_low = low;
			str = this_low + str;
			var x1 = r.quotient;
			var high1 = ~x1.high;
			var low1 = ~x1.low + 1 | 0;
			if(low1 == 0) {
				var ret1 = high1++;
				high1 = high1 | 0;
			}
			var this1 = new haxe__$Int64__$_$_$Int64(high1,low1);
			i = this1;
		} else {
			str = r.modulus.low + str;
			i = r.quotient;
		}
	}
	if(neg) {
		str = "-" + str;
	}
	return str;
};
haxe_Int64.divMod = function(dividend,divisor) {
	if(divisor.high == 0) {
		switch(divisor.low) {
		case 0:
			throw haxe_Exception.thrown("divide by zero");
		case 1:
			var this1 = new haxe__$Int64__$_$_$Int64(dividend.high,dividend.low);
			var this2 = new haxe__$Int64__$_$_$Int64(0,0);
			return { quotient : this1, modulus : this2};
		}
	}
	var divSign = dividend.high < 0 != divisor.high < 0;
	var modulus;
	if(dividend.high < 0) {
		var high = ~dividend.high;
		var low = ~dividend.low + 1 | 0;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(high,low);
		modulus = this1;
	} else {
		var this1 = new haxe__$Int64__$_$_$Int64(dividend.high,dividend.low);
		modulus = this1;
	}
	if(divisor.high < 0) {
		var high = ~divisor.high;
		var low = ~divisor.low + 1 | 0;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(high,low);
		divisor = this1;
	}
	var this1 = new haxe__$Int64__$_$_$Int64(0,0);
	var quotient = this1;
	var this1 = new haxe__$Int64__$_$_$Int64(0,1);
	var mask = this1;
	while(!(divisor.high < 0)) {
		var v = haxe_Int32.ucompare(divisor.high,modulus.high);
		var cmp = v != 0 ? v : haxe_Int32.ucompare(divisor.low,modulus.low);
		var b = 1;
		b &= 63;
		if(b == 0) {
			var this1 = new haxe__$Int64__$_$_$Int64(divisor.high,divisor.low);
			divisor = this1;
		} else if(b < 32) {
			var this2 = new haxe__$Int64__$_$_$Int64(divisor.high << b | divisor.low >>> 32 - b,divisor.low << b);
			divisor = this2;
		} else {
			var this3 = new haxe__$Int64__$_$_$Int64(divisor.low << b - 32,0);
			divisor = this3;
		}
		var b1 = 1;
		b1 &= 63;
		if(b1 == 0) {
			var this4 = new haxe__$Int64__$_$_$Int64(mask.high,mask.low);
			mask = this4;
		} else if(b1 < 32) {
			var this5 = new haxe__$Int64__$_$_$Int64(mask.high << b1 | mask.low >>> 32 - b1,mask.low << b1);
			mask = this5;
		} else {
			var this6 = new haxe__$Int64__$_$_$Int64(mask.low << b1 - 32,0);
			mask = this6;
		}
		if(cmp >= 0) {
			break;
		}
	}
	while(true) {
		var b_high = 0;
		var b_low = 0;
		if(!(mask.high != b_high || mask.low != b_low)) {
			break;
		}
		var v = haxe_Int32.ucompare(modulus.high,divisor.high);
		if((v != 0 ? v : haxe_Int32.ucompare(modulus.low,divisor.low)) >= 0) {
			var this1 = new haxe__$Int64__$_$_$Int64(quotient.high | mask.high,quotient.low | mask.low);
			quotient = this1;
			var high = modulus.high - divisor.high | 0;
			var low = modulus.low - divisor.low | 0;
			if(haxe_Int32.ucompare(modulus.low,divisor.low) < 0) {
				var ret = high--;
				high = high | 0;
			}
			var this2 = new haxe__$Int64__$_$_$Int64(high,low);
			modulus = this2;
		}
		var b = 1;
		b &= 63;
		if(b == 0) {
			var this3 = new haxe__$Int64__$_$_$Int64(mask.high,mask.low);
			mask = this3;
		} else if(b < 32) {
			var this4 = new haxe__$Int64__$_$_$Int64(mask.high >>> b,mask.high << 32 - b | mask.low >>> b);
			mask = this4;
		} else {
			var this5 = new haxe__$Int64__$_$_$Int64(0,mask.high >>> b - 32);
			mask = this5;
		}
		var b1 = 1;
		b1 &= 63;
		if(b1 == 0) {
			var this6 = new haxe__$Int64__$_$_$Int64(divisor.high,divisor.low);
			divisor = this6;
		} else if(b1 < 32) {
			var this7 = new haxe__$Int64__$_$_$Int64(divisor.high >>> b1,divisor.high << 32 - b1 | divisor.low >>> b1);
			divisor = this7;
		} else {
			var this8 = new haxe__$Int64__$_$_$Int64(0,divisor.high >>> b1 - 32);
			divisor = this8;
		}
	}
	if(divSign) {
		var high = ~quotient.high;
		var low = ~quotient.low + 1 | 0;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(high,low);
		quotient = this1;
	}
	if(dividend.high < 0) {
		var high = ~modulus.high;
		var low = ~modulus.low + 1 | 0;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(high,low);
		modulus = this1;
	}
	return { quotient : quotient, modulus : modulus};
};
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe__$Int64__$_$_$Int64.__name__ = "haxe._Int64.___Int64";
haxe__$Int64__$_$_$Int64.prototype = {
	__class__: haxe__$Int64__$_$_$Int64
};
var haxe_Int64Helper = function() { };
haxe_Int64Helper.__name__ = "haxe.Int64Helper";
haxe_Int64Helper.parseString = function(sParam) {
	var base_high = 0;
	var base_low = 10;
	var this1 = new haxe__$Int64__$_$_$Int64(0,0);
	var current = this1;
	var this1 = new haxe__$Int64__$_$_$Int64(0,1);
	var multiplier = this1;
	var sIsNegative = false;
	var s = StringTools.trim(sParam);
	if(s.charAt(0) == "-") {
		sIsNegative = true;
		s = s.substring(1,s.length);
	}
	var len = s.length;
	var _g = 0;
	var _g1 = len;
	while(_g < _g1) {
		var i = _g++;
		var digitInt = HxOverrides.cca(s,len - 1 - i) - 48;
		if(digitInt < 0 || digitInt > 9) {
			throw haxe_Exception.thrown("NumberFormatError");
		}
		if(digitInt != 0) {
			var digit_high = digitInt >> 31;
			var digit_low = digitInt;
			if(sIsNegative) {
				var mask = 65535;
				var al = multiplier.low & mask;
				var ah = multiplier.low >>> 16;
				var bl = digit_low & mask;
				var bh = digit_low >>> 16;
				var p00 = haxe_Int32._mul(al,bl);
				var p10 = haxe_Int32._mul(ah,bl);
				var p01 = haxe_Int32._mul(al,bh);
				var p11 = haxe_Int32._mul(ah,bh);
				var low = p00;
				var high = (p11 + (p01 >>> 16) | 0) + (p10 >>> 16) | 0;
				p01 <<= 16;
				low = low + p01 | 0;
				if(haxe_Int32.ucompare(low,p01) < 0) {
					var ret = high++;
					high = high | 0;
				}
				p10 <<= 16;
				low = low + p10 | 0;
				if(haxe_Int32.ucompare(low,p10) < 0) {
					var ret1 = high++;
					high = high | 0;
				}
				high = high + (haxe_Int32._mul(multiplier.low,digit_high) + haxe_Int32._mul(multiplier.high,digit_low) | 0) | 0;
				var b_high = high;
				var b_low = low;
				var high1 = current.high - b_high | 0;
				var low1 = current.low - b_low | 0;
				if(haxe_Int32.ucompare(current.low,b_low) < 0) {
					var ret2 = high1--;
					high1 = high1 | 0;
				}
				var this1 = new haxe__$Int64__$_$_$Int64(high1,low1);
				current = this1;
				if(!(current.high < 0)) {
					throw haxe_Exception.thrown("NumberFormatError: Underflow");
				}
			} else {
				var mask1 = 65535;
				var al1 = multiplier.low & mask1;
				var ah1 = multiplier.low >>> 16;
				var bl1 = digit_low & mask1;
				var bh1 = digit_low >>> 16;
				var p001 = haxe_Int32._mul(al1,bl1);
				var p101 = haxe_Int32._mul(ah1,bl1);
				var p011 = haxe_Int32._mul(al1,bh1);
				var p111 = haxe_Int32._mul(ah1,bh1);
				var low2 = p001;
				var high2 = (p111 + (p011 >>> 16) | 0) + (p101 >>> 16) | 0;
				p011 <<= 16;
				low2 = low2 + p011 | 0;
				if(haxe_Int32.ucompare(low2,p011) < 0) {
					var ret3 = high2++;
					high2 = high2 | 0;
				}
				p101 <<= 16;
				low2 = low2 + p101 | 0;
				if(haxe_Int32.ucompare(low2,p101) < 0) {
					var ret4 = high2++;
					high2 = high2 | 0;
				}
				high2 = high2 + (haxe_Int32._mul(multiplier.low,digit_high) + haxe_Int32._mul(multiplier.high,digit_low) | 0) | 0;
				var b_high1 = high2;
				var b_low1 = low2;
				var high3 = current.high + b_high1 | 0;
				var low3 = current.low + b_low1 | 0;
				if(haxe_Int32.ucompare(low3,current.low) < 0) {
					var ret5 = high3++;
					high3 = high3 | 0;
				}
				var this2 = new haxe__$Int64__$_$_$Int64(high3,low3);
				current = this2;
				if(current.high < 0) {
					throw haxe_Exception.thrown("NumberFormatError: Overflow");
				}
			}
		}
		var mask2 = 65535;
		var al2 = multiplier.low & mask2;
		var ah2 = multiplier.low >>> 16;
		var bl2 = base_low & mask2;
		var bh2 = base_low >>> 16;
		var p002 = haxe_Int32._mul(al2,bl2);
		var p102 = haxe_Int32._mul(ah2,bl2);
		var p012 = haxe_Int32._mul(al2,bh2);
		var p112 = haxe_Int32._mul(ah2,bh2);
		var low4 = p002;
		var high4 = (p112 + (p012 >>> 16) | 0) + (p102 >>> 16) | 0;
		p012 <<= 16;
		low4 = low4 + p012 | 0;
		if(haxe_Int32.ucompare(low4,p012) < 0) {
			var ret6 = high4++;
			high4 = high4 | 0;
		}
		p102 <<= 16;
		low4 = low4 + p102 | 0;
		if(haxe_Int32.ucompare(low4,p102) < 0) {
			var ret7 = high4++;
			high4 = high4 | 0;
		}
		high4 = high4 + (haxe_Int32._mul(multiplier.low,base_high) + haxe_Int32._mul(multiplier.high,base_low) | 0) | 0;
		var this3 = new haxe__$Int64__$_$_$Int64(high4,low4);
		multiplier = this3;
	}
	return current;
};
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
	unwrap: function() {
		return this.value;
	}
	,__class__: haxe_ValueException
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
var haxe_exceptions_PosException = function(message,previous,pos) {
	haxe_Exception.call(this,message,previous);
	if(pos == null) {
		this.posInfos = { fileName : "(unknown)", lineNumber : 0, className : "(unknown)", methodName : "(unknown)"};
	} else {
		this.posInfos = pos;
	}
};
haxe_exceptions_PosException.__name__ = "haxe.exceptions.PosException";
haxe_exceptions_PosException.__super__ = haxe_Exception;
haxe_exceptions_PosException.prototype = $extend(haxe_Exception.prototype,{
	toString: function() {
		return "" + haxe_Exception.prototype.toString.call(this) + " in " + this.posInfos.className + "." + this.posInfos.methodName + " at " + this.posInfos.fileName + ":" + this.posInfos.lineNumber;
	}
	,__class__: haxe_exceptions_PosException
});
var haxe_exceptions_NotImplementedException = function(message,previous,pos) {
	if(message == null) {
		message = "Not implemented";
	}
	haxe_exceptions_PosException.call(this,message,previous,pos);
};
haxe_exceptions_NotImplementedException.__name__ = "haxe.exceptions.NotImplementedException";
haxe_exceptions_NotImplementedException.__super__ = haxe_exceptions_PosException;
haxe_exceptions_NotImplementedException.prototype = $extend(haxe_exceptions_PosException.prototype,{
	__class__: haxe_exceptions_NotImplementedException
});
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe_io_Bytes.__name__ = "haxe.io.Bytes";
haxe_io_Bytes.ofString = function(s,encoding) {
	if(encoding == haxe_io_Encoding.RawNative) {
		var buf = new Uint8Array(s.length << 1);
		var _g = 0;
		var _g1 = s.length;
		while(_g < _g1) {
			var i = _g++;
			var c = s.charCodeAt(i);
			buf[i << 1] = c & 255;
			buf[i << 1 | 1] = c >> 8;
		}
		return new haxe_io_Bytes(buf.buffer);
	}
	var a = [];
	var i = 0;
	while(i < s.length) {
		var c = s.charCodeAt(i++);
		if(55296 <= c && c <= 56319) {
			c = c - 55232 << 10 | s.charCodeAt(i++) & 1023;
		}
		if(c <= 127) {
			a.push(c);
		} else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe_io_Bytes(new Uint8Array(a).buffer);
};
haxe_io_Bytes.prototype = {
	sub: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		return new haxe_io_Bytes(this.b.buffer.slice(pos + this.b.byteOffset,pos + this.b.byteOffset + len));
	}
	,__class__: haxe_io_Bytes
};
var haxe_io_Input = function() { };
haxe_io_Input.__name__ = "haxe.io.Input";
haxe_io_Input.prototype = {
	readByte: function() {
		throw new haxe_exceptions_NotImplementedException(null,null,{ fileName : "haxe/io/Input.hx", lineNumber : 53, className : "haxe.io.Input", methodName : "readByte"});
	}
	,set_bigEndian: function(b) {
		this.bigEndian = b;
		return b;
	}
	,readDouble: function() {
		var i1 = this.readInt32();
		var i2 = this.readInt32();
		if(this.bigEndian) {
			return haxe_io_FPHelper.i64ToDouble(i2,i1);
		} else {
			return haxe_io_FPHelper.i64ToDouble(i1,i2);
		}
	}
	,readInt32: function() {
		var ch1 = this.readByte();
		var ch2 = this.readByte();
		var ch3 = this.readByte();
		var ch4 = this.readByte();
		if(this.bigEndian) {
			return ch4 | ch3 << 8 | ch2 << 16 | ch1 << 24;
		} else {
			return ch1 | ch2 << 8 | ch3 << 16 | ch4 << 24;
		}
	}
	,__class__: haxe_io_Input
};
var haxe_io_BytesInput = function(b,pos,len) {
	if(pos == null) {
		pos = 0;
	}
	if(len == null) {
		len = b.length - pos;
	}
	if(pos < 0 || len < 0 || pos + len > b.length) {
		throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
	}
	this.b = b.b;
	this.pos = pos;
	this.len = len;
	this.totlen = len;
};
haxe_io_BytesInput.__name__ = "haxe.io.BytesInput";
haxe_io_BytesInput.__super__ = haxe_io_Input;
haxe_io_BytesInput.prototype = $extend(haxe_io_Input.prototype,{
	readByte: function() {
		if(this.len == 0) {
			throw haxe_Exception.thrown(new haxe_io_Eof());
		}
		this.len--;
		return this.b[this.pos++];
	}
	,__class__: haxe_io_BytesInput
});
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__:true,__constructs__:null
	,UTF8: {_hx_name:"UTF8",_hx_index:0,__enum__:"haxe.io.Encoding",toString:$estr}
	,RawNative: {_hx_name:"RawNative",_hx_index:1,__enum__:"haxe.io.Encoding",toString:$estr}
};
haxe_io_Encoding.__constructs__ = [haxe_io_Encoding.UTF8,haxe_io_Encoding.RawNative];
var haxe_io_Eof = function() {
};
haxe_io_Eof.__name__ = "haxe.io.Eof";
haxe_io_Eof.prototype = {
	toString: function() {
		return "Eof";
	}
	,__class__: haxe_io_Eof
};
var haxe_io_Error = $hxEnums["haxe.io.Error"] = { __ename__:true,__constructs__:null
	,Blocked: {_hx_name:"Blocked",_hx_index:0,__enum__:"haxe.io.Error",toString:$estr}
	,Overflow: {_hx_name:"Overflow",_hx_index:1,__enum__:"haxe.io.Error",toString:$estr}
	,OutsideBounds: {_hx_name:"OutsideBounds",_hx_index:2,__enum__:"haxe.io.Error",toString:$estr}
	,Custom: ($_=function(e) { return {_hx_index:3,e:e,__enum__:"haxe.io.Error",toString:$estr}; },$_._hx_name="Custom",$_.__params__ = ["e"],$_)
};
haxe_io_Error.__constructs__ = [haxe_io_Error.Blocked,haxe_io_Error.Overflow,haxe_io_Error.OutsideBounds,haxe_io_Error.Custom];
var haxe_io_FPHelper = function() { };
haxe_io_FPHelper.__name__ = "haxe.io.FPHelper";
haxe_io_FPHelper.i64ToDouble = function(low,high) {
	haxe_io_FPHelper.helper.setInt32(0,low,true);
	haxe_io_FPHelper.helper.setInt32(4,high,true);
	return haxe_io_FPHelper.helper.getFloat64(0,true);
};
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
var js_lib__$ArrayBuffer_ArrayBufferCompat = function() { };
js_lib__$ArrayBuffer_ArrayBufferCompat.__name__ = "js.lib._ArrayBuffer.ArrayBufferCompat";
js_lib__$ArrayBuffer_ArrayBufferCompat.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null ? null : end - begin);
	var resultArray = new Uint8Array(u.byteLength);
	resultArray.set(u);
	return resultArray.buffer;
};
var js_node_Fs = require("fs");
var js_node_buffer_Buffer = require("buffer").Buffer;
var js_node_buffer__$Buffer_Helper = function() { };
js_node_buffer__$Buffer_Helper.__name__ = "js.node.buffer._Buffer.Helper";
js_node_buffer__$Buffer_Helper.bytesOfBuffer = function(b) {
	var o = Object.create(haxe_io_Bytes.prototype);
	o.length = b.byteLength;
	o.b = b;
	b.bufferValue = b;
	b.hxBytes = o;
	b.bytes = b;
	return o;
};
var node_buffer_Buffer = require("buffer").Buffer;
var tink_await_Error = {};
tink_await_Error.fromAny = function(any) {
	if(((any) instanceof tink_core_TypedError)) {
		return any;
	} else {
		return tink_core_TypedError.withData(0,"Unexpected Error",any,{ fileName : "tink/await/Error.hx", lineNumber : 12, className : "tink.await._Error.Error_Impl_", methodName : "fromAny"});
	}
};
var tink_await_OutcomeTools = function() { };
tink_await_OutcomeTools.__name__ = "tink.await.OutcomeTools";
tink_await_OutcomeTools.getOutcome = function(outcome,value) {
	if(outcome == null) {
		return tink_core_Outcome.Success(value);
	} else {
		switch(outcome._hx_index) {
		case 0:
			var v = outcome.data;
			return outcome;
		case 1:
			var _g = outcome.failure;
			var e = _g;
			if(((e) instanceof tink_core_TypedError)) {
				return outcome;
			} else {
				var e = _g;
				return tink_core_Outcome.Failure(tink_await_Error.fromAny(e));
			}
			break;
		}
	}
};
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
	global.setImmediate(f);
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
var tink_core_CallbackLink = {};
tink_core_CallbackLink.fromMany = function(callbacks) {
	var this1 = new tink_core_SimpleLink(function() {
		if(callbacks != null) {
			var _g = 0;
			while(_g < callbacks.length) {
				var cb = callbacks[_g];
				++_g;
				if(cb != null) {
					cb.cancel();
				}
			}
		} else {
			callbacks = null;
		}
	});
	return this1;
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
	this.isTinkError = true;
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
tink_core_TypedError.asError = function(v) {
	if(v != null && v.isTinkError) {
		return v;
	} else {
		return null;
	}
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
var tink_core__$Future_FutureObject = function() {
};
tink_core__$Future_FutureObject.__name__ = "tink.core._Future.FutureObject";
tink_core__$Future_FutureObject.prototype = {
	getStatus: function() {
		return tink_core_FutureStatus.NeverEver;
	}
	,handle: function(callback) {
		return null;
	}
	,eager: function() {
	}
	,__class__: tink_core__$Future_FutureObject
};
var tink_core__$Lazy_LazyConst = function(value) {
	this.value = value;
};
tink_core__$Lazy_LazyConst.__name__ = "tink.core._Lazy.LazyConst";
tink_core__$Lazy_LazyConst.prototype = {
	isComputed: function() {
		return true;
	}
	,get: function() {
		return this.value;
	}
	,compute: function() {
	}
	,underlying: function() {
		return null;
	}
	,__class__: tink_core__$Lazy_LazyConst
};
var tink_core__$Future_SyncFuture = function(value) {
	tink_core__$Future_FutureObject.call(this);
	this.value = value;
};
tink_core__$Future_SyncFuture.__name__ = "tink.core._Future.SyncFuture";
tink_core__$Future_SyncFuture.__super__ = tink_core__$Future_FutureObject;
tink_core__$Future_SyncFuture.prototype = $extend(tink_core__$Future_FutureObject.prototype,{
	getStatus: function() {
		return tink_core_FutureStatus.Ready(this.value);
	}
	,handle: function(cb) {
		tink_core_Callback.invoke(cb,tink_core_Lazy.get(this.value));
		return null;
	}
	,eager: function() {
		if(!this.value.isComputed()) {
			tink_core_Lazy.get(this.value);
		}
	}
	,__class__: tink_core__$Future_SyncFuture
});
var tink_core_Future = {};
tink_core_Future.never = function() {
	return tink_core_Future.NEVER_INST;
};
tink_core_Future.noise = function(this1) {
	if(this1.getStatus()._hx_index == 4) {
		return tink_core_Future.never();
	} else {
		return tink_core_Future.map(this1,function(_) {
			return null;
		});
	}
};
tink_core_Future.map = function(this1,f,gather) {
	var _g = this1.getStatus();
	switch(_g._hx_index) {
	case 3:
		var l = _g.result;
		var this2 = l;
		var f1 = f;
		return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyFunc(function() {
			return f1(this2.get());
		},this2));
	case 4:
		return tink_core_Future.never();
	default:
		return new tink_core__$Future_SuspendableFuture(function(fire) {
			return this1.handle(function(v) {
				fire(f(v));
			});
		});
	}
};
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
		return tink_core_Future.never();
	default:
		return new tink_core__$Future_SuspendableFuture(function($yield) {
			var inner = new tink_core_CallbackLinkRef();
			var outer = this1.handle(function(v) {
				var param = next(v).handle($yield);
				var this1 = inner.link;
				if(this1 != null) {
					this1.cancel();
				}
				inner.link = param;
			});
			return new tink_core__$Callback_LinkPair(outer,inner);
		});
	}
};
tink_core_Future.ofJsPromise = function(promise,transformError) {
	return tink_core_Future.irreversible(function(cb) {
		promise.then(function(a) {
			var _g = cb;
			var a1 = tink_core_Outcome.Success(a);
			tink_core_Callback.defer(function() {
				_g(a1);
			});
		},function(e) {
			var cb1 = cb;
			var tmp;
			if(transformError == null) {
				var e1 = e;
				tmp = tink_core_TypedError.withData(500,e1.message,e1,{ fileName : "tink/core/Future.hx", lineNumber : 176, className : "tink.core._Future.Future_Impl_", methodName : "ofJsPromise"});
			} else {
				var f = transformError;
				tmp = f(e);
			}
			cb1(tink_core_Outcome.Failure(tmp));
		});
	});
};
tink_core_Future.processMany = function(a,concurrency,fn,lift) {
	if(a.length == 0) {
		return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(lift(tink_core_Outcome.Success([]))));
	} else {
		var this1 = new tink_core__$Future_SuspendableFuture(function($yield) {
			var links = [];
			var _g = [];
			var _g1 = 0;
			while(_g1 < a.length) {
				var x = a[_g1];
				++_g1;
				_g.push(null);
			}
			var ret = _g;
			var index = 0;
			var pending = 0;
			var done = false;
			var concurrency1;
			if(concurrency == null) {
				concurrency1 = a.length;
			} else {
				var v = concurrency;
				concurrency1 = v < 1 ? 1 : v > a.length ? a.length : v;
			}
			var fireWhenReady = function() {
				if(index == ret.length) {
					if(pending == 0) {
						var v = lift(tink_core_Outcome.Success(ret));
						done = true;
						$yield(v);
						return true;
					} else {
						return false;
					}
				} else {
					return false;
				}
			};
			var step = null;
			step = function() {
				if(!done && !fireWhenReady()) {
					while(index < ret.length) {
						index += 1;
						var index1 = [index - 1];
						var p = a[index1[0]];
						var check = [(function(index) {
							return function(o) {
								var _g = fn(o);
								switch(_g._hx_index) {
								case 0:
									var v = _g.data;
									ret[index[0]] = v;
									fireWhenReady();
									break;
								case 1:
									var e = _g.failure;
									var _g = 0;
									while(_g < links.length) {
										var l = links[_g];
										++_g;
										if(l != null) {
											l.cancel();
										}
									}
									var v = lift(tink_core_Outcome.Failure(e));
									done = true;
									$yield(v);
									break;
								}
							};
						})(index1)];
						var _g = p.getStatus();
						if(_g._hx_index == 3) {
							var _hx_tmp;
							_hx_tmp = tink_core_Lazy.get(_g.result);
							var v = _hx_tmp;
							check[0](v);
							if(!done) {
								continue;
							}
						} else {
							pending += 1;
							links.push(p.handle((function(check) {
								return function(o) {
									pending -= 1;
									check[0](o);
									if(!done) {
										step();
									}
								};
							})(check)));
						}
						break;
					}
				}
			};
			var _g = 0;
			var _g1 = concurrency1;
			while(_g < _g1) {
				var i = _g++;
				step();
			}
			return tink_core_CallbackLink.fromMany(links);
		});
		return this1;
	}
};
tink_core_Future.async = function(init,lazy) {
	if(lazy == null) {
		lazy = false;
	}
	var ret = tink_core_Future.irreversible(init);
	if(lazy) {
		return ret;
	} else {
		ret.eager();
		return ret;
	}
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
	tink_core__$Future_FutureObject.call(this);
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
tink_core__$Future_SuspendableFuture.__super__ = tink_core__$Future_FutureObject;
tink_core__$Future_SuspendableFuture.prototype = $extend(tink_core__$Future_FutureObject.prototype,{
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
	,eager: function() {
		switch(this.status._hx_index) {
		case 0:
			this.status = tink_core_FutureStatus.EagerlyAwaited;
			this.arm();
			break;
		case 1:
			this.status = tink_core_FutureStatus.EagerlyAwaited;
			break;
		default:
		}
	}
	,__class__: tink_core__$Future_SuspendableFuture
});
var tink_core_Lazy = {};
tink_core_Lazy.get = function(this1) {
	this1.compute();
	return this1.get();
};
var tink_core__$Lazy_LazyFunc = function(f,from) {
	this.f = f;
	this.from = from;
};
tink_core__$Lazy_LazyFunc.__name__ = "tink.core._Lazy.LazyFunc";
tink_core__$Lazy_LazyFunc.prototype = {
	underlying: function() {
		return this.from;
	}
	,isComputed: function() {
		return this.f == null;
	}
	,get: function() {
		return this.result;
	}
	,compute: function() {
		var _g = this.f;
		if(_g != null) {
			var v = _g;
			this.f = null;
			var _g = this.from;
			if(_g != null) {
				var cur = _g;
				this.from = null;
				var stack = [];
				while(cur != null && !cur.isComputed()) {
					stack.push(cur);
					cur = cur.underlying();
				}
				stack.reverse();
				var _g = 0;
				while(_g < stack.length) {
					var c = stack[_g];
					++_g;
					c.compute();
				}
			}
			this.result = v();
		}
	}
	,__class__: tink_core__$Lazy_LazyFunc
};
var tink_core_Outcome = $hxEnums["tink.core.Outcome"] = { __ename__:true,__constructs__:null
	,Success: ($_=function(data) { return {_hx_index:0,data:data,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Success",$_.__params__ = ["data"],$_)
	,Failure: ($_=function(failure) { return {_hx_index:1,failure:failure,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Failure",$_.__params__ = ["failure"],$_)
};
tink_core_Outcome.__constructs__ = [tink_core_Outcome.Success,tink_core_Outcome.Failure];
var tink_core_Promise = {};
tink_core_Promise.never = function() {
	return tink_core_Future.never();
};
tink_core_Promise.noise = function(this1) {
	if(this1.getStatus()._hx_index == 4) {
		return tink_core_Promise.never();
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
tink_core_Promise.inParallel = function(a,concurrency) {
	return tink_core_Promise.many(a,concurrency);
};
tink_core_Promise.many = function(a,concurrency) {
	return tink_core_Future.processMany(a,concurrency,function(o) {
		return o;
	},function(o) {
		return o;
	});
};
tink_core_Promise.inSequence = function(a) {
	return tink_core_Promise.many(a,1);
};
var tink_s2d_Geometry = $hxEnums["tink.s2d.Geometry"] = { __ename__:true,__constructs__:null
	,Point: ($_=function(v) { return {_hx_index:0,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="Point",$_.__params__ = ["v"],$_)
	,LineString: ($_=function(v) { return {_hx_index:1,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="LineString",$_.__params__ = ["v"],$_)
	,Polygon: ($_=function(v) { return {_hx_index:2,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="Polygon",$_.__params__ = ["v"],$_)
	,MultiPoint: ($_=function(v) { return {_hx_index:3,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="MultiPoint",$_.__params__ = ["v"],$_)
	,MultiLineString: ($_=function(v) { return {_hx_index:4,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="MultiLineString",$_.__params__ = ["v"],$_)
	,MultiPolygon: ($_=function(v) { return {_hx_index:5,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="MultiPolygon",$_.__params__ = ["v"],$_)
	,GeometryCollection: ($_=function(v) { return {_hx_index:6,v:v,__enum__:"tink.s2d.Geometry",toString:$estr}; },$_._hx_name="GeometryCollection",$_.__params__ = ["v"],$_)
};
tink_s2d_Geometry.__constructs__ = [tink_s2d_Geometry.Point,tink_s2d_Geometry.LineString,tink_s2d_Geometry.Polygon,tink_s2d_Geometry.MultiPoint,tink_s2d_Geometry.MultiLineString,tink_s2d_Geometry.MultiPolygon,tink_s2d_Geometry.GeometryCollection];
var tink_s2d_LineString = {};
tink_s2d_LineString.toWkt = function(this1) {
	if(this1.length == 0) {
		return "LINESTRING EMPTY";
	} else {
		var result = new Array(this1.length);
		var _g = 0;
		var _g1 = this1.length;
		while(_g < _g1) {
			var i = _g++;
			var point = this1[i];
			result[i] = "" + point[0] + " " + point[1];
		}
		return "LINESTRING(" + result.join(",") + ")";
	}
};
var tink_s2d_MultiLineString = {};
tink_s2d_MultiLineString.toWkt = function(this1) {
	if(this1.length == 0) {
		return "MULTILINESTRING EMPTY";
	} else {
		var result = new Array(this1.length);
		var _g = 0;
		var _g1 = this1.length;
		while(_g < _g1) {
			var i = _g++;
			var line = this1[i];
			var result1 = new Array(line.length);
			var _g2 = 0;
			var _g3 = line.length;
			while(_g2 < _g3) {
				var i1 = _g2++;
				var point = line[i1];
				result1[i1] = "" + point[0] + " " + point[1];
			}
			result[i] = "(" + result1.join(",") + ")";
		}
		return "MULTILINESTRING(" + result.join(",") + ")";
	}
};
var tink_s2d_MultiPoint = {};
tink_s2d_MultiPoint.toWkt = function(this1) {
	if(this1.length == 0) {
		return "MULTIPOINT EMPTY";
	} else {
		var result = new Array(this1.length);
		var _g = 0;
		var _g1 = this1.length;
		while(_g < _g1) {
			var i = _g++;
			var point = this1[i];
			result[i] = "" + point[0] + " " + point[1];
		}
		return "MULTIPOINT(" + result.join(",") + ")";
	}
};
var tink_s2d_MultiPolygon = {};
tink_s2d_MultiPolygon.toWkt = function(this1) {
	if(this1.length == 0) {
		return "MULTIPOLYGON EMPTY";
	} else {
		var result = new Array(this1.length);
		var _g = 0;
		var _g1 = this1.length;
		while(_g < _g1) {
			var i = _g++;
			var polygon = this1[i];
			var result1 = new Array(polygon.length);
			var _g2 = 0;
			var _g3 = polygon.length;
			while(_g2 < _g3) {
				var i1 = _g2++;
				var line = polygon[i1];
				var result2 = new Array(line.length);
				var _g4 = 0;
				var _g5 = line.length;
				while(_g4 < _g5) {
					var i2 = _g4++;
					var point = line[i2];
					result2[i2] = "" + point[0] + " " + point[1];
				}
				result1[i1] = "(" + result2.join(",") + ")";
			}
			result[i] = "(" + result1.join(",") + ")";
		}
		return "MULTIPOLYGON(" + result.join(",") + ")";
	}
};
var tink_s2d_Point = {};
tink_s2d_Point.isEmpty = function(this1) {
	if(this1.length != 0) {
		if(isNaN(this1[0])) {
			return isNaN(this1[1]);
		} else {
			return false;
		}
	} else {
		return true;
	}
};
tink_s2d_Point.toWkt = function(this1) {
	if(tink_s2d_Point.isEmpty(this1)) {
		return "POINT EMPTY";
	} else {
		return "POINT(" + ("" + this1[0] + " " + this1[1]) + ")";
	}
};
var tink_s2d_Polygon = {};
tink_s2d_Polygon.toWkt = function(this1) {
	if(this1.length == 0) {
		return "POLYGON EMPTY";
	} else {
		var result = new Array(this1.length);
		var _g = 0;
		var _g1 = this1.length;
		while(_g < _g1) {
			var i = _g++;
			var line = this1[i];
			var result1 = new Array(line.length);
			var _g2 = 0;
			var _g3 = line.length;
			while(_g2 < _g3) {
				var i1 = _g2++;
				var point = line[i1];
				result1[i1] = "" + point[0] + " " + point[1];
			}
			result[i] = "(" + result1.join(",") + ")";
		}
		return "POLYGON(" + result.join(",") + ")";
	}
};
var tink_s3d_Geometry = $hxEnums["tink.s3d.Geometry"] = { __ename__:true,__constructs__:null
	,Point: ($_=function(v) { return {_hx_index:0,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="Point",$_.__params__ = ["v"],$_)
	,LineString: ($_=function(v) { return {_hx_index:1,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="LineString",$_.__params__ = ["v"],$_)
	,Polygon: ($_=function(v) { return {_hx_index:2,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="Polygon",$_.__params__ = ["v"],$_)
	,MultiPoint: ($_=function(v) { return {_hx_index:3,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="MultiPoint",$_.__params__ = ["v"],$_)
	,MultiLineString: ($_=function(v) { return {_hx_index:4,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="MultiLineString",$_.__params__ = ["v"],$_)
	,MultiPolygon: ($_=function(v) { return {_hx_index:5,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="MultiPolygon",$_.__params__ = ["v"],$_)
	,GeometryCollection: ($_=function(v) { return {_hx_index:6,v:v,__enum__:"tink.s3d.Geometry",toString:$estr}; },$_._hx_name="GeometryCollection",$_.__params__ = ["v"],$_)
};
tink_s3d_Geometry.__constructs__ = [tink_s3d_Geometry.Point,tink_s3d_Geometry.LineString,tink_s3d_Geometry.Polygon,tink_s3d_Geometry.MultiPoint,tink_s3d_Geometry.MultiLineString,tink_s3d_Geometry.MultiPolygon,tink_s3d_Geometry.GeometryCollection];
var tink_spatial_Geometry = $hxEnums["tink.spatial.Geometry"] = { __ename__:true,__constructs__:null
	,S2D: ($_=function(v) { return {_hx_index:0,v:v,__enum__:"tink.spatial.Geometry",toString:$estr}; },$_._hx_name="S2D",$_.__params__ = ["v"],$_)
	,S3D: ($_=function(v) { return {_hx_index:1,v:v,__enum__:"tink.spatial.Geometry",toString:$estr}; },$_._hx_name="S3D",$_.__params__ = ["v"],$_)
};
tink_spatial_Geometry.__constructs__ = [tink_spatial_Geometry.S2D,tink_spatial_Geometry.S3D];
var tink_spatial_Parser = function() { };
tink_spatial_Parser.__name__ = "tink.spatial.Parser";
tink_spatial_Parser.wkb = function(bytes) {
	var this1 = new haxe_io_BytesInput(bytes,0);
	return tink_spatial_Buffer.parseGeometry(this1,false);
};
var tink_spatial_Buffer = {};
tink_spatial_Buffer.parseGeometry = function(this1,extended) {
	if(extended == null) {
		extended = false;
	}
	this1.set_bigEndian(this1.readByte() == 0);
	var type = this1.readInt32();
	if(extended && (type & 536870912) != 0) {
		type &= -536870913;
		this1.readInt32();
	}
	switch(type) {
	case 1:
		var this2 = [this1.readDouble(),this1.readDouble()];
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.Point(this2));
	case 2:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var this2 = [this1.readDouble(),this1.readDouble()];
			_g.push(this2);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.LineString(this2));
	case 3:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = [];
			var _g4 = 0;
			var _g5 = this1.readInt32();
			while(_g4 < _g5) {
				var _1 = _g4++;
				var this2 = [this1.readDouble(),this1.readDouble()];
				_g3.push(this2);
			}
			var this3 = _g3;
			_g.push(this3);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.Polygon(this2));
	case 4:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 0) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 0) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiPoint(2D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiPoint(2D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.MultiPoint(this2));
	case 5:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 0) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 1) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiLineString(2D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiLineString(2D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.MultiLineString(this2));
	case 6:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 0) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 2) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiPolygon(2D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiPolygon(2D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.MultiPolygon(this2));
	case 7:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 0) {
				var v = _g3.v;
				tmp = v;
			} else {
				var v1 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside GeometryCollection(2D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S2D(tink_s2d_Geometry.GeometryCollection(this2));
	case 1001:
		var this2 = [this1.readDouble(),this1.readDouble(),this1.readDouble()];
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.Point(this2));
	case 1002:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var this2 = [this1.readDouble(),this1.readDouble(),this1.readDouble()];
			_g.push(this2);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.LineString(this2));
	case 1003:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = [];
			var _g4 = 0;
			var _g5 = this1.readInt32();
			while(_g4 < _g5) {
				var _1 = _g4++;
				var this2 = [this1.readDouble(),this1.readDouble(),this1.readDouble()];
				_g3.push(this2);
			}
			var this3 = _g3;
			_g.push(this3);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.Polygon(this2));
	case 1004:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 1) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 0) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiPoint(3D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiPoint(3D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.MultiPoint(this2));
	case 1005:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 1) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 1) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiLineString(3D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiLineString(3D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.MultiLineString(this2));
	case 1006:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 1) {
				var _g4 = _g3.v;
				if(_g4._hx_index == 2) {
					var v = _g4.v;
					tmp = v;
				} else {
					var v1 = _g3;
					throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside MultiPolygon(3D)");
				}
			} else {
				var v2 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v2) + " inside MultiPolygon(3D)");
			}
			_g.push(tmp);
		}
		var this2 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.MultiPolygon(this2));
	case 1007:
		var _g = [];
		var _g1 = 0;
		var _g2 = this1.readInt32();
		while(_g1 < _g2) {
			var _ = _g1++;
			var _g3 = tink_spatial_Buffer.parseGeometry(this1);
			var tmp;
			if(_g3._hx_index == 1) {
				var v = _g3.v;
				tmp = v;
			} else {
				var v1 = _g3;
				throw haxe_Exception.thrown("Unexpected " + Std.string(v1) + " inside GeometryCollection(3D)");
			}
			_g.push(tmp);
		}
		var this1 = _g;
		return tink_spatial_Geometry.S3D(tink_s3d_Geometry.GeometryCollection(this1));
	default:
		var v = type;
		throw haxe_Exception.thrown("WKB type \"" + v + "\" not supported");
	}
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
	toQuery: function(limit) {
		throw haxe_Exception.thrown("implement");
	}
	,stream: function() {
		return this.cnx.execute(this.toQuery());
	}
	,all: function() {
		return tink_streams_RealStream.collect(this.stream());
	}
	,first: function() {
		return tink_core_Promise.next(this.all(),function(r) {
			if(r.length == 0) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Failure(new tink_core_TypedError(404,"The requested item was not found",{ fileName : "tink/sql/Dataset.hx", lineNumber : 225, className : "tink.sql.Dataset", methodName : "first"}))));
			} else {
				var v = r;
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(v[0])));
			}
		});
	}
	,__class__: tink_sql_Dataset
};
var tink_sql_Limitable = function(cnx) {
	tink_sql_Dataset.call(this,cnx);
};
tink_sql_Limitable.__name__ = "tink.sql.Limitable";
tink_sql_Limitable.__super__ = tink_sql_Dataset;
tink_sql_Limitable.prototype = $extend(tink_sql_Dataset.prototype,{
	limit: function(limit) {
		return new tink_sql_Limited(this.cnx,limit,$bind(this,this.toQuery));
	}
	,first: function() {
		return this.limit(tink_sql_Limit.ofInt(1)).first();
	}
	,__class__: tink_sql_Limitable
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
	toSelectOp: function(limit) {
		return { from : this.target, selection : this.selection, where : this.condition.where, having : this.condition.having, limit : limit, groupBy : this.grouped, orderBy : this.order};
	}
	,toQuery: function(limit) {
		return tink_sql_Query.Select(this.toSelectOp(limit));
	}
	,__class__: tink_sql_Selected
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
	_select: function(selection) {
		return new tink_sql_FilterableWhere(this.cnx,this.fields,this.target,this.toCondition,this.condition,selection);
	}
	,__class__: tink_sql_Selectable
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
	create: function(ifNotExists) {
		if(ifNotExists == null) {
			ifNotExists = false;
		}
		return this.cnx.execute(tink_sql_Query.CreateTable(this.info,ifNotExists));
	}
	,insertMany: function(rows,options) {
		if(rows.length == 0) {
			return tink_core_Promise.NOISE;
		} else {
			return this.insert(tink_sql_InsertData.Literal(rows),options);
		}
	}
	,insertOne: function(row,options) {
		return this.insert(tink_sql_InsertData.Literal([row]),options);
	}
	,insert: function(data,options) {
		return this.cnx.execute(tink_sql_Query.Insert({ table : this.info, data : data, ignore : options != null && !(!options.ignore), replace : options != null && !(!options.replace), update : options != null && options.update != null ? options.update(this.fields) : null}));
	}
	,update: function(f,options) {
		var _g = f(this.fields);
		if(_g.length == 0) {
			return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success({ rowsAffected : 0})));
		} else {
			var patch = _g;
			return this.cnx.execute(tink_sql_Query.Update({ table : this.info, set : patch, where : this.toCondition(options.where), max : options.max}));
		}
	}
	,__class__: tink_sql_TableSource
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
var tink_sql_Key = $hxEnums["tink.sql.Key"] = { __ename__:true,__constructs__:null
	,Primary: ($_=function(fields) { return {_hx_index:0,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Primary",$_.__params__ = ["fields"],$_)
	,Unique: ($_=function(name,fields) { return {_hx_index:1,name:name,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Unique",$_.__params__ = ["name","fields"],$_)
	,Index: ($_=function(name,fields) { return {_hx_index:2,name:name,fields:fields,__enum__:"tink.sql.Key",toString:$estr}; },$_._hx_name="Index",$_.__params__ = ["name","fields"],$_)
};
tink_sql_Key.__constructs__ = [tink_sql_Key.Primary,tink_sql_Key.Unique,tink_sql_Key.Index];
var tink_sql_TableStaticInfo = function(columns,keys) {
	this.columns = columns;
	this.keys = keys;
};
tink_sql_TableStaticInfo.__name__ = "tink.sql.TableStaticInfo";
tink_sql_TableStaticInfo.prototype = {
	getColumns: function() {
		return this.columns;
	}
	,columnNames: function() {
		var _g = [];
		var _g1 = 0;
		var _g2 = this.columns;
		while(_g1 < _g2.length) {
			var c = _g2[_g1];
			++_g1;
			_g.push(c.name);
		}
		return _g;
	}
	,getKeys: function() {
		return this.keys;
	}
	,__class__: tink_sql_TableStaticInfo
};
var tink_sql_Table0 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "textValue";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DText(tink_sql_TextSize.Medium,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"textValue",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "type";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"type",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table0.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ id : this1, textValue : this2, type : this3},tmp);
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
	getName: function() {
		return this.name;
	}
	,getAlias: function() {
		return this.alias;
	}
	,__class__: tink_sql_TableInstanceInfo
});
var tink_sql_Table1 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "descItem";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"descItem",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table1.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ descItem : this1, id : this2},tmp);
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
	var inlobj_name = "description";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
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
	var tmp = tink_sql_Table2.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ description : this1, id : this2, isHook : this3, name : this4, stateClient : this5, stateMenu : this6, stateServer : this7, url : this8},tmp);
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
	var inlobj_name = "argumentNo";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"argumentNo",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "def";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"def",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "description";
	var inlobj_nullable = true;
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
	var tmp = tink_sql_Table3.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ argumentNo : this1, def : this2, description : this3, funcid : this4, name : this5, type : this6, typeURL : this7},tmp);
};
tink_sql_Table3.__name__ = "tink.sql.Table3";
tink_sql_Table3.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table3.INFO.columns,tink_sql_Table3.INFO.keys);
};
tink_sql_Table3.__super__ = tink_sql_TableSource;
tink_sql_Table3.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table3
});
var tink_sql_Table4 = function(cnx,tableName,alias) {
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
	var tmp = tink_sql_Table4.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ desc : this1, funcid : this2, returnNo : this3, type : this4, typeURL : this5},tmp);
};
tink_sql_Table4.__name__ = "tink.sql.Table4";
tink_sql_Table4.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table4.INFO.columns,tink_sql_Table4.INFO.keys);
};
tink_sql_Table4.__super__ = tink_sql_TableSource;
tink_sql_Table4.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table4
});
var tink_sql_Table5 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "code";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"code",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "desc";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"desc",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "exampleNo";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"exampleNo",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "funcid";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"funcid",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "output";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"output",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table5.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ code : this1, desc : this2, exampleNo : this3, funcid : this4, output : this5},tmp);
};
tink_sql_Table5.__name__ = "tink.sql.Table5";
tink_sql_Table5.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table5.INFO.columns,tink_sql_Table5.INFO.keys);
};
tink_sql_Table5.__super__ = tink_sql_TableSource;
tink_sql_Table5.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table5
});
var tink_sql_Table6 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "description";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "url";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"url",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table6.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ description : this1, id : this2, name : this3, url : this4},tmp);
};
tink_sql_Table6.__name__ = "tink.sql.Table6";
tink_sql_Table6.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table6.INFO.columns,tink_sql_Table6.INFO.keys);
};
tink_sql_Table6.__super__ = tink_sql_TableSource;
tink_sql_Table6.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table6
});
var tink_sql_Table7 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "def";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"def",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "structID";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"structID",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "structOrder";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"structOrder",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "type";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"type",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "typeURL";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this6 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"typeURL",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table7.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ def : this1, name : this2, structID : this3, structOrder : this4, type : this5, typeURL : this6},tmp);
};
tink_sql_Table7.__name__ = "tink.sql.Table7";
tink_sql_Table7.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table7.INFO.columns,tink_sql_Table7.INFO.keys);
};
tink_sql_Table7.__super__ = tink_sql_TableSource;
tink_sql_Table7.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table7
});
var tink_sql_Table8 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "description";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "url";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"url",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table8.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ description : this1, id : this2, name : this3, url : this4},tmp);
};
tink_sql_Table8.__name__ = "tink.sql.Table8";
tink_sql_Table8.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table8.INFO.columns,tink_sql_Table8.INFO.keys);
};
tink_sql_Table8.__super__ = tink_sql_TableSource;
tink_sql_Table8.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table8
});
var tink_sql_Table9 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "description";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"description",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "name";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"name",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "url";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"url",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table9.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ description : this1, id : this2, name : this3, url : this4},tmp);
};
tink_sql_Table9.__name__ = "tink.sql.Table9";
tink_sql_Table9.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table9.INFO.columns,tink_sql_Table9.INFO.keys);
};
tink_sql_Table9.__super__ = tink_sql_TableSource;
tink_sql_Table9.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table9
});
var tink_sql_Table10 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "desc";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"desc",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "id";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"id",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "url";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(1024,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"url",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table10.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ desc : this1, id : this2, url : this3},tmp);
};
tink_sql_Table10.__name__ = "tink.sql.Table10";
tink_sql_Table10.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table10.INFO.columns,tink_sql_Table10.INFO.keys);
};
tink_sql_Table10.__super__ = tink_sql_TableSource;
tink_sql_Table10.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table10
});
var tink_sql_Table11 = function(cnx,tableName,alias) {
	var this1 = tableName;
	var name = this1;
	var inlobj_name = "desc";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this1 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"desc",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "enumID";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null);
	var inlobj_writable = true;
	var this2 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"enumID",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "enumName";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this3 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"enumName",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "memberNo";
	var inlobj_nullable = false;
	var inlobj_type = tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null);
	var inlobj_writable = true;
	var this4 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"memberNo",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var inlobj_name = "value";
	var inlobj_nullable = true;
	var inlobj_type = tink_sql_DataType.DString(255,null);
	var inlobj_writable = true;
	var this5 = tink_sql_Expr.ofData(tink_sql_ExprData.EField(alias,"value",tink_sql_expr_ExprTyper.typeColumn(inlobj_type)));
	var tmp = tink_sql_Table11.makeInfo(name,alias);
	tink_sql_TableSource.call(this,cnx,name,alias,{ desc : this1, enumID : this2, enumName : this3, memberNo : this4, value : this5},tmp);
};
tink_sql_Table11.__name__ = "tink.sql.Table11";
tink_sql_Table11.makeInfo = function(name,alias) {
	return new tink_sql_TableInstanceInfo(name,alias,tink_sql_Table11.INFO.columns,tink_sql_Table11.INFO.keys);
};
tink_sql_Table11.__super__ = tink_sql_TableSource;
tink_sql_Table11.prototype = $extend(tink_sql_TableSource.prototype,{
	__class__: tink_sql_Table11
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
	this.DescItem = new tink_sql_Table0(cnx,"DescItem","DescItem");
	this.DescriptionStorage = new tink_sql_Table1(cnx,"DescriptionStorage","DescriptionStorage");
	this.Function = new tink_sql_Table2(cnx,"Function","Function");
	this.FunctionArg = new tink_sql_Table3(cnx,"FunctionArg","FunctionArg");
	this.FunctionRet = new tink_sql_Table4(cnx,"FunctionRet","FunctionRet");
	this.LuaExample = new tink_sql_Table5(cnx,"LuaExample","LuaExample");
	this.Struct = new tink_sql_Table6(cnx,"Struct","Struct");
	this.StructMember = new tink_sql_Table7(cnx,"StructMember","StructMember");
	this.GClass = new tink_sql_Table8(cnx,"GClass","GClass");
	this.Library = new tink_sql_Table9(cnx,"Library","Library");
	this.GEnum = new tink_sql_Table10(cnx,"GEnum","GEnum");
	this.GEnumMembers = new tink_sql_Table11(cnx,"GEnumMembers","GEnumMembers");
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
var tink_sql_Limited = function(cnx,limit,create) {
	tink_sql_Dataset.call(this,cnx);
	this.limit = limit;
	this.create = create;
};
tink_sql_Limited.__name__ = "tink.sql.Limited";
tink_sql_Limited.__super__ = tink_sql_Dataset;
tink_sql_Limited.prototype = $extend(tink_sql_Dataset.prototype,{
	toQuery: function(_) {
		return this.create(this.limit);
	}
	,__class__: tink_sql_Limited
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
tink_sql_Expr.eq = function(a,b) {
	return tink_sql_Expr.ofData(tink_sql_ExprData.EBinOp(tink_sql_BinOp.Equals,a,b));
};
var tink_sql_Limit = {};
tink_sql_Limit.ofInt = function(i) {
	return { limit : i, offset : 0};
};
var tink_sql_Order = $hxEnums["tink.sql.Order"] = { __ename__:true,__constructs__:null
	,Asc: {_hx_name:"Asc",_hx_index:0,__enum__:"tink.sql.Order",toString:$estr}
	,Desc: {_hx_name:"Desc",_hx_index:1,__enum__:"tink.sql.Order",toString:$estr}
};
tink_sql_Order.__constructs__ = [tink_sql_Order.Asc,tink_sql_Order.Desc];
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
var tink_sql_FieldUpdate = function(field,expr) {
	this.field = field;
	this.expr = expr;
};
tink_sql_FieldUpdate.__name__ = "tink.sql.FieldUpdate";
tink_sql_FieldUpdate.prototype = {
	__class__: tink_sql_FieldUpdate
};
var tink_sql_InsertData = $hxEnums["tink.sql.InsertData"] = { __ename__:true,__constructs__:null
	,Literal: ($_=function(data) { return {_hx_index:0,data:data,__enum__:"tink.sql.InsertData",toString:$estr}; },$_._hx_name="Literal",$_.__params__ = ["data"],$_)
	,Select: ($_=function(op) { return {_hx_index:1,op:op,__enum__:"tink.sql.InsertData",toString:$estr}; },$_._hx_name="Select",$_.__params__ = ["op"],$_)
};
tink_sql_InsertData.__constructs__ = [tink_sql_InsertData.Literal,tink_sql_InsertData.Select];
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
var tink_sql_Id = {};
tink_sql_Id.toExpr = function(this1) {
	var this2 = this1;
	return tink_sql_Expr.ofData(tink_sql_ExprData.EValue(this2,tink_sql_ExprType.VInt));
};
var tink_sql_drivers__$MySql_MySqlSanitizer = function() {
};
tink_sql_drivers__$MySql_MySqlSanitizer.__name__ = "tink.sql.drivers._MySql.MySqlSanitizer";
tink_sql_drivers__$MySql_MySqlSanitizer.prototype = {
	ident: function(s) {
		var buf_b = "";
		buf_b += String.fromCodePoint(96);
		var _g = 0;
		var _g1 = s.length;
		while(_g < _g1) {
			var c = _g++;
			var _g2 = s.charCodeAt(c);
			if(_g2 == 96) {
				buf_b += String.fromCodePoint(96);
				buf_b += String.fromCodePoint(96);
			} else {
				var v = _g2;
				buf_b += String.fromCodePoint(v);
			}
		}
		buf_b += String.fromCodePoint(96);
		return buf_b;
	}
	,__class__: tink_sql_drivers__$MySql_MySqlSanitizer
};
var tink_sql_drivers_MySql = {};
tink_sql_drivers_MySql.getSanitizer = function(_) {
	return tink_sql_drivers_MySql.sanitizer;
};
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
	this.formatter = new tink_sql_format_SqliteFormatter();
	this.info = info;
	this.cnx = cnx;
	this.parser = new tink_sql_parse_ResultParser();
};
tink_sql_drivers_node_Sqlite3Connection.__name__ = "tink.sql.drivers.node.Sqlite3Connection";
tink_sql_drivers_node_Sqlite3Connection.prototype = {
	toError: function(error) {
		return tink_core_Outcome.Failure(tink_core_TypedError.withData(null,error.message,error,{ fileName : "tink/sql/drivers/node/Sqlite3.hx", lineNumber : 56, className : "tink.sql.drivers.node.Sqlite3Connection", methodName : "toError"}));
	}
	,streamStatement: function(statement,parse) {
		var next = null;
		next = function(step) {
			statement.get([],function(error,row) {
				var step1 = step;
				var next1;
				if(error == null) {
					if(row == null) {
						statement.finalize();
						next1 = tink_streams_Step.End;
					} else {
						var row1 = row;
						next1 = tink_streams_Step.Link(parse(row1),tink_streams_Generator.stream(next));
					}
				} else {
					var error1 = error;
					next1 = tink_streams_Step.Fail(tink_core_TypedError.withData(null,error1.message,error1,{ fileName : "tink/sql/drivers/node/Sqlite3.hx", lineNumber : 70, className : "tink.sql.drivers.node.Sqlite3Connection", methodName : "streamStatement"}));
				}
				step1(next1);
			});
		};
		return tink_streams_Generator.stream(next);
	}
	,execute: function(query) {
		var _gthis = this;
		switch(query._hx_index) {
		case 0:
			var _g = query.union;
			var parse = this.parser.queryParser(query,this.formatter.isNested(query));
			return tink_streams_Stream.promise(tink_core_Promise.next(this.get(query),function(statement) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(_gthis.streamStatement(statement,parse))));
			}));
		case 1:
			var _g = query.select;
			var parse1 = this.parser.queryParser(query,this.formatter.isNested(query));
			return tink_streams_Stream.promise(tink_core_Promise.next(this.get(query),function(statement) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(_gthis.streamStatement(statement,parse1))));
			}));
		case 2:
			var _g = query.insert;
			return tink_core_Promise.next(this.run(query),function(res) {
				var this1 = res.lastID;
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(this1)));
			});
		case 3:
			var _g = query.update;
			return tink_core_Promise.next(this.run(query),function(res) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success({ rowsAffected : res.changes})));
			});
		case 4:
			var _g = query.$delete;
			return tink_core_Promise.next(this.run(query),function(res) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success({ rowsAffected : res.changes})));
			});
		case 5:
			var _g = query.call;
			var parse2 = this.parser.queryParser(query,this.formatter.isNested(query));
			return tink_streams_Stream.promise(tink_core_Promise.next(this.get(query),function(statement) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(_gthis.streamStatement(statement,parse2))));
			}));
		case 6:
			var _g = query.table;
			var _g = query.ifNotExists;
			return tink_core_Promise.next(this.run(query),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
			});
		case 7:
			var _g = query.table;
			return tink_core_Promise.next(this.run(query),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
			});
		case 8:
			var table = query.table;
			return tink_core_Promise.next(this.run(tink_sql_Query.Delete({ from : table})),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
			});
		case 9:
			var _g = query.table;
			var _g = query.changes;
			return tink_core_Promise.next(this.run(query),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
			});
		case 12:
			var _g = query.transaction;
			return tink_core_Promise.next(this.run(query),function(_) {
				return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
			});
		default:
			throw haxe_Exception.thrown("Operation not supported");
		}
	}
	,prepare: function(query) {
		return tink_sql_format_Statement.prepare(this.formatter.format(query),($_=tink_sql_drivers_MySql.getSanitizer(null),$bind($_,$_.ident)));
	}
	,get: function(query) {
		var _gthis = this;
		return tink_core_Future.async(function(done) {
			var prepared = _gthis.prepare(query);
			var res = null;
			res = _gthis.cnx.prepare(prepared.query,prepared.values,function(error) {
				done(error != null ? _gthis.toError(error) : tink_core_Outcome.Success(res));
			});
		});
	}
	,run: function(query) {
		var _gthis = this;
		return tink_core_Future.async(function(done) {
			var prepared = _gthis.prepare(query);
			_gthis.cnx.run(prepared.query,prepared.values,function(error) {
				done(error == null ? tink_core_Outcome.Success(this) : _gthis.toError(error));
			});
		});
	}
	,__class__: tink_sql_drivers_node_Sqlite3Connection
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
tink_sql_expr_ExprTyper.nameField = function(table,field,alias) {
	return (alias != null ? alias : table) + "@@@" + field;
};
tink_sql_expr_ExprTyper.typeTarget = function(target,nest) {
	if(nest == null) {
		nest = false;
	}
	switch(target._hx_index) {
	case 0:
		var table = target.table;
		var _g = new haxe_ds_StringMap();
		var column = $getIterator(table.getColumns());
		while(column.hasNext()) {
			var column1 = column.next();
			var key = nest ? tink_sql_expr_ExprTyper.nameField(table.getName(),column1.name,table.getAlias()) : column1.name;
			var value = tink_sql_expr_ExprTyper.typeColumn(column1.type);
			_g.h[key] = value;
		}
		return _g;
	case 1:
		var _g = target.type;
		var _g = target.c;
		var left = target.left;
		var right = target.right;
		var res = tink_sql_expr_ExprTyper.typeTarget(left,true);
		var add = tink_sql_expr_ExprTyper.typeTarget(right,true);
		var h = add.h;
		var field_h = h;
		var field_keys = Object.keys(h);
		var field_length = field_keys.length;
		var field_current = 0;
		while(field_current < field_length) {
			var field = field_keys[field_current++];
			var v = add.h[field];
			res.h[field] = v;
		}
		return res;
	case 2:
		var alias = target.alias;
		var query = target.query;
		var types = tink_sql_expr_ExprTyper.typeQuery(query);
		var _g = new haxe_ds_StringMap();
		var h = types.h;
		var field_h = h;
		var field_keys = Object.keys(h);
		var field_length = field_keys.length;
		var field_current = 0;
		while(field_current < field_length) {
			var field = field_keys[field_current++];
			var key = tink_sql_expr_ExprTyper.nameField(alias,field);
			_g.h[key] = types.h[field];
		}
		return _g;
	}
};
tink_sql_expr_ExprTyper.typeQuery = function(query) {
	switch(query._hx_index) {
	case 0:
		var _g = query.union;
		var _g1 = _g.distinct;
		var _g1 = _g.limit;
		var _g1 = _g.right;
		var left = _g.left;
		return tink_sql_expr_ExprTyper.typeQuery(left);
	case 1:
		var _g = query.select;
		var _g1 = _g.from;
		var _g2 = _g.groupBy;
		var _g2 = _g.having;
		var _g2 = _g.limit;
		var _g2 = _g.orderBy;
		var _g2 = _g.where;
		var selection = _g.selection;
		if(selection != null) {
			var _g = new haxe_ds_StringMap();
			var _g2 = 0;
			var _g3 = Reflect.fields(selection);
			while(_g2 < _g3.length) {
				var key = _g3[_g2];
				++_g2;
				var value = tink_sql_expr_ExprTyper.type(selection[key]);
				_g.h[key] = value;
			}
			return _g;
		} else {
			var target = _g1;
			return tink_sql_expr_ExprTyper.typeTarget(target);
		}
		break;
	case 5:
		var _g = query.call;
		return new haxe_ds_StringMap();
	default:
		throw haxe_Exception.thrown("cannot type non selection: " + Std.string(query));
	}
};
tink_sql_expr_ExprTyper.type = function(expr) {
	var res;
	var _g = expr;
	switch(_g._hx_index) {
	case 0:
		var _g1 = _g.op;
		var _g1 = _g.a;
		var _g1 = _g.postfix;
		res = tink_sql_ExprType.VBool;
		break;
	case 1:
		var _g1 = _g.a;
		var _g1 = _g.b;
		switch(_g.op._hx_index) {
		case 0:case 1:case 2:case 3:case 4:
			res = tink_sql_ExprType.VFloat;
			break;
		default:
			res = tink_sql_ExprType.VBool;
		}
		break;
	case 2:
		var _g1 = _g.table;
		var _g1 = _g.name;
		var type = _g.type;
		res = type;
		break;
	case 3:
		var _g1 = _g.name;
		var _g1 = _g.args;
		var _g1 = _g.parenthesis;
		var type = _g.type;
		res = type;
		break;
	case 4:
		var _g1 = _g.value;
		var type = _g.type;
		res = type;
		break;
	case 5:
		var type = _g.type;
		res = type;
		break;
	case 6:
		var _g1 = _g.query;
		var type = _g.type;
		res = type;
		break;
	}
	if(res._hx_index == 10) {
		var expr = res.expr;
		return tink_sql_expr_ExprTyper.type(expr);
	} else {
		var v = res;
		return v;
	}
};
var tink_sql_expr_Field = {};
tink_sql_expr_Field.get_name = function(this1) {
	var _g = this1;
	if(_g._hx_index == 2) {
		var _g1 = _g.table;
		var _g1 = _g.type;
		var v = _g.name;
		return v;
	} else {
		var v = _g;
		throw haxe_Exception.thrown("assert: invalid field " + Std.string(v));
	}
};
tink_sql_expr_Field.set = function(this1,e) {
	return new tink_sql_FieldUpdate(this1,e);
};
tink_sql_expr_Field.eqFloat = function(a,b) {
	return tink_sql_Expr.eq(a,tink_sql_Expr.ofData(tink_sql_ExprData.EValue(b,tink_sql_ExprType.VFloat)));
};
var tink_sql_expr_Functions = function() { };
tink_sql_expr_Functions.__name__ = "tink.sql.expr.Functions";
tink_sql_expr_Functions.max = function(e) {
	return tink_sql_Expr.ofData(tink_sql_ExprData.ECall("MAX",[e],tink_sql_ExprType.VTypeOf(e)));
};
var tink_sql_format_SqlFormatter = function() {
};
tink_sql_format_SqlFormatter.__name__ = "tink.sql.format.SqlFormatter";
tink_sql_format_SqlFormatter.prototype = {
	format: function(query) {
		switch(query._hx_index) {
		case 0:
			var op = query.union;
			return this.union(op);
		case 1:
			var op = query.select;
			return this.select(op);
		case 2:
			var op = query.insert;
			return this.insert(op);
		case 3:
			var op = query.update;
			return this.update(op);
		case 4:
			var op = query.$delete;
			return this.delete(op);
		case 5:
			var op = query.call;
			return this.call(op);
		case 6:
			var table = query.table;
			var ifNotExists = query.ifNotExists;
			return this.createTable(table,ifNotExists);
		case 7:
			var table = query.table;
			return this.dropTable(table);
		case 8:
			var table = query.table;
			return this.truncateTable(table);
		case 12:
			var op = query.transaction;
			return tink_sql_format_Statement.fromString(this.transaction(op));
		default:
			throw haxe_Exception.thrown("Query not supported in currrent formatter: " + Std.string(query));
		}
	}
	,isNested: function(query) {
		switch(query._hx_index) {
		case 0:
			var op = query.union;
			return this.isNested(op.left);
		case 1:
			var _g = query.select;
			var _g1 = _g.from;
			var _g2 = _g.groupBy;
			var _g2 = _g.having;
			var _g2 = _g.limit;
			var _g2 = _g.orderBy;
			var _g2 = _g.where;
			if(_g1._hx_index == 1) {
				var _g2 = _g1.left;
				var _g2 = _g1.right;
				var _g2 = _g1.type;
				var _g2 = _g1.c;
				if(_g.selection == null) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
			break;
		default:
			return false;
		}
	}
	,autoIncrement: function(increment) {
		if(increment) {
			return [tink_sql_format__$Statement_StatementMember.Sql("AUTO_INCREMENT")];
		} else {
			return [];
		}
	}
	,type: function(type) {
		switch(type._hx_index) {
		case 0:
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("TINYINT")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 1:
			var _g = type.signed;
			var _g1 = type.autoIncrement;
			var _g1 = type.byDefault;
			switch(type.size._hx_index) {
			case 0:
				var signed = _g;
				var d = _g1;
				var this1 = [tink_sql_format__$Statement_StatementMember.Sql("TINYINT")];
				var addition = tink_sql_format_Statement.fromString("UNSIGNED");
				var condition = !signed;
				if(condition == null) {
					condition = true;
				}
				var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
				var defaultValue = d;
				var addition;
				if(defaultValue == null) {
					addition = [];
				} else {
					var v = defaultValue;
					addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
				}
				if(addition.length > 0) {
					return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
				} else {
					return this2;
				}
				break;
			case 1:
				var signed = _g;
				var d = _g1;
				var this1 = [tink_sql_format__$Statement_StatementMember.Sql("SMALLINT")];
				var addition = tink_sql_format_Statement.fromString("UNSIGNED");
				var condition = !signed;
				if(condition == null) {
					condition = true;
				}
				var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
				var defaultValue = d;
				var addition;
				if(defaultValue == null) {
					addition = [];
				} else {
					var v = defaultValue;
					addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
				}
				if(addition.length > 0) {
					return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
				} else {
					return this2;
				}
				break;
			case 2:
				var signed = _g;
				var d = _g1;
				var this1 = [tink_sql_format__$Statement_StatementMember.Sql("MEDIUMINT")];
				var addition = tink_sql_format_Statement.fromString("UNSIGNED");
				var condition = !signed;
				if(condition == null) {
					condition = true;
				}
				var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
				var defaultValue = d;
				var addition;
				if(defaultValue == null) {
					addition = [];
				} else {
					var v = defaultValue;
					addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
				}
				if(addition.length > 0) {
					return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
				} else {
					return this2;
				}
				break;
			case 3:
				var signed = _g;
				var d = _g1;
				var this1 = [tink_sql_format__$Statement_StatementMember.Sql("INT")];
				var addition = tink_sql_format_Statement.fromString("UNSIGNED");
				var condition = !signed;
				if(condition == null) {
					condition = true;
				}
				var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
				var defaultValue = d;
				var addition;
				if(defaultValue == null) {
					addition = [];
				} else {
					var v = defaultValue;
					addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
				}
				if(addition.length > 0) {
					return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
				} else {
					return this2;
				}
				break;
			case 4:
				var signed = _g;
				var d = _g1;
				var this1 = [tink_sql_format__$Statement_StatementMember.Sql("BIGINT")];
				var addition = tink_sql_format_Statement.fromString("UNSIGNED");
				var condition = !signed;
				if(condition == null) {
					condition = true;
				}
				var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
				var defaultValue = d;
				var addition;
				if(defaultValue == null) {
					addition = [];
				} else {
					var v = defaultValue;
					addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
				}
				if(addition.length > 0) {
					return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
				} else {
					return this2;
				}
				break;
			}
			break;
		case 2:
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("DOUBLE")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 3:
			var maxLength = type.maxLength;
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql(maxLength < 65536 ? "VARCHAR(" + maxLength + ")" : "TEXT")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 5:
			return [tink_sql_format__$Statement_StatementMember.Sql("JSON")];
		case 6:
			var maxLength = type.maxLength;
			if(maxLength < 65536) {
				return tink_sql_format_Statement.fromString("VARBINARY(" + maxLength + ")");
			} else {
				return tink_sql_format_Statement.fromString("BLOB");
			}
			break;
		case 7:
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("DATETIME")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 8:
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("DATETIME")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 9:
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("TIMESTAMP")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 16:
			var type1 = type.type;
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql(type1)];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		default:
			throw haxe_Exception.thrown("Type not supported in current formatter: " + Std.string(type));
		}
	}
	,defineColumn: function(column) {
		var this1 = [tink_sql_format__$Statement_StatementMember.Ident(column.name)];
		var addition = this.type(column.type);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = tink_sql_format_Statement.fromString(column.nullable ? "NULL" : "NOT NULL");
		var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var _g = column.type;
		var addition;
		if(_g._hx_index == 1) {
			var _g1 = _g.size;
			var _g1 = _g.signed;
			var _g1 = _g.byDefault;
			addition = _g.autoIncrement == true;
		} else {
			addition = false;
		}
		var addition1 = this.autoIncrement(addition);
		if(addition1.length > 0) {
			return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition1);
		} else {
			return this1;
		}
	}
	,keyFields: function(key) {
		switch(key._hx_index) {
		case 0:
			var fields = key.fields;
			return fields;
		case 1:
			var _g = key.name;
			var fields = key.fields;
			return fields;
		case 2:
			var _g = key.name;
			var fields = key.fields;
			return fields;
		}
	}
	,keyType: function(key) {
		switch(key._hx_index) {
		case 0:
			var _g = key.fields;
			return [tink_sql_format__$Statement_StatementMember.Sql("PRIMARY KEY")];
		case 1:
			var _g = key.fields;
			var name = key.name;
			return [tink_sql_format__$Statement_StatementMember.Sql("UNIQUE KEY")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		case 2:
			var _g = key.fields;
			var name = key.name;
			return [tink_sql_format__$Statement_StatementMember.Sql("INDEX")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		}
	}
	,defineKey: function(key) {
		var this1 = this.keyType(key);
		var _this = this.keyFields(key);
		var f = tink_sql_format_StatementFactory.ident;
		var result = new Array(_this.length);
		var _g = 0;
		var _g1 = _this.length;
		while(_g < _g1) {
			var i = _g++;
			result[i] = f(_this[i]);
		}
		var stmnt = tink_sql_format_Statement.separated([],result);
		return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]).concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
	}
	,createTable: function(table,ifNotExists) {
		var this1 = [tink_sql_format__$Statement_StatementMember.Sql("CREATE TABLE")];
		var addition = tink_sql_format_Statement.fromString("IF NOT EXISTS");
		var condition = ifNotExists;
		if(condition == null) {
			condition = true;
		}
		var this2 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var name = table.getName();
		var this1 = this2.concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		var f = $bind(this,this.defineColumn);
		var _g = [];
		var x = $getIterator(table.getColumns());
		while(x.hasNext()) {
			var x1 = x.next();
			_g.push(f(x1));
		}
		var input = _g;
		var f = $bind(this,this.defineKey);
		var _g = [];
		var x = $getIterator(table.getKeys());
		while(x.hasNext()) {
			var x1 = x.next();
			_g.push(f(x1));
		}
		var stmnt = tink_sql_format_Statement.separated([],input.concat(_g));
		return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]).concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
	}
	,dropTable: function(table) {
		var name = table.getName();
		return [tink_sql_format__$Statement_StatementMember.Sql("DROP TABLE")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
	}
	,truncateTable: function(table) {
		var name = table.getName();
		return [tink_sql_format__$Statement_StatementMember.Sql("TRUNCATE TABLE")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
	}
	,insertRow: function(columns,row) {
		var _g = [];
		var x = $getIterator(columns);
		while(x.hasNext()) {
			var x1 = x.next();
			var _g1 = row[x1.name];
			var _g2 = x1.type;
			var tmp;
			if(_g1 == null) {
				switch(_g2._hx_index) {
				case 5:
					tmp = Object.prototype.hasOwnProperty.call(row,x1.name) ? [tink_sql_format__$Statement_StatementMember.Value("null")] : [tink_sql_format__$Statement_StatementMember.Value(null)];
					break;
				case 10:case 11:case 12:case 13:case 14:case 15:
					tmp = [tink_sql_format__$Statement_StatementMember.Value(null)];
					break;
				default:
					tmp = [tink_sql_format__$Statement_StatementMember.Value(null)];
				}
			} else {
				switch(_g2._hx_index) {
				case 5:
					var v = _g1;
					tmp = [tink_sql_format__$Statement_StatementMember.Value(JSON.stringify(v))];
					break;
				case 10:
					var v1 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_Point.toWkt(v1) + "',4326)");
					break;
				case 11:
					var v2 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_LineString.toWkt(v2) + "',4326)");
					break;
				case 12:
					var v3 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_Polygon.toWkt(v3) + "',4326)");
					break;
				case 13:
					var v4 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_MultiPoint.toWkt(v4) + "',4326)");
					break;
				case 14:
					var v5 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_MultiLineString.toWkt(v5) + "',4326)");
					break;
				case 15:
					var v6 = _g1;
					tmp = tink_sql_format_Statement.fromString("ST_GeomFromText('" + tink_s2d_MultiPolygon.toWkt(v6) + "',4326)");
					break;
				default:
					var v7 = _g1;
					tmp = [tink_sql_format__$Statement_StatementMember.Value(v7)];
				}
			}
			_g.push(tmp);
		}
		var stmnt = tink_sql_format_Statement.separated([],_g);
		return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
	}
	,insertInto: function(insert) {
		return [tink_sql_format__$Statement_StatementMember.Sql("INSERT INTO")];
	}
	,insert: function(insert) {
		var this1 = this.insertInto(insert);
		var name = insert.table.getName();
		var q = this1.concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		var _g = insert.data;
		switch(_g._hx_index) {
		case 0:
			var rows = _g.data;
			var writableColumns = Lambda.filter(insert.table.getColumns(),function(c) {
				return c.writable;
			});
			var result = new Array(writableColumns.length);
			var _g1 = 0;
			var _g2 = writableColumns.length;
			while(_g1 < _g2) {
				var i = _g1++;
				result[i] = writableColumns[i].name;
			}
			var _this = result;
			var f = tink_sql_format_StatementFactory.ident;
			var result = new Array(_this.length);
			var _g1 = 0;
			var _g2 = _this.length;
			while(_g1 < _g2) {
				var i = _g1++;
				result[i] = f(_this[i]);
			}
			var stmnt = tink_sql_format_Statement.separated([],result);
			var this1 = tink_sql_format_Statement.concat(q.concat([tink_sql_format_Statement.WHITESPACE]).concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
			var addition = tink_sql_format_Statement.fromString("VALUES");
			var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
			var _g1 = $bind(this,this.insertRow);
			var columns = writableColumns;
			var f = function(row) {
				return _g1(columns,row);
			};
			var result = new Array(rows.length);
			var _g2 = 0;
			var _g3 = rows.length;
			while(_g2 < _g3) {
				var i = _g2++;
				result[i] = f(rows[i]);
			}
			var addition = tink_sql_format_Statement.separated([],result);
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this2;
			}
			break;
		case 1:
			var op = _g.op;
			var columns1;
			var _g = op.from;
			var _g2 = op.selection;
			switch(_g._hx_index) {
			case 0:
				if(_g2 == null) {
					var table = _g.table;
					columns1 = table.columnNames();
				} else {
					var fields = _g2;
					if(fields != null) {
						columns1 = Reflect.fields(fields);
					} else {
						throw haxe_Exception.thrown("Can't get field information for the select: " + Std.string(op));
					}
				}
				break;
			case 2:
				var _g3 = _g.alias;
				var _g3 = _g.query;
				if(_g3._hx_index == 1) {
					var _g = _g3.select;
					var _g3 = _g.from;
					var _g3 = _g.groupBy;
					var _g3 = _g.having;
					var _g3 = _g.limit;
					var _g3 = _g.orderBy;
					var _g3 = _g.where;
					if(_g2 == null) {
						var selection = _g.selection;
						columns1 = Reflect.fields(selection);
					} else {
						var fields = _g2;
						if(fields != null) {
							columns1 = Reflect.fields(fields);
						} else {
							throw haxe_Exception.thrown("Can't get field information for the select: " + Std.string(op));
						}
					}
				} else {
					var fields = _g2;
					if(fields != null) {
						columns1 = Reflect.fields(fields);
					} else {
						throw haxe_Exception.thrown("Can't get field information for the select: " + Std.string(op));
					}
				}
				break;
			default:
				var fields = _g2;
				if(fields != null) {
					columns1 = Reflect.fields(fields);
				} else {
					throw haxe_Exception.thrown("Can't get field information for the select: " + Std.string(op));
				}
			}
			var _g = [];
			var c = $getIterator(columns1);
			while(c.hasNext()) {
				var c1 = c.next();
				_g.push([tink_sql_format__$Statement_StatementMember.Ident(c1)]);
			}
			var stmnt = tink_sql_format_Statement.separated([],_g);
			var this1 = tink_sql_format_Statement.concat(q.concat([tink_sql_format_Statement.WHITESPACE]).concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
			var addition = this.select(op);
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		}
	}
	,field: function(name,value) {
		var this1 = this.expr(value);
		var addition = tink_sql_format_Statement.fromString("AS");
		return (addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1).concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
	}
	,prefixFields: function(target) {
		var _gthis = this;
		switch(target._hx_index) {
		case 0:
			var table = target.table;
			var alias = table.getAlias();
			var from = alias == null ? table.getName() : alias;
			var _g = [];
			var x = $getIterator(table.columnNames());
			while(x.hasNext()) {
				var x1 = x.next();
				_g.push(_gthis.field(from + "@@@" + x1,tink_sql_ExprData.EField(from,x1,null)));
			}
			return tink_sql_format_Statement.separated([],_g);
		case 1:
			var left = target.left;
			var right = target.right;
			var type = target.type;
			var c = target.c;
			return tink_sql_format_Statement.separated([],[this.prefixFields(left),this.prefixFields(right)]);
		case 2:
			var _g = target.query;
			if(_g._hx_index == 1) {
				var _g1 = _g.select;
				var _g = _g1.from;
				var _g = _g1.groupBy;
				var _g = _g1.having;
				var _g = _g1.limit;
				var _g = _g1.orderBy;
				var _g = _g1.where;
				var selection = _g1.selection;
				var alias = target.alias;
				var _this = Reflect.fields(selection);
				var result = new Array(_this.length);
				var _g = 0;
				var _g1 = _this.length;
				while(_g < _g1) {
					var i = _g++;
					var name = _this[i];
					result[i] = _gthis.field(alias + "@@@" + name,tink_sql_ExprData.EField(alias,name,null));
				}
				return tink_sql_format_Statement.separated([],result);
			} else {
				throw haxe_Exception.thrown("Can't get field information for target: " + Std.string(target));
			}
			break;
		}
	}
	,selection: function(target,selection) {
		var _gthis = this;
		if(target._hx_index == 0) {
			var _g = target.table;
			if(selection == null) {
				return [tink_sql_format__$Statement_StatementMember.Sql("*")];
			} else {
				var fields = selection;
				var _this = Reflect.fields(fields);
				var result = new Array(_this.length);
				var _g = 0;
				var _g1 = _this.length;
				while(_g < _g1) {
					var i = _g++;
					var name = _this[i];
					result[i] = _gthis.field(name,fields[name]);
				}
				return tink_sql_format_Statement.separated([],result);
			}
		} else if(selection == null) {
			return this.prefixFields(target);
		} else {
			var fields = selection;
			var _this = Reflect.fields(fields);
			var result = new Array(_this.length);
			var _g = 0;
			var _g1 = _this.length;
			while(_g < _g1) {
				var i = _g++;
				var name = _this[i];
				result[i] = _gthis.field(name,fields[name]);
			}
			return tink_sql_format_Statement.separated([],result);
		}
	}
	,table: function(info) {
		var name = info.getName();
		var alias = info.getAlias();
		var this1 = [tink_sql_format__$Statement_StatementMember.Ident(name)];
		var addition = [tink_sql_format__$Statement_StatementMember.Sql("AS")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(alias)]);
		var condition = alias != null && alias != name;
		if(condition == null) {
			condition = true;
		}
		if(condition && addition.length > 0) {
			return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this1;
		}
	}
	,target: function(from) {
		switch(from._hx_index) {
		case 0:
			var info = from.table;
			return this.table(info);
		case 1:
			var left = from.left;
			var right = from.right;
			var type = from.type;
			var cond = from.c;
			var this1 = this.target(left);
			var addition;
			if(type == null) {
				addition = tink_sql_format_Statement.fromString("INNER");
			} else {
				switch(type) {
				case "left":
					addition = tink_sql_format_Statement.fromString("LEFT");
					break;
				case "right":
					addition = tink_sql_format_Statement.fromString("RIGHT");
					break;
				}
			}
			var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
			var addition = tink_sql_format_Statement.fromString("JOIN");
			var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
			var addition = this.target(right);
			var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
			var addition = tink_sql_format_Statement.fromString("ON");
			var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
			var addition = this.expr(cond);
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
			break;
		case 2:
			var alias = from.alias;
			var query = from.query;
			var stmnt = this.format(query);
			var this1 = tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
			var addition = tink_sql_format_Statement.fromString("AS");
			return (addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1).concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(alias)]);
		}
	}
	,groupBy: function(grouped) {
		var _gthis = this;
		if(grouped == null) {
			return [];
		} else {
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("GROUP BY")];
			var result = new Array(grouped.length);
			var _g = 0;
			var _g1 = grouped.length;
			while(_g < _g1) {
				var i = _g++;
				result[i] = _gthis.expr(grouped[i]);
			}
			return tink_sql_format_Statement.separated(this1.concat([tink_sql_format_Statement.WHITESPACE]),result);
		}
	}
	,orderBy: function(orderBy) {
		var _gthis = this;
		if(orderBy == null) {
			return [];
		} else {
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("ORDER BY")];
			var result = new Array(orderBy.length);
			var _g = 0;
			var _g1 = orderBy.length;
			while(_g < _g1) {
				var i = _g++;
				var by = orderBy[i];
				var this2 = _gthis.expr(by.field);
				var e = by.order;
				var addition = tink_sql_format_Statement.fromString($hxEnums[e.__enum__].__constructs__[e._hx_index]._hx_name.toUpperCase());
				result[i] = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
			}
			return tink_sql_format_Statement.separated(this1.concat([tink_sql_format_Statement.WHITESPACE]),result);
		}
	}
	,limit: function(limit) {
		if(limit == null || limit.limit == null) {
			return [];
		} else {
			var value = limit.limit;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("LIMIT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(value)]);
			var value = limit.offset;
			var addition = [tink_sql_format__$Statement_StatementMember.Sql("OFFSET")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(value)]);
			var condition = limit.offset != null && limit.offset != 0;
			if(condition == null) {
				condition = true;
			}
			if(condition && addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
		}
	}
	,where: function(condition,printTableName) {
		if(printTableName == null) {
			printTableName = true;
		}
		if(condition == null) {
			return [];
		} else {
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("WHERE")];
			var addition = this.expr(condition,printTableName);
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
		}
	}
	,having: function(condition) {
		if(condition == null) {
			return [];
		} else {
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("HAVING")];
			var addition = this.expr(condition);
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
		}
	}
	,select: function(select) {
		var this1 = [tink_sql_format__$Statement_StatementMember.Sql("SELECT")];
		var addition = this.selection(select.from,select.selection);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = tink_sql_format_Statement.fromString("FROM");
		var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var addition = this.target(select.from);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.where(select.where);
		var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var addition = this.groupBy(select.groupBy);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.having(select.having);
		var this1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var addition = this.orderBy(select.orderBy);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.limit(select.limit);
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this2;
		}
	}
	,union: function(union) {
		var stmnt = this.format(union.left);
		var this1 = tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
		var addition = tink_sql_format_Statement.fromString("UNION");
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = tink_sql_format_Statement.fromString("ALL");
		var condition = !union.distinct;
		if(condition == null) {
			condition = true;
		}
		var this1 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var stmnt = this.format(union.right);
		var this2 = tink_sql_format_Statement.concat(this1.concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
		var addition = this.limit(union.limit);
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this2;
		}
	}
	,update: function(update) {
		var _gthis = this;
		var name = update.table.getName();
		var this1 = [tink_sql_format__$Statement_StatementMember.Sql("UPDATE")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		var addition = tink_sql_format_Statement.fromString("SET ");
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var _this = update.set;
		var result = new Array(_this.length);
		var _g = 0;
		var _g1 = _this.length;
		while(_g < _g1) {
			var i = _g++;
			var set = _this[i];
			var this1 = [tink_sql_format__$Statement_StatementMember.Ident(tink_sql_expr_Field.get_name(set.field))];
			var addition = tink_sql_format_Statement.fromString("=");
			var this3 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
			var addition1 = _gthis.expr(set.expr,false);
			result[i] = addition1.length > 0 ? tink_sql_format_Statement.concat(this3.concat([tink_sql_format_Statement.WHITESPACE]),addition1) : this3;
		}
		var this1 = tink_sql_format_Statement.separated(this2,result);
		var addition = this.where(update.where,false);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.limit(tink_sql_Limit.ofInt(update.max));
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this2;
		}
	}
	,'delete': function(del) {
		var name = del.from.getName();
		var this1 = [tink_sql_format__$Statement_StatementMember.Sql("DELETE FROM")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
		var addition = this.where(del.where,false);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.limit(tink_sql_Limit.ofInt(del.max));
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this2;
		}
	}
	,call: function(op) {
		throw haxe_Exception.thrown("implement");
	}
	,transaction: function(transaction) {
		switch(transaction._hx_index) {
		case 0:
			return this.beginTransaction();
		case 1:
			return "COMMIT";
		case 2:
			return "ROLLBACK";
		}
	}
	,beginTransaction: function() {
		return "START TRANSACTION";
	}
	,binOp: function(o) {
		switch(o._hx_index) {
		case 0:
			return tink_sql_format_Statement.fromString("+");
		case 1:
			return tink_sql_format_Statement.fromString("-");
		case 2:
			return tink_sql_format_Statement.fromString("*");
		case 3:
			return tink_sql_format_Statement.fromString("MOD");
		case 4:
			return tink_sql_format_Statement.fromString("/");
		case 5:
			return tink_sql_format_Statement.fromString(">");
		case 6:
			return tink_sql_format_Statement.fromString(">=");
		case 7:
			return tink_sql_format_Statement.fromString("<");
		case 8:
			return tink_sql_format_Statement.fromString("<=");
		case 9:
			return tink_sql_format_Statement.fromString("=");
		case 10:
			return tink_sql_format_Statement.fromString("AND");
		case 11:
			return tink_sql_format_Statement.fromString("OR");
		case 12:
			return tink_sql_format_Statement.fromString("LIKE");
		case 13:
			return tink_sql_format_Statement.fromString("IN");
		}
	}
	,unOp: function(o) {
		switch(o._hx_index) {
		case 0:
			return tink_sql_format_Statement.fromString("NOT");
		case 1:
			return tink_sql_format_Statement.fromString("IS NULL");
		case 2:
			return tink_sql_format_Statement.fromString("-");
		}
	}
	,returning: function() {
		return tink_sql_format_Statement.fromString("RETURNING");
	}
	,expr: function(e,printTableName) {
		if(printTableName == null) {
			printTableName = true;
		}
		var _gthis = this;
		if(e == null) {
			return tink_sql_format_Statement.fromString("NULL");
		} else {
			switch(e._hx_index) {
			case 0:
				var _g = e.op;
				var _g1 = e.a;
				if(e.postfix) {
					var a = _g1;
					var op = _g;
					var this1 = this.expr(a);
					var addition = this.unOp(op);
					if(addition.length > 0) {
						return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
					} else {
						return this1;
					}
				} else {
					var a = _g1;
					var op = _g;
					var this1 = this.unOp(op);
					var addition = this.expr(a,printTableName);
					if(addition.length > 0) {
						return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
					} else {
						return this1;
					}
				}
				break;
			case 1:
				var _g = e.op;
				var _g1 = e.a;
				var _g2 = e.b;
				if(_g._hx_index == 13) {
					var a = _g1;
					var b = _g2;
					var e1 = b;
					var tmp;
					if(e1._hx_index == 4) {
						var _g3 = e1.type;
						if(e1.value.length == 0) {
							if(_g3._hx_index == 6) {
								var _g4 = _g3.type;
								tmp = true;
							} else {
								tmp = false;
							}
						} else {
							tmp = false;
						}
					} else {
						tmp = false;
					}
					if(tmp) {
						return [tink_sql_format__$Statement_StatementMember.Value(false)];
					} else {
						var op = _g;
						var a = _g1;
						var b = _g2;
						var this1 = this.expr(a,printTableName);
						var addition = this.binOp(op);
						var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
						var addition = this.expr(b,printTableName);
						var stmnt = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
						return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
					}
				} else {
					var op = _g;
					var a = _g1;
					var b = _g2;
					var this1 = this.expr(a,printTableName);
					var addition = this.binOp(op);
					var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
					var addition = this.expr(b,printTableName);
					var stmnt = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
					return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
				}
				break;
			case 2:
				var _g = e.type;
				var table = e.table;
				var name = e.name;
				return (!printTableName || table == null ? [] : [tink_sql_format__$Statement_StatementMember.Ident(table)].concat(tink_sql_format_Statement.fromString("."))).concat([tink_sql_format__$Statement_StatementMember.Ident(name)]);
			case 3:
				var _g = e.name;
				var _g1 = e.args;
				var _g2 = e.parenthesis;
				if(_g == "JSON_VALUE") {
					if(_g1.length == 2) {
						var jsonDoc = _g1[0];
						var path = _g1[1];
						var returnType = e.type;
						var params = this.expr(jsonDoc,printTableName);
						var params1;
						switch(returnType._hx_index) {
						case 0:
							params1 = this.expr(path,printTableName);
							break;
						case 2:case 4:
							var this1 = this.expr(path,printTableName);
							var addition = this.returning();
							var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
							var addition = [tink_sql_format__$Statement_StatementMember.Sql("SIGNED")];
							params1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
							break;
						case 3:
							var this1 = this.expr(path,printTableName);
							var addition = this.returning();
							var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
							var addition = [tink_sql_format__$Statement_StatementMember.Sql("DOUBLE")];
							params1 = addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
							break;
						default:
							throw haxe_Exception.thrown("not implemented");
						}
						var params2 = [params,params1];
						var stmnt = tink_sql_format_Statement.separated([],params2);
						return tink_sql_format_Statement.concat([tink_sql_format__$Statement_StatementMember.Sql("JSON_VALUE")].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
					} else {
						var name = _g;
						var args = _g1;
						var wrap = _g2;
						var result = new Array(args.length);
						var _g3 = 0;
						var _g4 = args.length;
						while(_g3 < _g4) {
							var i = _g3++;
							result[i] = _gthis.expr(args[i],printTableName);
						}
						var params = result;
						if(wrap == null || wrap) {
							var stmnt = tink_sql_format_Statement.separated([],params);
							return tink_sql_format_Statement.concat([tink_sql_format__$Statement_StatementMember.Sql(name)].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						} else {
							return tink_sql_format_Statement.separated([tink_sql_format__$Statement_StatementMember.Sql(name)],params);
						}
					}
				} else {
					var name = _g;
					var args = _g1;
					var wrap = _g2;
					var result = new Array(args.length);
					var _g = 0;
					var _g1 = args.length;
					while(_g < _g1) {
						var i = _g++;
						result[i] = _gthis.expr(args[i],printTableName);
					}
					var params = result;
					if(wrap == null || wrap) {
						var stmnt = tink_sql_format_Statement.separated([],params);
						return tink_sql_format_Statement.concat([tink_sql_format__$Statement_StatementMember.Sql(name)].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
					} else {
						return tink_sql_format_Statement.separated([tink_sql_format__$Statement_StatementMember.Sql(name)],params);
					}
				}
				break;
			case 4:
				var _g = e.value;
				var _g1 = e.type;
				if(_g == null) {
					return tink_sql_format_Statement.fromString("NULL");
				} else {
					switch(_g1._hx_index) {
					case 0:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					case 2:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					case 3:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					case 4:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					case 5:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					case 6:
						switch(_g1.type._hx_index) {
						case 0:
							var v = _g;
							var f = tink_sql_format_StatementFactory.value;
							var result = new Array(v.length);
							var _g1 = 0;
							var _g2 = v.length;
							while(_g1 < _g2) {
								var i = _g1++;
								result[i] = f(v[i]);
							}
							var stmnt = tink_sql_format_Statement.separated([],result);
							return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						case 2:
							var v = _g;
							var f = tink_sql_format_StatementFactory.value;
							var result = new Array(v.length);
							var _g1 = 0;
							var _g2 = v.length;
							while(_g1 < _g2) {
								var i = _g1++;
								result[i] = f(v[i]);
							}
							var stmnt = tink_sql_format_Statement.separated([],result);
							return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						case 3:
							var v = _g;
							var f = tink_sql_format_StatementFactory.value;
							var result = new Array(v.length);
							var _g1 = 0;
							var _g2 = v.length;
							while(_g1 < _g2) {
								var i = _g1++;
								result[i] = f(v[i]);
							}
							var stmnt = tink_sql_format_Statement.separated([],result);
							return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						case 4:
							var v = _g;
							var f = tink_sql_format_StatementFactory.value;
							var result = new Array(v.length);
							var _g1 = 0;
							var _g2 = v.length;
							while(_g1 < _g2) {
								var i = _g1++;
								result[i] = f(v[i]);
							}
							var stmnt = tink_sql_format_Statement.separated([],result);
							return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						case 8:
							var v = _g;
							var f = tink_sql_format_StatementFactory.value;
							var result = new Array(v.length);
							var _g1 = 0;
							var _g2 = v.length;
							while(_g1 < _g2) {
								var i = _g1++;
								result[i] = f(v[i]);
							}
							var stmnt = tink_sql_format_Statement.separated([],result);
							return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
						default:
							throw haxe_Exception.thrown("Only arrays of primitive types are supported");
						}
						break;
					case 7:
						var bytes = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(bytes)];
					case 8:
						var v = _g;
						return [tink_sql_format__$Statement_StatementMember.Value(v)];
					default:
						throw haxe_Exception.thrown("Expression not supported in current formatter: " + Std.string(e));
					}
				}
				break;
			case 6:
				var _g = e.type;
				var query = e.query;
				var stmnt = this.format(query);
				return tink_sql_format_Statement.concat([].concat(tink_sql_format_Statement.fromString("(")),stmnt).concat(tink_sql_format_Statement.fromString(")"));
			default:
				throw haxe_Exception.thrown("Expression not supported in current formatter: " + Std.string(e));
			}
		}
	}
	,__class__: tink_sql_format_SqlFormatter
};
var tink_sql_format_SqliteFormatter = function() {
	tink_sql_format_SqlFormatter.call(this);
};
tink_sql_format_SqliteFormatter.__name__ = "tink.sql.format.SqliteFormatter";
tink_sql_format_SqliteFormatter.__super__ = tink_sql_format_SqlFormatter;
tink_sql_format_SqliteFormatter.prototype = $extend(tink_sql_format_SqlFormatter.prototype,{
	format: function(query) {
		return tink_sql_format_SqlFormatter.prototype.format.call(this,query);
	}
	,defineColumn: function(column) {
		var _g = column.type;
		var autoIncrement;
		if(_g._hx_index == 1) {
			var _g1 = _g.size;
			var _g1 = _g.signed;
			var _g1 = _g.byDefault;
			autoIncrement = _g.autoIncrement == true;
		} else {
			autoIncrement = false;
		}
		var this1 = [tink_sql_format__$Statement_StatementMember.Ident(column.name)];
		var addition;
		if(autoIncrement) {
			addition = tink_sql_format_Statement.fromString("INTEGER");
		} else {
			var this2 = this.type(column.type);
			var addition1 = tink_sql_format_Statement.fromString(column.nullable ? "NULL" : "NOT NULL");
			addition = addition1.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition1) : this2;
		}
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this1;
		}
	}
	,type: function(type) {
		if(type._hx_index == 4) {
			var size = type.size;
			var d = type.byDefault;
			var this1 = [tink_sql_format__$Statement_StatementMember.Sql("TEXT")];
			var defaultValue = d;
			var addition;
			if(defaultValue == null) {
				addition = [];
			} else {
				var v = defaultValue;
				addition = [tink_sql_format__$Statement_StatementMember.Sql("DEFAULT")].concat([tink_sql_format_Statement.WHITESPACE]).concat([tink_sql_format__$Statement_StatementMember.Value(defaultValue)]);
			}
			if(addition.length > 0) {
				return tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition);
			} else {
				return this1;
			}
		} else {
			return tink_sql_format_SqlFormatter.prototype.type.call(this,type);
		}
	}
	,union: function(union) {
		var this1 = this.format(union.left);
		var addition = tink_sql_format_Statement.fromString("UNION");
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = tink_sql_format_Statement.fromString("ALL");
		var condition = !union.distinct;
		if(condition == null) {
			condition = true;
		}
		var this1 = condition && addition.length > 0 ? tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this2;
		var addition = this.format(union.right);
		var this2 = addition.length > 0 ? tink_sql_format_Statement.concat(this1.concat([tink_sql_format_Statement.WHITESPACE]),addition) : this1;
		var addition = this.limit(union.limit);
		if(addition.length > 0) {
			return tink_sql_format_Statement.concat(this2.concat([tink_sql_format_Statement.WHITESPACE]),addition);
		} else {
			return this2;
		}
	}
	,beginTransaction: function() {
		return "BEGIN TRANSACTION";
	}
	,__class__: tink_sql_format_SqliteFormatter
});
var tink_sql_format__$Statement_StatementMember = $hxEnums["tink.sql.format._Statement.StatementMember"] = { __ename__:true,__constructs__:null
	,Sql: ($_=function(query) { return {_hx_index:0,query:query,__enum__:"tink.sql.format._Statement.StatementMember",toString:$estr}; },$_._hx_name="Sql",$_.__params__ = ["query"],$_)
	,Ident: ($_=function(name) { return {_hx_index:1,name:name,__enum__:"tink.sql.format._Statement.StatementMember",toString:$estr}; },$_._hx_name="Ident",$_.__params__ = ["name"],$_)
	,Value: ($_=function(value) { return {_hx_index:2,value:value,__enum__:"tink.sql.format._Statement.StatementMember",toString:$estr}; },$_._hx_name="Value",$_.__params__ = ["value"],$_)
};
tink_sql_format__$Statement_StatementMember.__constructs__ = [tink_sql_format__$Statement_StatementMember.Sql,tink_sql_format__$Statement_StatementMember.Ident,tink_sql_format__$Statement_StatementMember.Value];
var tink_sql_format_StatementFactory = function() { };
tink_sql_format_StatementFactory.__name__ = "tink.sql.format.StatementFactory";
tink_sql_format_StatementFactory.ident = function(name) {
	return [tink_sql_format__$Statement_StatementMember.Ident(name)];
};
tink_sql_format_StatementFactory.value = function(value) {
	return [tink_sql_format__$Statement_StatementMember.Value(value)];
};
var tink_sql_format_Statement = {};
tink_sql_format_Statement.separated = function(this1,input) {
	var res = this1.slice(0);
	var _g = 0;
	var _g1 = input.length;
	while(_g < _g1) {
		var i = _g++;
		if(i > 0) {
			res.push(tink_sql_format_Statement.SEPARATE);
		}
		res = res.concat(input[i]);
	}
	return res;
};
tink_sql_format_Statement.concat = function(this1,other) {
	return this1.concat(other);
};
tink_sql_format_Statement.fromString = function(query) {
	if(query == null) {
		return [];
	} else if(query == "") {
		return [];
	} else {
		var v = query;
		return [tink_sql_format__$Statement_StatementMember.Sql(query)];
	}
};
tink_sql_format_Statement.prepare = function(this1,ident) {
	var query_b = "";
	var values = [];
	var _g = 0;
	while(_g < this1.length) {
		var member = this1[_g];
		++_g;
		switch(member._hx_index) {
		case 0:
			var sql = member.query;
			query_b += sql == null ? "null" : "" + sql;
			break;
		case 1:
			var i = member.name;
			query_b += Std.string(ident(i));
			break;
		case 2:
			var v = member.value;
			query_b += "?";
			if(((v) instanceof haxe_io_Bytes)) {
				var b = v;
				var data = b.b;
				v = js_node_buffer_Buffer.from(data.buffer,data.byteOffset,b.length);
			}
			if(((v) instanceof haxe__$Int64__$_$_$Int64)) {
				v = haxe_Int64.toString(v);
			}
			values.push(v);
			break;
		}
	}
	return { query : query_b, values : values};
};
var tink_sql_parse_ResultParser = function() {
};
tink_sql_parse_ResultParser.__name__ = "tink.sql.parse.ResultParser";
tink_sql_parse_ResultParser.prototype = {
	parseGeometryValue: function(bytes) {
		var _g = tink_spatial_Parser.wkb(bytes.sub(4,bytes.length - 4));
		if(_g._hx_index == 0) {
			var _g1 = _g.v;
			switch(_g1._hx_index) {
			case 0:
				var v = _g1.v;
				return v;
			case 1:
				var v = _g1.v;
				return v;
			case 2:
				var v = _g1.v;
				return v;
			case 3:
				var v = _g1.v;
				return v;
			case 4:
				var v = _g1.v;
				return v;
			case 5:
				var v = _g1.v;
				return v;
			case 6:
				var v = _g1.v;
				return v;
			}
		} else {
			throw haxe_Exception.thrown("expected 2d geometries");
		}
	}
	,parseValue: function(value,type) {
		if(value == null) {
			return null;
		}
		if(type == null) {
			return value;
		} else {
			switch(type._hx_index) {
			case 0:
				return "" + Std.string(value);
			case 1:
				return JSON.parse(value);
			case 2:
				if(typeof(value) == "string") {
					return value == "1";
				} else if(typeof(value) == "number" && ((value | 0) === value)) {
					return value > 0;
				} else {
					return !(!value);
				}
				break;
			case 3:
				if(typeof(value) == "string") {
					return parseFloat(value);
				} else {
					return value;
				}
				break;
			case 4:
				if(typeof(value) == "string") {
					return Std.parseInt(value);
				} else {
					return value;
				}
				break;
			case 5:
				if(typeof(value) == "string") {
					return haxe_Int64Helper.parseString(value);
				} else {
					return value;
				}
				break;
			case 7:
				if(((value) instanceof js_node_buffer_Buffer)) {
					return js_node_buffer__$Buffer_Helper.bytesOfBuffer(value);
				} else if(typeof(value) == "string") {
					return haxe_io_Bytes.ofString(value);
				} else {
					return value;
				}
				break;
			case 8:
				if(typeof(value) == "string") {
					return HxOverrides.strDate(value);
				} else if(typeof(value) == "number") {
					return new Date(value);
				} else {
					return value;
				}
				break;
			case 9:
				var _g = type.type;
				if(typeof(value) == "string") {
					return this.parseGeometryValue(haxe_io_Bytes.ofString(value));
				} else if(((value) instanceof haxe_io_Bytes)) {
					return this.parseGeometryValue(value);
				} else {
					return value;
				}
				break;
			default:
				return value;
			}
		}
	}
	,queryParser: function(query,nest) {
		var _gthis = this;
		var types = tink_sql_expr_ExprTyper.typeQuery(query);
		return function(row) {
			var res = { };
			var nonNull_h = Object.create(null);
			var _g = 0;
			var _g1 = Reflect.fields(row);
			while(_g < _g1.length) {
				var field = _g1[_g];
				++_g;
				var value = _gthis.parseValue(row[field],types.h[field]);
				if(nest) {
					var parts = field.split("@@@");
					var table = parts[0];
					var name = parts[1];
					var target = !Object.prototype.hasOwnProperty.call(res,table) ? res[table] = { } : res[table];
					target[name] = value;
					if(value != null) {
						nonNull_h[table] = true;
					}
				} else {
					res[field] = value;
				}
			}
			if(nest) {
				var _g = 0;
				var _g1 = Reflect.fields(res);
				while(_g < _g1.length) {
					var table = _g1[_g];
					++_g;
					if(!Object.prototype.hasOwnProperty.call(nonNull_h,table)) {
						Reflect.deleteField(res,table);
					}
				}
			}
			return res;
		};
	}
	,__class__: tink_sql_parse_ResultParser
};
var tink_streams_StreamBase = function() {
};
tink_streams_StreamBase.__name__ = "tink.streams.StreamBase";
tink_streams_StreamBase.prototype = {
	forEach: function(handler) {
		throw haxe_Exception.thrown("not implemented");
	}
	,__class__: tink_streams_StreamBase
};
var tink_streams_RealStream = {};
tink_streams_RealStream.collect = function(this1) {
	var buf = [];
	return tink_core_Future.map(this1.forEach(tink_streams_Handler.ofSafe(function(x) {
		buf.push(x);
		return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_streams_Handled.Resume));
	})),function(c) {
		switch(c._hx_index) {
		case 0:
			var _g = c.rest;
			throw haxe_Exception.thrown("unreachable");
		case 2:
			var e = c.error;
			return tink_core_Outcome.Failure(e);
		case 3:
			return tink_core_Outcome.Success(buf);
		}
	});
};
var tink_streams_Stream = {};
tink_streams_Stream.dirty = function(this1) {
	return this1;
};
tink_streams_Stream.future = function(f) {
	return new tink_streams_FutureStream(f);
};
tink_streams_Stream.promise = function(f) {
	return tink_streams_Stream.future(tink_core_Future.map(f,function(o) {
		switch(o._hx_index) {
		case 0:
			var s = o.data;
			return tink_streams_Stream.dirty(s);
		case 1:
			var e = o.failure;
			return tink_streams_Stream.ofError(e);
		}
	}));
};
tink_streams_Stream.ofError = function(e) {
	return new tink_streams__$Stream_ErrorStream(e);
};
var tink_streams_Handled = $hxEnums["tink.streams.Handled"] = { __ename__:true,__constructs__:null
	,BackOff: {_hx_name:"BackOff",_hx_index:0,__enum__:"tink.streams.Handled",toString:$estr}
	,Finish: {_hx_name:"Finish",_hx_index:1,__enum__:"tink.streams.Handled",toString:$estr}
	,Resume: {_hx_name:"Resume",_hx_index:2,__enum__:"tink.streams.Handled",toString:$estr}
	,Clog: ($_=function(e) { return {_hx_index:3,e:e,__enum__:"tink.streams.Handled",toString:$estr}; },$_._hx_name="Clog",$_.__params__ = ["e"],$_)
};
tink_streams_Handled.__constructs__ = [tink_streams_Handled.BackOff,tink_streams_Handled.Finish,tink_streams_Handled.Resume,tink_streams_Handled.Clog];
var tink_streams_Conclusion = $hxEnums["tink.streams.Conclusion"] = { __ename__:true,__constructs__:null
	,Halted: ($_=function(rest) { return {_hx_index:0,rest:rest,__enum__:"tink.streams.Conclusion",toString:$estr}; },$_._hx_name="Halted",$_.__params__ = ["rest"],$_)
	,Clogged: ($_=function(error,at) { return {_hx_index:1,error:error,at:at,__enum__:"tink.streams.Conclusion",toString:$estr}; },$_._hx_name="Clogged",$_.__params__ = ["error","at"],$_)
	,Failed: ($_=function(error) { return {_hx_index:2,error:error,__enum__:"tink.streams.Conclusion",toString:$estr}; },$_._hx_name="Failed",$_.__params__ = ["error"],$_)
	,Depleted: {_hx_name:"Depleted",_hx_index:3,__enum__:"tink.streams.Conclusion",toString:$estr}
};
tink_streams_Conclusion.__constructs__ = [tink_streams_Conclusion.Halted,tink_streams_Conclusion.Clogged,tink_streams_Conclusion.Failed,tink_streams_Conclusion.Depleted];
var tink_streams__$Stream_ErrorStream = function(error) {
	tink_streams_StreamBase.call(this);
	this.error = error;
};
tink_streams__$Stream_ErrorStream.__name__ = "tink.streams._Stream.ErrorStream";
tink_streams__$Stream_ErrorStream.__super__ = tink_streams_StreamBase;
tink_streams__$Stream_ErrorStream.prototype = $extend(tink_streams_StreamBase.prototype,{
	forEach: function(handler) {
		return new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_streams_Conclusion.Failed(this.error)));
	}
	,__class__: tink_streams__$Stream_ErrorStream
});
var tink_streams_Handler = {};
tink_streams_Handler.ofSafe = function(f) {
	var this1 = f;
	return this1;
};
var tink_streams_FutureStream = function(f) {
	tink_streams_StreamBase.call(this);
	this.f = f;
};
tink_streams_FutureStream.__name__ = "tink.streams.FutureStream";
tink_streams_FutureStream.__super__ = tink_streams_StreamBase;
tink_streams_FutureStream.prototype = $extend(tink_streams_StreamBase.prototype,{
	forEach: function(handler) {
		var _gthis = this;
		return tink_core_Future.async(function(cb) {
			_gthis.f.handle(function(s) {
				s.forEach(handler).handle(cb);
			});
		});
	}
	,__class__: tink_streams_FutureStream
});
var tink_streams_Generator = function(upcoming) {
	tink_streams_StreamBase.call(this);
	this.upcoming = upcoming;
};
tink_streams_Generator.__name__ = "tink.streams.Generator";
tink_streams_Generator.stream = function(step) {
	return new tink_streams_Generator(tink_core_Future.async(step));
};
tink_streams_Generator.__super__ = tink_streams_StreamBase;
tink_streams_Generator.prototype = $extend(tink_streams_StreamBase.prototype,{
	forEach: function(handler) {
		var _gthis = this;
		return tink_core_Future.async(function(cb) {
			_gthis.upcoming.handle(function(e) {
				switch(e._hx_index) {
				case 0:
					var v = e.value;
					var then = e.next;
					handler(v).handle(function(s) {
						switch(s._hx_index) {
						case 0:
							cb(tink_streams_Conclusion.Halted(_gthis));
							break;
						case 1:
							cb(tink_streams_Conclusion.Halted(then));
							break;
						case 2:
							then.forEach(handler).handle(cb);
							break;
						case 3:
							var e = s.e;
							cb(tink_streams_Conclusion.Clogged(e,_gthis));
							break;
						}
					});
					break;
				case 1:
					var e1 = e.e;
					cb(tink_streams_Conclusion.Failed(e1));
					break;
				case 2:
					cb(tink_streams_Conclusion.Depleted);
					break;
				}
			});
		});
	}
	,__class__: tink_streams_Generator
});
var tink_streams_Step = $hxEnums["tink.streams.Step"] = { __ename__:true,__constructs__:null
	,Link: ($_=function(value,next) { return {_hx_index:0,value:value,next:next,__enum__:"tink.streams.Step",toString:$estr}; },$_._hx_name="Link",$_.__params__ = ["value","next"],$_)
	,Fail: ($_=function(e) { return {_hx_index:1,e:e,__enum__:"tink.streams.Step",toString:$estr}; },$_._hx_name="Fail",$_.__params__ = ["e"],$_)
	,End: {_hx_name:"End",_hx_index:2,__enum__:"tink.streams.Step",toString:$estr}
};
tink_streams_Step.__constructs__ = [tink_streams_Step.Link,tink_streams_Step.Fail,tink_streams_Step.End];
function $getIterator(o) { if( o instanceof Array ) return new haxe_iterators_ArrayIterator(o); else return o.iterator(); }
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $global.$haxeUID++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = m.bind(o); o.hx__closures__[m.__id__] = f; } return f; }
$global.$haxeUID |= 0;
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.prototype.__class__ = String;
String.__name__ = "String";
Array.__name__ = "Array";
Date.prototype.__class__ = Date;
Date.__name__ = "Date";
js_Boot.__toStr = ({ }).toString;
if(ArrayBuffer.prototype.slice == null) {
	ArrayBuffer.prototype.slice = js_lib__$ArrayBuffer_ArrayBufferCompat.sliceImpl;
}
haxe_Int32._mul = Math.imul != null ? Math.imul : function(a,b) {
	return a * (b & 65535) + (a * (b >>> 16) << 16 | 0) | 0;
};
haxe_io_FPHelper.helper = new DataView(new ArrayBuffer(8));
tink_core_Callback.depth = 0;
tink_core_Future.NEVER_INST = new tink_core__$Future_FutureObject();
tink_core_Promise.NOISE = new tink_core__$Future_SyncFuture(new tink_core__$Lazy_LazyConst(tink_core_Outcome.Success(null)));
tink_sql_Table0.COLUMNS = [{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "textValue", nullable : true, type : tink_sql_DataType.DText(tink_sql_TextSize.Medium,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true}];
tink_sql_Table0.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table0.INFO = new tink_sql_TableStaticInfo(tink_sql_Table0.COLUMNS,tink_sql_Table0.KEYS);
tink_sql_Table1.COLUMNS = [{ name : "descItem", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true}];
tink_sql_Table1.KEYS = [];
tink_sql_Table1.INFO = new tink_sql_TableStaticInfo(tink_sql_Table1.COLUMNS,tink_sql_Table1.KEYS);
tink_sql_Table2.COLUMNS = [{ name : "description", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "isHook", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "stateClient", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "stateMenu", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "stateServer", nullable : false, type : tink_sql_DataType.DBool(null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table2.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table2.INFO = new tink_sql_TableStaticInfo(tink_sql_Table2.COLUMNS,tink_sql_Table2.KEYS);
tink_sql_Table3.COLUMNS = [{ name : "argumentNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "def", nullable : true, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "description", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "funcid", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "typeURL", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true}];
tink_sql_Table3.KEYS = [];
tink_sql_Table3.INFO = new tink_sql_TableStaticInfo(tink_sql_Table3.COLUMNS,tink_sql_Table3.KEYS);
tink_sql_Table4.COLUMNS = [{ name : "desc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "funcid", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "returnNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "typeURL", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true}];
tink_sql_Table4.KEYS = [];
tink_sql_Table4.INFO = new tink_sql_TableStaticInfo(tink_sql_Table4.COLUMNS,tink_sql_Table4.KEYS);
tink_sql_Table5.COLUMNS = [{ name : "code", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "desc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "exampleNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "funcid", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "output", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true}];
tink_sql_Table5.KEYS = [];
tink_sql_Table5.INFO = new tink_sql_TableStaticInfo(tink_sql_Table5.COLUMNS,tink_sql_Table5.KEYS);
tink_sql_Table6.COLUMNS = [{ name : "description", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table6.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table6.INFO = new tink_sql_TableStaticInfo(tink_sql_Table6.COLUMNS,tink_sql_Table6.KEYS);
tink_sql_Table7.COLUMNS = [{ name : "def", nullable : true, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "structID", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "structOrder", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "type", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "typeURL", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table7.KEYS = [];
tink_sql_Table7.INFO = new tink_sql_TableStaticInfo(tink_sql_Table7.COLUMNS,tink_sql_Table7.KEYS);
tink_sql_Table8.COLUMNS = [{ name : "description", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table8.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table8.INFO = new tink_sql_TableStaticInfo(tink_sql_Table8.COLUMNS,tink_sql_Table8.KEYS);
tink_sql_Table9.COLUMNS = [{ name : "description", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "name", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table9.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table9.INFO = new tink_sql_TableStaticInfo(tink_sql_Table9.COLUMNS,tink_sql_Table9.KEYS);
tink_sql_Table10.COLUMNS = [{ name : "desc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "id", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,true,null), writable : true},{ name : "url", nullable : false, type : tink_sql_DataType.DString(1024,null), writable : true}];
tink_sql_Table10.KEYS = [tink_sql_Key.Primary(["id"])];
tink_sql_Table10.INFO = new tink_sql_TableStaticInfo(tink_sql_Table10.COLUMNS,tink_sql_Table10.KEYS);
tink_sql_Table11.COLUMNS = [{ name : "desc", nullable : true, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "enumID", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Default,false,false,null), writable : true},{ name : "enumName", nullable : false, type : tink_sql_DataType.DString(255,null), writable : true},{ name : "memberNo", nullable : false, type : tink_sql_DataType.DInt(tink_sql_IntSize.Small,true,false,null), writable : true},{ name : "value", nullable : true, type : tink_sql_DataType.DString(255,null), writable : true}];
tink_sql_Table11.KEYS = [];
tink_sql_Table11.INFO = new tink_sql_TableStaticInfo(tink_sql_Table11.COLUMNS,tink_sql_Table11.KEYS);
tink_sql_Transaction0.INFO = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	{
		var value = tink_sql_Table0.makeInfo("DescItem",null);
		_g.h["DescItem"] = value;
	}
	{
		var value = tink_sql_Table1.makeInfo("DescriptionStorage",null);
		_g.h["DescriptionStorage"] = value;
	}
	{
		var value = tink_sql_Table2.makeInfo("Function",null);
		_g.h["Function"] = value;
	}
	{
		var value = tink_sql_Table3.makeInfo("FunctionArg",null);
		_g.h["FunctionArg"] = value;
	}
	{
		var value = tink_sql_Table4.makeInfo("FunctionRet",null);
		_g.h["FunctionRet"] = value;
	}
	{
		var value = tink_sql_Table5.makeInfo("LuaExample",null);
		_g.h["LuaExample"] = value;
	}
	{
		var value = tink_sql_Table6.makeInfo("Struct",null);
		_g.h["Struct"] = value;
	}
	{
		var value = tink_sql_Table7.makeInfo("StructMember",null);
		_g.h["StructMember"] = value;
	}
	{
		var value = tink_sql_Table8.makeInfo("GClass",null);
		_g.h["GClass"] = value;
	}
	{
		var value = tink_sql_Table9.makeInfo("Library",null);
		_g.h["Library"] = value;
	}
	{
		var value = tink_sql_Table10.makeInfo("GEnum",null);
		_g.h["GEnum"] = value;
	}
	{
		var value = tink_sql_Table11.makeInfo("GEnumMembers",null);
		_g.h["GEnumMembers"] = value;
	}
	$r = new tink_sql_DatabaseStaticInfo(_g);
	return $r;
}(this));
tink_sql_Database0.INFO = tink_sql_Transaction0.INFO;
tink_sql_drivers_MySql.sanitizer = new tink_sql_drivers__$MySql_MySqlSanitizer();
tink_sql_format_Statement.SEPARATE = tink_sql_format__$Statement_StatementMember.Sql(", ");
tink_sql_format_Statement.WHITESPACE = tink_sql_format__$Statement_StatementMember.Sql(" ");
Main.main();
})(typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
