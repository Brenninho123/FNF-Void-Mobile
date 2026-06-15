package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class CrashState extends FlxState
{
	var errorMsg:String;

	public function new(msg:String)
	{
		super();
		errorMsg = msg;
	}

	override function create()
	{
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var title = new FlxText(20, 40, FlxG.width - 40, "CRASH", 32);
		title.color = FlxColor.RED;
		title.alignment = CENTER;
		add(title);

		var msg = new FlxText(20, 100, FlxG.width - 40, errorMsg, 18);
		msg.color = FlxColor.WHITE;
		msg.wordWrap = true;
		add(msg);

		var hint = new FlxText(20, FlxG.height - 60, FlxG.width - 40, "Tap anywhere to close", 20);
		hint.color = FlxColor.fromRGB(180, 180, 180);
		hint.alignment = CENTER;
		add(hint);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				openfl.system.System.exit(0);
		#else
		if (FlxG.keys.anyJustPressed([ANY]))
			Sys.exit(0);
		#end
	}
}
