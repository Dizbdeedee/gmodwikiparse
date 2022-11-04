import tink.sql.Types;

//Initial db. Only things we can directly infer from the page live here.

@:transitive
enum abstract DescItemType(SmallInt) from SmallInt to SmallInt {
	var DESCRIPTION;
	var DESCRIPTION_BREAK_ABOVE;
	var DESCRIPTION_BREAK_BELOW;
	var LINK_TEXT;
	var LINK_URL;
	var BEGIN_NOTE;
	var END_NOTE;
	var BEGIN_WARNING;
	var END_WARNING;
	var BEGIN_INTERNAL;
	var END_INTERNAL;
	var BEGIN_BUG;
	var END_BUG;
	var BEGIN_DEPRECATED;
	var END_DEPRECATED;
	var BEGIN_LUA_CODE;
	var LUA_CODE;
	var END_LUA_CODE;
	var BEGIN_JAVASCRIPT;
	var END_JAVASCRIPT;
	var BEGIN_LIST;
	var LIST_ITEM;
	var END_LIST;
	var HEADING;
	var TITLE;
	var BEGIN_VALIDATE;
	var END_VALIDATE;
	var BEGIN_CODE; //highlight
	var END_CODE;
	var BEGIN_STRONG;
	var END_STRONG;
	var BEGIN_KEY;
	var END_KEY;
	var BEGIN_REMOVED;
	var END_REMOVED;
}

//linked lists are generally a bad idea... cool
typedef DescItem = {
	@:primary
	@:autoIncrement
	var id(default,never):Id<DescItem>;
	var ?textValue(default,never):MediumText;
	var type(default,never):DescItemType;
	// var ?nextDesc:Id<DescItem>;
	// var ?prevDesc:Id<DescItem>;
}

typedef DescriptionStorage = {
	
	var id(default,never):Id<DescriptionStorage>;
	var descItem(default,never):Id<DescItem>;
}

typedef Function = {
	@:primary 
	@:autoIncrement
	var id(default,never):Id<Function>;
	var name(default,never):VarChar<255>;
	var url(default,never):VarChar<1024>;
	var ?description(default,never):Id<DescriptionStorage>;
	var isHook(default,never):Bool;
	var stateClient(default,never):Bool;
	var stateMenu(default,never):Bool;
	var stateServer(default,never):Bool;
}

typedef FunctionArg = {
	var argumentNo(default,never):SmallInt;
	var funcid(default,never):Id<Function>;
	var name(default,never):VarChar<255>;
	var type(default,never):VarChar<255>;
	var typeURL(default,never):VarChar<255>;
	var ?def(default,never):VarChar<255>;
	var ?description(default,never):Id<DescriptionStorage>;
}

typedef FunctionRet = {
	var returnNo(default,never):SmallInt;
	var funcid(default,never):Id<Function>;
	var type(default,never):VarChar<255>;
	var typeURL(default,never):VarChar<255>;
	var ?desc(default,never):Id<DescItem>;
}

typedef LuaExample = {
	var exampleNo(default,never):SmallInt;
	var funcid(default,never):Id<Function>;
	var ?desc(default,never):Id<DescriptionStorage>;
	var ?output(default,never):Id<DescriptionStorage>;
	var code(default,never):Id<DescriptionStorage>;
}

typedef Struct = {
	@:autoIncrement
	@:primary var id(default,never):Id<Struct>;
	var name(default,never):VarChar<255>;
	var url(default,never):VarChar<1024>;
	var ?description(default,never):Id<DescriptionStorage>;
}

typedef StructMember = {
	// I think this matters. For some reason.
	var structOrder(default,never):SmallInt;
	var structID(default,never):Id<Struct>;
	var name(default,never):VarChar<255>;
	var type(default,never):VarChar<255>;
	var typeURL(default,never):VarChar<1024>;
	var ?def(default,never):VarChar<255>;
}

typedef GClass = {
	@:autoIncrement
	@:primary var id(default,never):Id<GClass>;
	var name(default,never):VarChar<255>;
	var url(default,never):VarChar<1024>;
	var ?description(default,never):Id<DescriptionStorage>;
}

typedef Library = {
	@:autoIncrement
	@:primary var id(default,never):Id<Library>;
	var name(default,never):VarChar<255>;
	var url(default,never):VarChar<1024>;
	var ?description(default,never):Id<DescriptionStorage>;
}

//fieldinline?

typedef GEnum = {
	@:autoIncrement
	@:primary var id(default,never):Id<GEnum>;
	var ?desc(default,never):Id<DescriptionStorage>;
	var url(default,never):VarChar<1024>;
}

typedef GEnumMembers = {
	var memberNo(default,never):SmallInt;
	var enumID(default,never):Id<GEnum>;
	var enumName(default,never):VarChar<255>;
	var ?desc(default,never):Id<DescriptionStorage>;
	var ?value(default,never):VarChar<255>;
}



@:tables(DescItem,DescriptionStorage,Function,FunctionArg,FunctionRet,LuaExample,Struct,StructMember,GClass,Library,GEnum,GEnumMembers)
interface WikiDBDef extends tink.sql.DatabaseDefinition {}
typedef WikiDB = tink.sql.Database<WikiDBDef>;

//Lua linkage. All the things we can infer from links, and strings. Lua type inference goes here.

typedef LibraryOwns = {
	@:primary var libraryID(default,never):Id<Library>;
	@:primary var funcID(default,never):Id<Function>;
}

typedef GClassOwns = {
	@:primary var gclassID(default,never):Id<GClass>;
	@:primary var funcID(default,never):Id<Function>;
}

typedef HookOwns = {
	@:primary var hookID(default,never):Id<GClass>; //did we forget hooks?
	@:primary var funcID(default,never):Id<Function>;
}

//if we don't match in this table something has gone wrong with resolving types and we need to abort
typedef ResolvedTypes = {
	@:primary var typeID(default,never):Id<ResolvedTypes>;
	@:unique var name(default,never):VarChar<255>;
}

typedef FunctionArgTypeResolve = {
	@:primary var funcArgID(default,never):Id<FunctionArg>;
	var typeID(default,never):Id<ResolvedTypes>;
}

typedef FunctionRetTypeResolve = {
	@:primary var funcRetID(default,never):Id<FunctionRet>;
	var typeID(default,never):Id<ResolvedTypes>;
}

typedef StructMemberResolve = {
	@:primary var structMemeberID(default,never):Id<StructMember>;
	var typeID(default,never):Id<ResolvedTypes>;
}


interface LinkageDBDef extends tink.sql.DatabaseDefinition {}
// class TypingDB extends tink.sql.Database {}


typedef HaxeTypes = {
	@:primary var haxeTypeID(default,never):Id<HaxeTypes>;
	@:unique var name(default,never):VarChar<255>;
}

typedef Transformation = {
	@:primary var luaName(default,never):VarChar<255>;
	var haxeName(default,never):VarChar<255>;
}

typedef Patches = {
	@:primary var patchID(default,never):Id<Patches>;
	//the sql statement to select args by
	var select(default,never):MediumText;
	//what to transform it into
	var haxeName(default,never):VarChar<255>;
}

interface HaxeTransformations extends tink.sql.DatabaseDefinition {}

interface HaxeFinal extends tink.sql.DatabaseDefinition {}