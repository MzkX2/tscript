package tscript.base;

#if (!macro && !DISABLED_MACRO_SUPERLATIVE)
@:access(tscript.base.Tools)
#end
@:access(tscript.base.EAbstract)
class Error {
	/**
	 * Error type.
	 */
	public var e:ErrorDef;

	/**
	 * This `Expr` pmin value.
	 */
	public var pmin:Int;

	/**
	 * This `Expr` pmax value.
	 */
	public var pmax:Int;

	/**
	 * Error origin.
	 */
	public var origin:String;

	/**
	 * Line, where this error pushed.
	 */
	public var line:Int;

	/**
	 * Current error argument.
	 */
	public var currentArg:String;

	/**
	 * Creating a `Error` values.
	 * @param e `Errordef` type.
	 * @param pmin `Expr` pmin value.
	 * @param pmax `Expr` pmax value.
	 * @param origin Origin error
	 * @param line Line, where error pushed.
	 * @param currentArg Current error argument.
	 */
	public function new(e, pmin, pmax, origin, line, ?currentArg) {
		this.e = e;
		this.pmin = pmin;
		this.pmax = pmax;
		this.origin = origin;
		this.line = line;
		this.currentArg = currentArg;
	}

	/**
	 * Returned a error message to `String`.
	 */
	public function toString():String {
		var message:String = switch (e) {
			case ENullObjectReference: "Null Object Reference.";
			case ETypeName: "Type name should start with an uppercase letter.";
			case EDuplicate(v): 'Duplicate class field declaration ($v).';
			case EInvalidChar(c): 'Invalid character: \'${StringTools.isEof(c) ? "EOF" : String.fromCharCode(c)}\' ($c)';
			case EUnexpected(s): 'Unexpected $s';
			case EFunctionAssign(f): 'Cannot rebind this method! ($f)';
			case EUnterminatedString: "Unterminated String!";
			case EUnterminatedComment: "Unterminated Comment!";
			case EInvalidPreprocessor(msg): 'Invalid preprocessor ($msg)';
			case EUnknownVariable(v): 'Unknown variable: $v';
			case EInvalidIterator(v): 'Invalid iterator: $v';
			case EInvalidOp(op): 'Invalid operator: $op';
			case EInvalidAccess(f): 'Invalid access to field: $f';
			case EInvalidAssign: "Invalid Assign!";
			case ETypeNotFound(t):
				var str:String = "Type not found: " + t;

				#if (!macro && !DISABLED_MACRO_SUPERLATIVE)
				meanPush(t, str);
				#end

				str;
			case EWriting: "This expression cannot be accessed for writing!";
			case EUnmatchingType(v, t, varn): '$t should be $v${(varn != null ? ' for variable "$varn".' : '.')}';
			case ECustom(msg): msg;
			case EInvalidFinal(v): 'This expression cannot be accessed for writing! $v';
			case EDoNotHaveField(cl, f): '$cl has no field $f!';
			case EAbstractField(abs, f): 'Abstract<${abs.name}> has no field $f!';
			case EUnexistingField(f, f2): '$f2 has no field $f!';
			case EPrivateField(f): 'Cannot access private field $f';
			case EUnknownIdentifier(s): 'Unknown Identifier: $s.';
			case EUpperCase: "Package name cannot have capital letters!";
			case ECannotUseAbs: "Cannot use abstract as value!";
			case EAlreadyModule(m, fileName) | EMultipleDecl(m, fileName):
				var str:String = '${(Type.enumEq(e, EMultipleDecl(m, fileName)) ? 'Multiple class declaration: $m' : 'Name "$m" is already defined in this module!')}';
				if (fileName != null) {
					str += "\n" + fileName;
					var str2:String = "";
					for (i in 0...fileName.length)
						str2 += "^";
					str += "\n" + str2 + " Previous declaration here.";
				}

				str;
			case ESuper: "Cannot use 'super' as value!";
		};

		var str:String = '$origin:$line: $message';
		return str;
	}

	#if (!macro && !DISABLED_MACRO_SUPERLATIVE)
	public static function meanPush(leSplit:String, str:String):String {
		var split:Array<String> = leSplit.split('.');
		var similarNames:Array<Array<Dynamic>> = [];
		var allNames:Array<String> = Tools.allNamesAvailable;

		for (i in allNames) {
			var same:Int = 0;
			var names:Array<String> = i.split('.');

			for (i in 0...names.length) {
				var nameSplit:Array<String> = try names[i].split('') catch (e) [];
				var splitSplit:Array<String> = try split[i].split('') catch (e) [];
				var length:Int = nameSplit.length;

				if (splitSplit.length < nameSplit.length)
					length = splitSplit.length;
				for (i in 0...length)
					if (nameSplit[i] == splitSplit[i] && nameSplit[i] != '')
						same++;
			}

			if (same > 0)
				similarNames.push([same, i]);
		}

		if (similarNames.length > 0) {
			var num:Int = 0;
			var biggest:Array<Dynamic> = [];

			for (i in similarNames) {
				if (i[0] > num || (i[0] == num && biggest[1].length < num)) {
					num = i[0];
					biggest = i;
				}
			}

			str += '\nDid you mean ? ${biggest[1]}';
		}

		return str;
	}
	#end
}

enum ErrorDef {
	ENullObjectReference;
	ETypeName;
	EDuplicate(v:String);
	EInvalidChar(c:Int);
	EUnexpected(s:String);
	EFunctionAssign(f:String);
	EUnterminatedString;
	EUnterminatedComment;
	EInvalidPreprocessor(msg:String);
	EUnknownVariable(v:String);
	EInvalidIterator(v:String);
	EInvalidOp(op:String);
	EInvalidAccess(f:String);
	EInvalidAssign;
	ETypeNotFound(t:String);
	EWriting;
	EUnmatchingType(v:String, t:String, ?varn:String);
	ECustom(msg:String);
	EInvalidFinal(?v:String);
	EDoNotHaveField(cl:EClass, f:String);
	EAbstractField(abs:EAbstract, f:String);
	EUnexistingField(f:Dynamic, f2:Dynamic);
	EPrivateField(f:String);
	EUnknownIdentifier(s:String);
	EUpperCase;
	ECannotUseAbs;
	EAlreadyModule(m:String, ?fileName:String);
	EMultipleDecl(cl:String, ?fileName:String);
	ESuper;
}
