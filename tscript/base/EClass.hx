package tscript.base;

typedef ClassDef = {
	/**
	 * This class is public?
	 */
	public var isPublic:Bool;

	/**
	 * Class dynamic value
	 */
	public var value:Dynamic;

	/**
	 * `final` variable? (idk)
	 */
	public var isFinal:Bool;

	/**
	 * This class no access?
	 */
	public var noAccess:Bool;

	/**
	 * Is function?
	 */
	public var isFun:Bool;
}

class EClass {
	/**
	 * Class name
	 */
	public var name:String;

	/**
	 * Class fields
	 */
	public var fields:Map<String, ClassDef> = [];

	/**
	 * New Class
	 * @param name class name
	 */
	public function new(name:String)
		this.name = name;

	public static function create(isPublic:Bool, value:Dynamic, isFinal:Bool, noAccess:Bool, isFun:Bool):ClassDef {
		return {
			isPublic: isPublic,
			value: value,
			isFinal: isFinal,
			noAccess: noAccess,
			isFun: isFun
		};
	}

	inline function toString():String
		return 'Class<$name>';
}
