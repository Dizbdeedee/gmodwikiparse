import tink.sql.Types;

@:transitive
enum abstract DescLinkType(SmallInt) from SmallInt to SmallInt {
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

typedef DescLink = {
	@:primary @:autoIncrement var id:Id<DescLink>;
	var ?textValue:MediumText;
	var type:DescLinkType;
	var ?nextDesc:Id<DescLink>;
}

typedef Function =  {
	@:primary @:autoIncrement var id:Id<Function>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var ?description:Id<DescLink>;
	var isHook:Bool;
	var stateClient:Bool;
	var stateMenu:Bool;
	var stateServer:Bool;
}

typedef Struct = {
	@:primary @:autoIncrement var id:Id<Struct>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var ?description:Id<DescLink>;
}

typedef StructMember = {
	// I think this matters. For some reason.
	@:primary var structOrder:SmallInt;
	@:primary var structID:Id<Struct>;
	var name:VarChar<255>;
	var type:VarChar<255>;
	var typeURL:VarChar<255>;
	var ?def:VarChar<255>;
}

typedef GClass = { 
	@:primary @:autoIncrement var id:Id<GClass>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var ?description:Id<DescLink>;
}

typedef Library = {
	@:primary @:autoIncrement var id:Id<Library>;
	var name:VarChar<255>;
	var url:VarChar<1024>;
	var ?description:Id<DescLink>;
}

// typedef FieldPage = {
// 	@:primary var id:Id<FieldPage>;
// 	var name:VarChar<255>;
// 	var url:VarChar<1024>;
// 	var description:Id<DescLink>;
// 	var type:VarChar<255>;
// 	var typeURL:VarChar<255>;
// }

// typedef FieldInline = {
// 	@:primary var id:Id<FieldInline>;
// 	var name:VarChar<255>;
// 	var description:Id<DescLink>;
// 	var type:VarChar<255>;
// 	var typeURL:VarChar<255>;
// 	var def:VarChar<255>;
// }

typedef FunctionArg = {
	@:primary var argumentNo:SmallInt;
	@:primary var funcid:Id<Function>;
	var name:VarChar<255>;
	var type:VarChar<255>;
	var typeURL:VarChar<255>;
	var ?def:VarChar<255>;
	var ?description:Id<DescLink>;
}

typedef FunctionRet = {
	@:primary var returnNo:SmallInt;
	@:primary var funcid:Id<Function>;
	var type:VarChar<255>;
	var typeURL:VarChar<255>;
	var ?desc:Id<DescLink>;
}

typedef LuaExample = {
	@:primary var exampleNo:SmallInt;
	@:primary var funcid:Id<Function>;
	var ?desc:Id<DescLink>;
	var ?output:Id<DescLink>;
	var code:Id<DescLink>;
}

typedef GEnum = {
	@:primary var id:Id<GEnum>;
	var ?desc:Id<DescLink>;
	var url:VarChar<1024>;
}

typedef GEnumMembers = {
	@:primary var memberNo:SmallInt;
	@:primary var enumID:Id<GEnum>;
	var enumName:VarChar<255>;
	var ?desc:Id<DescLink>;
	var ?value:VarChar<255>;
}



@:tables(DescLink,Function,FunctionArg,FunctionRet)
interface WikiDBDef extends tink.sql.DatabaseDefinition {}
typedef WikiDB = tink.sql.Database<WikiDBDef>;
// class TypingDB extends tink.sql.Database {}