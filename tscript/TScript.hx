package tscript;

import haxe.Exception as OGException;
import haxe.Timer;
import tscript.base.*;
import tscript.base.Expr;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import tscript.backend.Exception;
import tscript.backend.GlobalMap;
import tscript.backend.Preset;

using StringTools;

typedef FileData =
{
	#if sys
	/**
	 * File path value
	 */
	public var ?fileName(default, null):String;
	#end

	/**
	 * Script succeded to parse?
	 */
	public var succeeded(default, null):Bool;

	/**
	 * Called function value
	 */
	public var calledFunction(default, null):String;

	/**
	 * Returning dynamic value
	 */
	public var returnValue(default, null):Null<Dynamic>;

	/**
	 * All exceptions
	 */
	public var exceptions(default, null):Array<Exception>;

	/**
	 * Last reported time value
	 */
	public var lastReportedTime(default, null):Float;
}

/**
 * Main class for scripting stuff.
 */
@:structInit
@:access(tscript.backend.Preset)
@:access(tscript.base.Interp)
@:access(tscript.base.Parser)
@:access(tscript.base.Tools)
@:keepSub
class TScript
{
	/**
	 * Default constant preset
	 */
	public static final DEFAULT_PRESET:PresetMode = MINI;

	/**
	 * Global variables map
	 */
	public static var globalVariables:GlobalMap = new GlobalMap();

	/**
	 * Global map
	 */
	public static var global(default, null):Map<String, TScript> = [];

	/**
	 * Default improved field value
	 */
	public static var defaultImprovedField(default, set):Null<Bool> = true;

	static function set_defaultImprovedField(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			if (i != null && !i._destroyed)
				i.improvedField = value;
		}

