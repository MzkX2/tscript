package tscript.base;

typedef AbstractDef = {
	/**
	 * This abstract is public?
	 */
	public var isPublic:Bool;

	/**
	 * Abstract name.
	 */
	public var name:String;

	/**
	 * Dynamic value.
	 */
	public var value:Dynamic;
}

class EAbstract {
	/**
	 * Abstract name.
	 */
	var name:String;

	/**
	 * Creating a `AbstractDef` for this.
	 * @param isPublic This abstract value is public?
	 * @param name Abstract value name
	 * @param value Abstract dynamic value
	 * @return `AbstractDef` (this `typedef` with values)
	 */
	public static function create(isPublic:Bool, name:String, value:Bool):AbstractDef {
		return {
			isPublic: isPublic,
			name: name,
			value: value
		}
	}

	public var fields:Map<String, AbstractDef> = [];

	public function new(name:String)
		this.name = name;

	inline function toString():String
		throw "Cannot use 'abstract' to string, because is value!";
}
