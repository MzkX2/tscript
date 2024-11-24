package tscript.base;

enum ModuleDecl {
	DPackage(path:Array<String>);
	DImport(path:Array<String>, ?everything:Bool, ?asIdent:String);
	DClass(c:Defs.ClassDecl);
	DTypedef(c:Defs.TypeDecl);
}

typedef ModuleType = {
	var name:String;
	var meta:Defs.Metadata;
	var isPrivate:Bool;
}
