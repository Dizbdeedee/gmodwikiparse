import generators.gclass.GClassResolver;
import generators.standard.FunctionResolver;
import data.WikiDB.DescItem;
import generators.desc.DescriptionParser;
import generators.standard.UnresolvedFunctionParse;
import generators.standard.UnresolvedFunctionRetParse;
import generators.standard.UnresolvedFunctionArgParse;
import generators.genum.GEnumResolver;
import generators.library.LibraryResolver;
import generators.panel.PanelResolver;
import generators.struct.StructResolver;
import generators.desc.DescriptionPublisher;
import cheerio.lib.cheerio.Cheerio;
import generators.desc.DescSelector;
import cheerio.lib.load.CheerioAPI;
import generators.hook.HookResolver;
import ContentParser;
import ContentParserTest;
import ParseChooser;

class Creation {
	public static function contentParserTest() {
		return {
			final descParser:DescriptionParser = {
				var descParserLZ = new DescriptionParserLazy();
				var _descParser = new DescriptionParserDef([
					new PSelector(descParserLZ),
					new NoteSelector(descParserLZ),
					new WarnSelector(descParserLZ),
					new BugSelector(descParserLZ),
					new DeprecatedSelector(descParserLZ),
					new RemovedSelector(descParserLZ),
					new ListSelector(descParserLZ),
					new LuaCodeSelector(descParserLZ),
					new HeadingSelector(),
					new HeadingWithSectionSelector(),
					new ValidateSelector(descParserLZ),
					new TitleSelector(),
					new AnchorSelector(),
					new ImageSelector(),
					new TextSelector(),
					new LinkSelector(),
					new TableSelector(),
					new CodeTagSelector(),
					new StrongSelector(),
					new BRSelector(),
					new JSCodeSelector(),
					new KeySelector(),
					new InternalSelector(descParserLZ),
					new ItalicsSelector(),
					new ImgSelector(),
					new ListItemSelector(),
					new CodeFeatureSelector(descParserLZ),
					new BoldSelector(),
					new NumberListSelector(descParserLZ)
				]);
				descParserLZ.resolve(_descParser);
				_descParser;
			}
			var func = new FunctionResolverDef(new UnresolvedFunctionParseDef(descParser)
				, new UnresolvedFunctionArgParseDef(descParser)
					, new UnresolvedFunctionRetParseDef(descParser), new DescriptionPublisherDef());
			var gclass = new GClassResolverDef(descParser, new DescriptionPublisherDef());
			var panel = new PanelResolverDef(descParser, new DescriptionPublisherDef());
			var struct = new StructResolverDef(descParser, new DescriptionPublisherDef());
			var genum = new GEnumResolverDef(descParser, new DescriptionPublisherDef());
			var library = new LibraryResolverDef(descParser, new DescriptionPublisherDef());
			var hook = new HookResolverDef(descParser, new DescriptionPublisherDef());

			final _contentParser = new ContentParserTestDef(new ParseChooserDef(), {
				_panelResolver: panel,
				_structResolver: struct,
				_enumResolver: genum,
				_gclassResolver: gclass,
				_libraryResolver: library,
				_funcResolver: func,
				_hookResolver: hook
			});
			_contentParser;
		}
	}

	public static function contentParser() {
		return {
			final descParser:DescriptionParser = {
				var descParserLZ = new DescriptionParserLazy();
				var _descParser = new DescriptionParserDef([
					new PSelector(descParserLZ),
					new NoteSelector(descParserLZ),
					new WarnSelector(descParserLZ),
					new BugSelector(descParserLZ),
					new DeprecatedSelector(descParserLZ),
					new RemovedSelector(descParserLZ),
					new ListSelector(descParserLZ),
					new LuaCodeSelector(descParserLZ),
					new HeadingSelector(),
					new HeadingWithSectionSelector(),
					new ValidateSelector(descParserLZ),
					new TitleSelector(),
					new AnchorSelector(),
					new ImageSelector(),
					new TextSelector(),
					new LinkSelector(),
					new TableSelector(),
					new CodeTagSelector(),
					new StrongSelector(),
					new BRSelector(),
					new JSCodeSelector(),
					new KeySelector(),
					new InternalSelector(descParserLZ),
					new ItalicsSelector(),
					new ImgSelector(),
					new ListItemSelector(),
					new CodeFeatureSelector(descParserLZ),
					new BoldSelector(),
					new NumberListSelector(descParserLZ)
				]);
				descParserLZ.resolve(_descParser);
				_descParser;
			}
			var func = new FunctionResolverDef(new UnresolvedFunctionParseDef(descParser)
				, new UnresolvedFunctionArgParseDef(descParser)
					, new UnresolvedFunctionRetParseDef(descParser), new DescriptionPublisherDef());
			var gclass = new GClassResolverDef(descParser, new DescriptionPublisherDef());
			var panel = new PanelResolverDef(descParser, new DescriptionPublisherDef());
			var struct = new StructResolverDef(descParser, new DescriptionPublisherDef());
			var genum = new GEnumResolverDef(descParser, new DescriptionPublisherDef());
			var library = new LibraryResolverDef(descParser, new DescriptionPublisherDef());
			var hook = new HookResolverDef(descParser, new DescriptionPublisherDef());

			final _contentParser = new ContentParserDef(new ParseChooserDef(), {
				_panelResolver: panel,
				_structResolver: struct,
				_enumResolver: genum,
				_gclassResolver: gclass,
				_libraryResolver: library,
				_funcResolver: func,
				_hookResolver: hook
			});
			_contentParser;
		}
	}
}

// TODO... sigh
class DescriptionParserLazy implements generators.desc.DescriptionParser {
	var descParser:generators.desc.DescriptionParser;

	public function new() {}

	public function resolve(_descParser:DescriptionParser) {
		descParser = _descParser;
	}

	public function parseDescNode(elem:Cheerio<Dynamic>, jq:CheerioAPI):Array<DescItem> {
		return descParser.parseDescNode(elem, jq);
	}
}
