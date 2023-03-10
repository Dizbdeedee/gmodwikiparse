package data;
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
    var BEGIN_NUMBER_LIST;
    var END_NUMBER_LIST;
}

//linked lists are generally a bad idea... cool
typedef DescItem = {
    @:primary
    @:autoIncrement
    var id(default,never):Id<DescItem>;
    var ?textValue(default,never):MediumText;
    var type(default,never):DescItemType;
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
    var stateClient(default,never):Bool; //should be realm
    var stateMenu(default,never):Bool;
    var stateServer(default,never):Bool;
    var isDeprecated(default,never):Bool;
    var isInternal(default,never):Bool;
}

typedef FunctionArg = {
    @:primary
    @:autoIncrement
    var id(default,never):Id<FunctionArg>;
    var argumentNo(default,never):SmallInt;
    var funcid(default,never):Id<Function>;
    var name(default,never):VarChar<255>;
    var type(default,never):VarChar<255>;
    var typeURL(default,never):VarChar<255>;
    var ?def(default,never):VarChar<255>;
    var ?description(default,never):Id<DescriptionStorage>;
}

typedef FunctionRet = {
    @:primary
    @:autoIncrement
    var id(default,never):Id<FunctionRet>;
    var returnNo(default,never):SmallInt;
    var funcid(default,never):Id<Function>;
    var type(default,never):VarChar<255>;
    var typeURL(default,never):VarChar<255>;
    var ?desc(default,never):Id<DescriptionStorage>;
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
    var realmServer(default,never):Bool;
    var realmClient(default,never):Bool;
    var realmMenu(default,never):Bool;
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
    var isDeprecated(default,never):Bool;
}

typedef GClassURL = {
    var urlNo(default,never):SmallInt;
    var gclassID(default,never):Id<GClass>;
    var url(default,never):VarChar<1024>;
}

typedef GClassField = {
    var fieldNo(default,never):SmallInt;
    var gclassID(default,never):Id<GClass>;
    var typeURL(default,never):VarChar<255>;
    var type(default,never):VarChar<255>;
    var description:Id<DescriptionStorage>;
}

typedef Library = {
    @:autoIncrement
    @:primary var id(default,never):Id<Library>;
    var name(default,never):VarChar<255>;
    var url(default,never):VarChar<1024>;
    var ?description(default,never):Id<DescriptionStorage>;
    var isDeprecated(default,never):Bool;
}

typedef LibraryURL = {
    var urlNo(default,never):SmallInt;
    var libraryID(default,never):Id<Library>;
    var url(default,never):VarChar<1024>;
}

typedef LibraryField = {
    var fieldNo(default,never):SmallInt;
    var name(default,never):VarChar<255>;
    var libraryID(default,never):Id<Library>;
    var type(default,never):VarChar<255>;
    var typeURL(default,never):VarChar<255>;
    var description(default,never):Id<DescriptionStorage>;
}

typedef Hook = {
    @:autoIncrement
    @:primary var id(default,never):Id<Hook>;
    var name(default,never):VarChar<255>;
    var url(default,never):VarChar<1024>;
    var ?description(default,never):Id<DescriptionStorage>;
}

typedef HookURL = {
    var urlNo(default,never):SmallInt;
    var hookID(default,never):Id<Hook>;
    var url(default,never):VarChar<1024>;
}

typedef Panel = {
    @:autoIncrement
    @:primary var id(default,never):Id<Panel>;
    var name(default,never):VarChar<255>;
    var url(default,never):VarChar<1024>;
    var ?parentLink(default,never):VarChar<1024>;
    var ?description(default,never):Id<DescriptionStorage>;
    var isDeprecated(default,never):Bool;
    var isInternal(default,never):Bool;
}

typedef PanelURL = {
    var urlNo(default,never):SmallInt;
    var panelID(default,never):Id<Panel>;
    var url:VarChar<1024>;
}

//fieldinline?

