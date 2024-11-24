package tscript.base;

typedef Argument = {name:String, ?t:Const.CType, ?opt:Bool, ?value:Expr};
typedef Metadata = Array<{name:String, params:Array<Expr>}>;

typedef ClassDecl = {
	> Module.ModuleType,
	var extend:Null<Const.CType>;
	var implement:Array<Const.CType>;
	var fields:Array<Field.FieldDecl>;
	var isExtern:Bool;
}

typedef TypeDecl = {
	> Module.ModuleType,
	var t:Const.CType;
}

typedef FunctionDecl = {
	var args:Array<Argument>;
	var expr:Expr;
	var ret:Null<Const.CType>;
}

typedef VarDecl = {
	var get:Null<String>;
	var set:Null<String>;
	var expr:Null<Expr>;
	var type:Null<Const.CType>;
}
