package tscript.backend;

import haxe.Exception as OGException;

abstract Exception(OGException) {
	/**
	 * Exception message.
	 */
	public var msg(get, never):String;

	/**
	 * Creating a exception
	 * @param exception Original Exception data (`haxe.Exception`)
	 */
	public function new(exception:OGException)
		this = exception;

	/**
	 * Created a exception from original exception (`haxe.Exception`)
	 * @param exception Original Exception data
	 */
	@:from public static function fromException(exception:OGException):Exception
		return new Exception(exception);

	/**
	 * Returned a exception description.
	 */
	@:to public function toString():String
		return msg;

	/**
	 * Detailed exception description.
	 *
	 * Includes message, stuck and the chain of previous exceptions (if set).
	 */
	public function details():String
		return this.details();

	function get_msg():String
		return this.message;

	function toException():OGException
		return this;
}