typedef GEnum = {
    @:autoIncrement
    @:primary var id(default,never):Id<GEnum>;
    var ?desc(default,never):Id<DescriptionStorage>;
    var url(default,never):VarChar<1024>;
    var isDeprecated(default,never):Bool;
    var realmServer(default,never):Bool;
    var realmClient(default,never):Bool;
    var realmMenu(default,never):Bool;
}

typedef GEnumMembers = {
    var memberNo(default,never):SmallInt;
    var enumID(default,never):Id<GEnum>;
    var enumName(default,never):VarChar<255>;
    var ?desc(default,never):Id<DescriptionStorage>;
    var ?value(default,never):VarChar<255>;
}

//Lua linkage. All the things we can infer from links, and strings. Lua type inference goes here.

typedef Link_LibraryOwns = {
    var libraryID(default,never):Id<Library>;
    var funcID(default,never):Id<Function>;
}

typedef Link_PanelOwns = {
    var panelID(default,never):Id<Panel>;
    var funcID(default,never):Id<Function>;
}

typedef Link_GClassOwns = {
    var gclassID(default,never):Id<GClass>;
    var funcID(default,never):Id<Function>;
}

typedef Link_HookOwns = {
    var hookID(default,never):Id<GClass>; //did we forget hooks?
    var funcID(default,never):Id<Function>;
}

//if we don't match in this table something has gone wrong with resolving types and we need to abort
typedef Link_ResolvedTypes = {
    @:primary
    @:autoIncrement var typeID(default,never):Id<Link_ResolvedTypes>;
    var name(default,never):VarChar<255>;
    var url(default,never):Null<VarChar<255>>;
}

// typedef Link_MultiType = {
//     var linkage(default,never):Id<Link_MultiType>;
//     var typeID(default,never):Id<Link_ResolvedTypes>;
// }

typedef Link_Category = {
    var cid(default,never):Id<Link_Category>;
    var name(default,never):VarChar<255>;
    var rank(default,never):SmallInt;
}

typedef Link_FunctionArgTypeResolve = {
    var funcArgNo(default,never):Id<FunctionArg>;
    var typeID(default,never):Id<Link_ResolvedTypes>;
}

typedef Link_FunctionRetTypeResolve = {
    var funcRetID(default,never):Id<FunctionRet>;
    var typeID(default,never):Id<Link_ResolvedTypes>;
}

typedef Link_StructMemberResolve = {
    @:primary var structMemeberID(default,never):Id<StructMember>;
    var typeID(default,never):Id<Link_ResolvedTypes>;
}

@:tables(DescItem,DescriptionStorage,Function,FunctionArg,FunctionRet,LuaExample,Struct,StructMember,GClass,Library,GEnum,GEnumMembers,
    GClassURL,Panel,PanelURL,
    LibraryField,LibraryURL,
    Hook,HookURL,
    Link_LibraryOwns,Link_GClassOwns,Link_HookOwns,
    Link_ResolvedTypes,Link_FunctionArgTypeResolve,
    Link_FunctionRetTypeResolve,Link_StructMemberResolve,
    Link_Category
)
interface WikiDBDef extends tink.sql.DatabaseDefinition {}
typedef WikiDB = tink.sql.Database<WikiDBDef>;

typedef HaxeTypes = {
    @:primary var haxeTypeID(default,never):Id<HaxeTypes>;
    @:unique var name(default,never):VarChar<255>;
}

typedef Transformation = {
    @:unique var luaName(default,never):VarChar<255>;
    var haxeName(default,never):VarChar<255>;
}

typedef Patches = {
    @:primary var patchID(default,never):Id<Patches>;
    var name(default,never):MediumText;
    //the sql statement to select args by
    var select(default,never):MediumText;
}

interface HaxeTransformations extends tink.sql.DatabaseDefinition {}

interface HaxeFinal extends tink.sql.DatabaseDefinition {}