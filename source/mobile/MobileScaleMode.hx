package mobile;

import flixel.FlxG;
import openfl.display.StageScaleMode;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.scaleModes.BaseScaleMode;

class MobileScaleMode extends BaseScaleMode
{
	override public function onMeasure(width:Int, height:Int):Void
	{
		var ratioX:Float = width / FlxG.width;
		var ratioY:Float = height / FlxG.height;
		var ratio:Float = Math.min(ratioX, ratioY);

		deviceSize.set(width, height);
		gameSize.set(Math.ceil(ratio * FlxG.width), Math.ceil(ratio * FlxG.height));

		FlxG.scaleMode = this;

		gameSize.x = width;
		gameSize.y = height;

		offset.x = 0;
		offset.y = 0;

		scale.x = gameSize.x / FlxG.width;
		scale.y = gameSize.y / FlxG.height;

		FlxG.game.scaleX = scale.x;
		FlxG.game.scaleY = scale.y;
	}
}