		return defaultImprovedField = value;
	}

	/**
	 * Default type check value
	 */
	public static var defaultTypeCheck(default, set):Null<Bool> = true;

	static function set_defaultTypeCheck(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			if (i != null && !i._destroyed)
				i.typeCheck = value == null ? false : value;
		}

		return defaultTypeCheck = value;
	}

	/**
	 * Default debug mode
	 */
	public static var defaultDebug(default, set):Null<Bool> = null;

	static function set_defaultDebug(value:Null<Bool>):Null<Bool>
	{
		for (i in global)
		{
			if (i != null && !i._destroyed)
				i.debugTraces = value == null ? false : value;
		}

		return defaultDebug = value;
	}

	/**
	 * Default function name
	 */
	public static var defaultFun(default, set):String = "main";

	static function set_defaultFun(value:String):String
	{
		for (i in global)
		{
			if (i != null && !i._destroyed)
				i.defaultFunc = value;
		}

		return defaultFun = value;
	}

	/**
	 * Script ID Count
	 */
	static var IDCount(default, null):Int = 0;

	/**
	 * EReg blank
	 */
	static var BlankReg(get, never):EReg;

	static function get_BlankReg():EReg
	{
		return ~/^[\n\r\t]$/;
	}

	/**
	 * EReg class
	 */
	static var classReg(get, never):EReg;

	static function get_classReg():EReg
	{
		return ~/^[a-zA-Z_][a-zA-Z0-9_]*$/;
	}

	/**
	 * Improved field value
	 */
	public var improvedField(default, set):Null<Bool> = true;

	function set_improvedField(value:Null<Bool>):Null<Bool>
	{
		if (_destroyed)
			return null;

		if (interp != null)
			interp.improvedField = value == null ? false : value;
		return improvedField = value;
	}

	/**
	 * Custom origin value
	 */
	public var customOrigin(default, set):String;

	function set_customOrigin(value:String):String
	{
		if (_destroyed)
			return null;

		@:privateAccess parser.origin = value;
		return customOrigin = value;
	}

	/**
	 * Variables map value
	 */
	public var variables(get, never):Map<String, Dynamic>;

	function get_variables():Map<String, Dynamic>
	{
		if (_destroyed)
			return null;

		return interp.variables;
	}

	/**
	 * Package path value
	 */
	public var packagePath(get, null):String = "";

	function get_packagePath():String
	{
		if (_destroyed)
			return null;

		return packagePath;
	}

	/**
	 * Class path value
	 */
	public var classPath(get, null):String;

	function get_classPath():String
	{
		if (_destroyed)
			return null;

		return classPath;
	}

	/**
	 * Return dynamic value
	 */
	public var returnValue(default, null):Null<Dynamic>;

	/**
	 * Script ID Value
	 */
	public var ID(default, null):Null<Int> = null;

	/**
	 * Last reported time value
	 */
	public var lastReportedTime(default, null):Float = -1;

	/**
	 * Not allowed classes dynamic array value
	 */
	public var notAllowedClasses(default, null):Array<Class<Dynamic>> = [];

	/**
	 * Script pressetter (cool guy lol)
	 */
	public var presetter(default, null):Preset;

	/**
	 * Interp for scripting
	 */
	public var interp(default, null):Interp;

	/**
	 * Parser for script file info
	 */
	public var parser(default, null):Parser;

	/**
	 * Script name
	 */
	public var script(default, null):String = "";

	/**
	 * Script file name
	 */
	public var scriptFile(default, null):String = "";

	/**
	 * Parsing exception value
	 */
	public var parsingException(default, null):Exception;

	/**
	 * for `destroy` function call
	 */
	@:noPrivateAccess var _destroyed(default, null):Bool;

	/**
	 * Default function name
	 */
	public var defaultFunc:String = null;

	/**
	 * Type check value
	 */
	public var typeCheck:Bool = false;

	/**
	 * Activated?
	 */
	public var active:Bool = true;

	/**
	 * Script will traces in command line?
	 */
	public var traces:Bool = false;

	/**
	 * Script will traces debug stuff?
	 */
	public var debugTraces:Bool = false;

	public function new(?scriptPath:String = "", ?preset:Bool = true, ?startExecute:Bool = true)
	{
		var time = Timer.stamp();

		if (defaultTypeCheck != null)
			typeCheck = defaultTypeCheck;
		if (defaultDebug != null)
			debugTraces = defaultDebug;
		if (defaultFun != null)
			defaultFunc = defaultFun;

		interp = new Interp();
		interp.setScr(this);

		if (defaultImprovedField != null)
			improvedField = defaultImprovedField;
		else
			improvedField = improvedField;

		parser = new Parser();

		presetter = new Preset(this);
		if (preset)
			this.preset();

		for (i => k in globalVariables)
		{
			if (i != null)
				set(i, k, true);
		}

		try
		{
			doFile(scriptPath);
			if (startExecute)
				execute();
			lastReportedTime = Timer.stamp() - time;

			if (debugTraces && scriptPath != null && scriptPath.length > 0)
			{
				if (lastReportedTime == 0)
					trace('File data brewed instantly (0 seconds)');
				else
					trace('File data brewed in ${lastReportedTime} seconds');
			}
		}
		catch (e)
		{
			lastReportedTime = -1;
		}
	}

	/**
	 * This function called for activate this script.
	 		*
	 		* Recommended call this, if you done a setting and calling a classes, functions and variables
	 */
	public function execute():Void
	{
		if (_destroyed || !active)
			return;

		parsingException = null;

		var origin:String =
			{
				if (customOrigin != null && customOrigin.length > 0)
					customOrigin;
				else if (scriptFile != null && scriptFile.length > 0)
					scriptFile;
				else
					"TScript";
			};

		if (script != null && script.length > 0)
		{
			resetInterp();

			function tryHaxe()
			{
				try
				{
					var expr:Expr = parser.parseString(script, origin);
					var r = interp.execute(expr);
					returnValue = r;
				}
				catch (e)
				{
					parsingException = e;
					returnValue = null;
				}

				if (defaultFunc != null)
					call(defaultFunc);
			}

			tryHaxe();
		}
	}

	/**
	 * Setting a variables, functions, classes
	 		*
	 		* For `obj`, and if `key` is variable name, write like this:
	 		*
	 		* ```haxe
	 		* set('object', object)
	 		* ```
	 		*
	 		* For `obj`, and if `key` is class name, write like this:
	 		*
	 		* ```haxe
	 		* set('StringTools', StringTools);
	 		* ```
	 *
	 * For `obj`, and if `key` is function call value, write like this:
	 *
	 * ```haxe
	 * set('function name', function(value:String) {
	 *    trace(value);
	 * });
	 *
	 * /////////////////////////////////////////////
	 *
	 * set('function name', (value:String) -> {
	 *    trace(value);
	 * });
	 * ```
	 		*
	 		* @param key is a name of `variables`, `functions`, `classes`.
	 		* @param obj is a dynamic value of `variables`, `function`, `classes` (upper a examples)
	 		* @param setAsFinal its final?
	 */
	public function set(key:String, ?obj:Dynamic, ?setAsFinal:Bool = false):TScript
	{
		if (_destroyed)
			return null;
		if (!active)
			return this;

		if (key == null || BlankReg.match(key) || !classReg.match(key))
			throw '$key is not a valid class name';
		else if (obj != null && (obj is Class) && notAllowedClasses.contains(obj))
			throw 'Tried to set ${Type.getClassName(obj)} which is not allowed';
		else if (Tools.keys.contains(key))
			throw '$key is a keyword and cannot be replaced';

		function setVar(key:String, obj:Dynamic):Void
		{
			if (setAsFinal)
				interp.finalVariables[key] = obj;
			else
				switch Type.typeof(obj)
				{
					case TFunction | TClass(_) | TEnum(_):
						interp.finalVariables[key] = obj;
					case _:
						interp.variables[key] = obj;
				}
		}

		setVar(key, obj);
		return this;
	}

	/**
	 * Setting a class
	 * @param cl class path
	 */
	public function setClass(cl:Class<Dynamic>):TScript
	{
		if (_destroyed)
			return null;

		if (cl == null)
		{
			if (traces)
			{
				trace('Class cannot be null');
			}

			return null;
		}

		var clName:String = Type.getClassName(cl);
		if (clName != null)
		{
			var splitCl:Array<String> = clName.split('.');
			if (splitCl.length > 1)
			{
				clName = splitCl[splitCl.length - 1];
			}

			set(clName, cl);
		}
		return this;
	}

	/**
	 * Setting a class path
	 * @param cl class path
	 */
	public function setClassString(cl:String):TScript
	{
		if (_destroyed)
			return null;

		if (cl == null || cl.length < 1)
		{
			if (traces)
				trace('Class cannot be null');

			return null;
		}

		var cls:Class<Dynamic> = Type.resolveClass(cl);
		if (cls != null)
		{
			if (cl.split('.').length > 1)
			{
				cl = cl.split('.')[cl.split('.').length - 1];
			}

			set(cl, cls);
		}
		return this;
	}

	/**
	 * Setting a special object
	 * @param obj current object
	 * @param includeFunctions true/false?
	 * @param exclusions write here a exclude objects
	 */
	public function setSpecialObject(obj:Dynamic, ?includeFunctions:Bool = true, ?exclusions:Array<String>):TScript
	{
		if (_destroyed)
			return null;
		if (!active)
			return this;
		if (obj == null)
			return this;
		if (exclusions == null)
			exclusions = new Array();

		var types:Array<Dynamic> = [Int, String, Float, Bool, Array];
		for (i in types)
			if (Std.isOfType(obj, i))
				throw 'Special object cannot be ${i}';

		if (interp.specialObject == null)
			interp.specialObject = {obj: null, includeFunctions: null, exclusions: null};

		interp.specialObject.obj = obj;
		interp.specialObject.exclusions = exclusions.copy();
		interp.specialObject.includeFunctions = includeFunctions;
		return this;
	}

	/**
	 * Returning a local Map (Name and Dynamic value)
	 */
	public function locals():Map<String, Dynamic>
	{
		if (_destroyed)
			return null;

		if (!active)
			return [];

		var newMap:Map<String, Dynamic> = new Map();
		for (i in interp.locals.keys())
		{
			var v = interp.locals[i];
			if (v != null)
				newMap[i] = v.r;
		}
		return newMap;
	}

	/**
	 * Removed a added setted `key` from `set()` function.
	 * @param key current `key`
	 */
	public function unset(key:String):TScript
	{
		if (_destroyed)
			return null;
		if (BlankReg.match(key) || !classReg.match(key))
			return this;
		if (!active)
			return null;

		for (i in [interp.finalVariables, interp.variables])
		{
			if (i.exists(key))
			{
				i.remove(key);
			}
		}

		return this;
	}

	/**
	 * Getted a information of `key`.
	 * @param key current `key`.
	 */
	public function get(key:String):Dynamic
	{
		if (_destroyed)
			return null;
		if (BlankReg.match(key) || !classReg.match(key))
			return null;

		if (!active)
		{
			if (traces)
				trace("This file data is not active!");

			return null;
		}

		var l = locals();
		if (l.exists(key))
			return l[key];

		var r = interp.finalVariables.get(key);
		if (r == null)
			r = interp.variables.get(key);

		return r;
	}

	/**
	 * Added a function for call in script inside.
	    *
	    * Example:
	    * ```haxe
	    * call('update', [elapsed]);
	    * ```
	    *
	    * @param func Function Name
	    * @param args Function arguments
	 */
	public function call(func:String, ?args:Array<Dynamic>):FileData
	{
		if (_destroyed)
			return {
				exceptions: [
					new Exception(new OGException((if (scriptFile != null && scriptFile.length > 0) scriptFile else "instance") + " is destroyed."))
				],
				calledFunction: func,
				succeeded: false,
				returnValue: null,
				lastReportedTime: -1
			};

		if (!active)
			return {
				exceptions: [
					new Exception(new OGException((if (scriptFile != null && scriptFile.length > 0) scriptFile else "instance") + " is not active."))
				],
				calledFunction: func,
				succeeded: false,
				returnValue: null,
				lastReportedTime: -1
			};

		var time:Float = Timer.stamp();

		var scriptFile:String = if (scriptFile != null && scriptFile.length > 0) scriptFile else "";
		var caller:FileData = {
			exceptions: [],
			calledFunction: func,
			succeeded: false,
			returnValue: null,
			lastReportedTime: -1
		}
		#if sys
		if (scriptFile != null && scriptFile.length > 0)
			Reflect.setField(caller, "fileName", scriptFile);
		#end
		if (args == null)
			args = new Array();

		var pushedExceptions:Array<String> = new Array();
		function pushException(e:String)
		{
			if (!pushedExceptions.contains(e))
				caller.exceptions.push(new Exception(new OGException(e)));

			pushedExceptions.push(e);
		}
		if (func == null || BlankReg.match(func) || !classReg.match(func))
		{
			if (traces)
				trace('Function name cannot be invalid for $scriptFile!');

			pushException('Function name cannot be invalid for $scriptFile!');
			return caller;
		}

		var fun = get(func);
		if (exists(func) && Type.typeof(fun) != TFunction)
		{
			if (traces)
				trace('$func is not a function');

			pushException('$func is not a function');
		}
		else if (!exists(func))
		{
			if (traces)
				trace('Function $func does not exist in $scriptFile.');

			if (scriptFile != null && scriptFile.length > 0)
				pushException('Function $func does not exist in $scriptFile.');
			else
				pushException('Function $func does not exist in file data instance.');
		}
		else
		{
			var oldCaller = caller;
			try
			{
				var functionField:Dynamic = Reflect.callMethod(this, fun, args);
				caller = {
					exceptions: caller.exceptions,
					calledFunction: func,
					succeeded: true,
					returnValue: functionField,
					lastReportedTime: -1,
				};
				#if sys
				if (scriptFile != null && scriptFile.length > 0)
					Reflect.setField(caller, "fileName", scriptFile);
				#end
				Reflect.setField(caller, "lastReportedTime", Timer.stamp() - time);
			}
			catch (e)
			{
				caller = oldCaller;
				caller.exceptions.insert(0, new Exception(e));
			}
		}

		return caller;
	}

	/**
	 * Clear this script data's
	 */
	public function clear():TScript
	{
		if (_destroyed)
			return null;
		if (!active)
			return this;

		for (i in interp.variables.keys())
			interp.variables.remove(i);

		for (i in interp.finalVariables.keys())
			interp.finalVariables.remove(i);

		return this;
	}

	/**
	 * Returned a existed `key`.
	 * @param key variable, function, class name
	 */
	public function exists(key:String):Bool
	{
		if (_destroyed)
			return false;
		if (!active)
			return false;
		if (BlankReg.match(key) || !classReg.match(key))
			return false;

		var l = locals();
		if (l.exists(key))
			return l.exists(key);

		for (i in [interp.variables, interp.finalVariables])
		{
			if (i.exists(key))
				return true;
		}
		return false;
	}

	/**
	 * Preset a `set()` variables, function, classes
	 */
	public function preset():Void
	{
		if (_destroyed)
			return;
		if (!active)
			return;

		presetter.preset();
	}

	function resetInterp():Void
	{
		if (_destroyed)
			return;

		interp.locals = #if haxe3 new Map() #else new Hash() #end;
		while (interp.declared.length > 0)
			interp.declared.pop();
		while (interp.pushedVars.length > 0)
			interp.pushedVars.pop();
	}

	function destroyInterp():Void
	{
		if (_destroyed)
			return;

		interp.locals = null;
		interp.variables = null;
		interp.finalVariables = null;
		interp.declared = null;
	}

	function doFile(scriptPath:String):Void
	{
		if (_destroyed)
			return;

		if (scriptPath == null || scriptPath.length < 1 || BlankReg.match(scriptPath))
		{
			ID = IDCount + 1;
			IDCount++;
			global[Std.string(ID)] = this;
			return;
		}

		if (scriptPath != null && scriptPath.length > 0)
		{
			#if sys
			if (FileSystem.exists(scriptPath))
			{
				scriptFile = scriptPath;
				script = File.getContent(scriptPath);
			}
			else
			{
				scriptFile = "";
				script = scriptPath;
			}
			#else
			scriptFile = "";
			script = scriptPath;
			#end

			if (scriptFile != null && scriptFile.length > 0)
				global[scriptFile] = this;
			else if (script != null && script.length > 0)
				global[script] = this;
		}
	}

	/**
	 * Doing a string
	 * @param string current string value
	 * @param origin originally string value
	 */
	public function doString(string:String, ?origin:String):TScript
	{
		if (_destroyed)
			return null;
		if (!active)
			return null;
		if (string == null || string.length < 1 || BlankReg.match(string))
			return this;

		parsingException = null;

		var time = Timer.stamp();
		try
		{
			#if sys
			if (FileSystem.exists(string.trim()))
				string = string.trim();

			if (FileSystem.exists(string))
			{
				scriptFile = string;
				origin = string;
				string = File.getContent(string);
			}
			#end

			var og:String = origin;
			if (og != null && og.length > 0)
				customOrigin = og;
			if (og == null || og.length < 1)
				og = customOrigin;
			if (og == null || og.length < 1)
				og = "TScript";

			resetInterp();

			script = string;

			if (scriptFile != null && scriptFile.length > 0)
			{
				if (ID != null)
					global.remove(Std.string(ID));
				global[scriptFile] = this;
			}
			else if (script != null && script.length > 0)
			{
				if (ID != null)
					global.remove(Std.string(ID));
				global[script] = this;
			}

			function tryHaxe()
			{
				try
				{
					var expr:Expr = parser.parseString(script, og);
					var r = interp.execute(expr);
					returnValue = r;
				}
				catch (e)
				{
					parsingException = e;
					returnValue = null;
				}

				if (defaultFunc != null)
					call(defaultFunc);
			}

			tryHaxe();

			lastReportedTime = Timer.stamp() - time;

			if (debugTraces)
			{
				if (lastReportedTime == 0)
					trace('File data instance brewed instantly (0s)');
				else
					trace('File data instance brewed in ${lastReportedTime}s');
			}
		}
		catch (e)
			lastReportedTime = -1;

		return this;
	}

	inline function toString():String
	{
		if (_destroyed)
			return "null";

		if (scriptFile != null && scriptFile.length > 0)
			return scriptFile;

		return "File data";
	}

	/**
	 * File list
	 * @param path file folder path.
	 * @param extensions file extenions (if this null, automatically getted a `hx` extension)
	 */
	public static function listScripts(path:String, ?extensions:Array<String>):Array<TScript>
	{
		if (!path.endsWith('/'))
			path += '/';

		if (extensions == null || extensions.length < 1)
			extensions = ['hx'];

		var list:Array<TScript> = [];
		#if sys
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var files:Array<String> = FileSystem.readDirectory(path);
			for (i in files)
			{
				var hasExtension:Bool = false;
				for (l in extensions)
				{
					if (i.endsWith(l))
					{
						hasExtension = true;
						break;
					}
				}
				if (hasExtension && FileSystem.exists(path + i))
					list.push(new TScript(path + i));
			}
		}
		#end

		return list;
	}

	/**
	 * Destroying all variables of this script.
	 */
	public function destroy():Void
	{
		if (_destroyed)
			return;

		if (global.exists(scriptFile) && scriptFile != null && scriptFile.length > 0)
			global.remove(scriptFile);
		else if (global.exists(script) && script != null && script.length > 0)
			global.remove(script);
		if (global.exists(Std.string(ID)))
			global.remove(script);

		if (classPath != null && classPath.length > 0)
		{
			Interp.classes.remove(classPath);
			Interp.STATICPACKAGES[classPath] = null;
			Interp.STATICPACKAGES.remove(classPath);
		}

		for (i in interp.pushedClasses)
		{
			Interp.classes.remove(i);
			Interp.STATICPACKAGES[i] = null;
			Interp.STATICPACKAGES.remove(i);
		}

		for (i in interp.pushedAbs)
		{
			Interp.eabstracts.remove(i);
			Interp.EABSTRACTS[i].base = null;
			Interp.EABSTRACTS[i].fileName = null;
			Interp.EABSTRACTS.remove(i);
		}

		for (i in interp.pushedVars)
		{
			if (globalVariables.exists(i))
				globalVariables.remove(i);
		}

		presetter.destroy();

		clear();
		resetInterp();
		destroyInterp();

		parsingException = null;
		customOrigin = null;
		parser = null;
		interp = null;
		script = null;
		scriptFile = null;
		active = false;
		improvedField = null;
		notAllowedClasses = null;
		lastReportedTime = -1;
		ID = null;
		returnValue = null;
		_destroyed = true;
	}

	function setClassPath(p):String
	{
		if (_destroyed)
			return null;

		return classPath = p;
	}

	function setPackagePath(p):String
	{
		if (_destroyed)
			return null;

		return packagePath = p;
	}
}
