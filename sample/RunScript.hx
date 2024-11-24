package;

import tscript.TScript;

class RunScript
{
	static function main():Void
	{
		var script = new TScript('test.hxc');
		script.call('onCreate');
		script.execute();
	}
}
