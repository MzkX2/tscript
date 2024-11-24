package tscript.backend;

import tscript.TScript;

enum PresetMode {
	NONE;
	MINI;
	REGULAR;
}

@:access(tscript.TScript)
class Preset {
	public var haxeMode:PresetMode;

	var script:TScript;
	var _destroyed:Bool = false;

	public function new(script:TScript) {
		if (script == null || script._destroyed)
			return;

		this.script = script;
		haxeMode = TScript.DEFAULT_PRESET;
	}

	function preset() {
		if (_destroyed || script == null || script._destroyed)
			return;

		var hArray:Array<Class<Dynamic>>;

		@:privateAccess {
			hArray = switch haxeMode {
				case MINI: PresetClasses.miniHaxe;
				case REGULAR: PresetClasses.regularHaxe;
				case NONE: [];
			}
		}

		for (i in hArray.copy())
			script.setClass(i);
	}

	function destroy() {
		if (_destroyed)
			return;

		script = null;
		haxeMode = null;

		_destroyed = true;
	}
}

class PresetClasses {
	static var miniHaxe:Array<Class<Dynamic>> = [
		Date,
		DateTools,
		EReg,
		Math,
		Reflect,
		Std,
		StringTools,
		Type,
		#if sys Sys, sys.io.File, sys.FileSystem #end
	];

	static var regularHaxe:Array<Class<Dynamic>> = {
		var array = miniHaxe.copy();
		var array2:Array<Class<Dynamic>> = [
			EReg,
			List,
			StringBuf,
			Xml,
			haxe.Http,
			haxe.Json,
			haxe.Log,
			haxe.Serializer,
			haxe.Unserializer,
			haxe.Timer,
			#if sys haxe.SysTools, sys.io.Process, sys.io.FileInput, sys.io.FileOutput, #end
		];
		for (i in array2)
			array.push(i);
		array;
	}
}
