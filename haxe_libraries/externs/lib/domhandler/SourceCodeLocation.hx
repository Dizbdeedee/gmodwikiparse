package domhandler;

typedef SourceCodeLocation = {
	/**
		One-based line index of the first character.
	**/
	var startLine : Float;
	/**
		One-based column index of the first character.
	**/
	var startCol : Float;
	/**
		Zero-based first character index.
	**/
	var startOffset : Float;
	/**
		One-based line index of the last character.
	**/
	var endLine : Float;
	/**
		One-based column index of the last character. Points directly *after* the last character.
	**/
	var endCol : Float;
	/**
		Zero-based last character index. Points directly *after* the last character.
	**/
	var endOffset : Float;
};