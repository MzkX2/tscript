package tscript.base;

/**
 * For Interp, this Iterator class show's a minimum iterator and maximum.
 */
@:keepSub
@:access(tscript.base.Interp)
class InterpIterator {
	/**
	 * Interp Iterator Minimum value.
	 */
	public var min:Int;

	/**
	 * Interp Iterator Maximum value.
	 */
	public var max:Int;

	/**
	 * Creating new Iterator.
	 * @param instance `Interp` class.
	 * @param expr1 For `min` value. Be right that this is with type `Int`.
	 * @param expr2 For `max` value. Be right that this is with type `Int`.
	 */
	public inline function new(instance:Interp, expr1:Expr, expr2:Expr):Void {
		var min:Dynamic = instance.expr(expr1);
		var max:Dynamic = instance.expr(expr2);

		// Error's push up's
		if (min == null)
			instance.error(ECustom("'null' should be 'Int'"));
		if (max == null)
			instance.error(ECustom("'null' should be 'Int'"));

		if (Std.isOfType(min, Float) && !Std.isOfType(min, Int))
			instance.error(ECustom("'Float' should be 'Int'"));
		if (Std.isOfType(max, Float) && !Std.isOfType(max, Int))
			instance.error(ECustom("'Float' should be 'Int'"));

		if (!Std.isOfType(min, Int))
			instance.error(ECustom("'" + Type.getClassName(Type.getClass(min)) + "' should be 'Int'"));
		if (!Std.isOfType(max, Int))
			instance.error(ECustom("'" + Type.getClassName(Type.getClass(max)) + "' should be 'Int'"));

		this.min = min;
		this.max = max;

		instance = null;
		expr1 = null;
		expr2 = null;
	}

	/**
	 * Minimum below Maximum Iterator?
	 * @return False or True
	 */
	public inline function hasNext():Bool
		return min < max;

	/**
	 * Added a num for `min` value.
	 * @return A next `min` value.
	 */
	public inline function next():Int
		return min++;
}
