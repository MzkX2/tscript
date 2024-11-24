package tscript.base;

typedef FieldDecl = {
	var name:String;
	var meta:Defs.Metadata;
	var kind:FieldKind;
	var access:Array<FieldAccess>;
}

enum FieldAccess {
	APublic;
	APrivate;
	AInline;
	AOverride;
	AStatic;
	AMacro;
}

enum FieldKind {
	KFunction(f:Defs.FunctionDecl);
	KVar(v:Defs.VarDecl);
}
