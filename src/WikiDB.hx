import tink.sql.Types;

@:transitive
enum abstract DescLinkType(SmallInt) from SmallInt to SmallInt {
	var DESCRIPTION;
	var DESCRIPTION_NEWLINE;
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
	var LUA_CODE;
}

typedef DescLink = {
	var id:Id<DescLink>;
	var textValue:MediumText;
	var type:DescLinkType;
	var nextDesc:Null<Id<DescLink>>;
}

typedef Function =  {
	var id:Id<Function>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
	var isHook:Bool;
	var stateClient:Bool;
	var stateMenu:Bool;
	var stateServer:Bool;
}

typedef GEnum = {
	var id:Id<GEnum>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
}

typedef Struct = {
	var id:Id<Struct>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
}

typedef GClass = { 
	var id:Id<GClass>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
}

typedef Library = {
	var id:Id<Library>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
}

typedef FieldPage = {
	var id:Id<FieldPage>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var description:Id<DescLink>;
	var type:VarChar<255>;
}

typedef FieldInline = {
	var id:Id<FieldInline>;
	var name:VarChar<255>;
	var description:Id<DescLink>;
	var type:VarChar<255>;
	var def:VarChar<255>;
}

typedef FunctionArg = {
	var id:Id<FunctionArg>;
	var funcid:Id<Function>;
	var name:VarChar<255>;
	var type:VarChar<255>;
	var def:VarChar<255>;
	var description:Id<DescLink>;
}

typedef FunctionRet = {
	var id:Id<FunctionRet>;
	var funcid:Id<Function>;
	var type:VarChar<255>;
	var desc:Id<DescLink>;
}

typedef LuaExample = {
	var id:Id<LuaExample>;
	var funcid:Id<Function>;
	var desc:Id<DescLink>;
	var example:MediumText;
	var output:Null<MediumText>;
}

@:tables(DescLink,Function,FunctionArg,FunctionRet)
interface WikiDBDef extends tink.sql.DatabaseDefinition {}
typedef WikiDB = tink.sql.Database<WikiDBDef>;
// class TypingDB extends tink.sql.Database {}