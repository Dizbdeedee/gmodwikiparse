import js.node.Fs;
import haxe.io.Path;

interface Templates {
	final gclassTemplate:haxe.Template;
	final gclassFunctionTemplate:haxe.Template;
	final funcArgTemplate:haxe.Template;
	final funcArgEndTemplate:haxe.Template;
}

// TODO remove postfix template
class TemplatesDef implements Templates {
	public final gclassTemplate:haxe.Template;

	public final gclassFunctionTemplate:haxe.Template;

	public final funcArgTemplate:haxe.Template;

	public final funcArgEndTemplate:haxe.Template;

	static final LOCATION_TEMPLATES = "templates";

	public function new() {
		gclassTemplate = _gclassTemplate();
		gclassFunctionTemplate = _gclassFunctionTemplate();
		funcArgTemplate = _funcArgTemplate();
		funcArgEndTemplate = _funcArgEndTemplate();
	}

	function _gclassTemplate() {
		var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES, "GClass.template"]))
			.toString();
		return new haxe.Template(file);
	}

	function _gclassFunctionTemplate() {
		var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES, "GClassFunction.template"]))
			.toString();
		return new haxe.Template(file);
	}

	function _funcArgTemplate() {
		var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES, "Variable.template"]))
			.toString();
		return new haxe.Template(file);
	}

	function _funcArgEndTemplate() {
		var file = Fs.readFileSync(Path.join([LOCATION_TEMPLATES, "VariableEnd.template"]))
			.toString();
		return new haxe.Template(file);
	}
}
