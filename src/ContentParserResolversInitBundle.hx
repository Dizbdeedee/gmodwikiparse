import generators.standard.FunctionResolver;
import generators.library.LibraryResolver;
import generators.genum.GEnumResolver;
import generators.struct.StructResolver;
import generators.hook.HookResolver;
import generators.panel.PanelResolver;
import generators.gclass.GClassResolver;

typedef ContentParserResolversInitBundle = {
	_funcResolver:FunctionResolver,
	_gclassResolver:GClassResolver,
	_panelResolver:PanelResolver,
	_structResolver:StructResolver,
	_enumResolver:GEnumResolver,
	_libraryResolver:LibraryResolver,
	_hookResolver:HookResolver,
}
