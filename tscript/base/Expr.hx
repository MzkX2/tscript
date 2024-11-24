package tscript.base;

typedef Expr = {
	var e:ExprDef;
	var pmin:Int;
	var pmax:Int;
	var origin:String;
	var line:Int;
}

enum ExprDef {
	EPublic(e:Expr);
	EPrivate(e:Expr);
	EStatic(e:Expr, ?inPublic:Bool);
	EInterpString(strings:Array<String>, interpolatedString:Array<{str:String, index:Int}>);
	EConst(c:Const);
	EIdent(v:String);
	EVar(n:String, finall:Bool, ?t:Const.CType, ?e:Expr);
	EParent(e:Expr);
	EBlock(e:Array<Expr>);
	EField(e:Expr, f:String, fAll:Array<String>);
	EBinop(op:String, e1:Expr, e2:Expr);
	ESwitchBinop(p:Expr, e1:Expr, e2:Expr);
	EUnop(op:String, prefix:Bool, e:Expr);
	ECall(e:Expr, params:Array<Expr>);
	EIf(cond:Expr, e1:Expr, ?e2:Expr);
	EWhile(cond:Expr, e:Expr);
	EFor(v:String, v2:String, it:Expr, e:Expr);
	ECoalesce(e1:Expr, e2:Expr, assign:Bool);
	ESafeNavigator(e1:Expr, f:String);
	EBreak;
	EContinue;
	EFunction(args:Array<Defs.Argument>, e:Expr, ?name:String, ?ret:Const.CType, ?line:Int);
	EReturnEmpty;
	EReturn(e:Expr);
	EArray(e:Expr, index:Expr);
	EArrayDecl(e:Array<Expr>);
	ENew(cl:String, params:Array<Expr>, ?subIds:Array<String>);
	EThrow(e:Expr);
	ETry(e:Expr, v:String, t:Null<Const.CType>, ecatch:Expr);
	EObject(fl:Array<{name:String, e:Expr}>);
	ETernary(cond:Expr, e1:Expr, e2:Expr);
	ESwitch(e:Expr, cases:Array<{values:Array<Expr>, expr:Expr, ifExpr:Expr}>, ?defaultExpr:Expr);
	EDoWhile(cond:Expr, e:Expr);
	EUsing(op:Dynamic, n:String);
	EImport(i:Dynamic, c:String, ?asIdent:String, ?fullName:String);
	EImportStar(pkg:String);
	EClass(cl:String, exprs:Array<Expr>);
	EEAbstract(ident:String, type:String, exprs:Array<Expr>, fromParent:String);
	EPackage(?p:String);
	EMeta(hasDot:Bool, name:String, args:Array<Expr>, e:Expr);
	EEReg(chars:String, ops:String);
	ECheckType(e:Expr, t:Const.CType);
}
