package tscript.base;

enum Const {
	CInt(v:Int);
	CFloat(f:Float);
	CString(s:String, ?allowsInterp:Bool);
	#if !haxe3
	CInt32(v:haxe.Int32);
	#end
}

enum CType {
	CTPath(path:Array<String>, ?params:Array<CType>);
	CTFun(args:Array<CType>, ret:CType);
	CTAnon(fields:Array<{name:String, t:CType, ?meta:Defs.Metadata}>);
	CTParent(t:CType);
	CTOpt(t:CType);
	CTNamed(n:String, t:CType);
}
