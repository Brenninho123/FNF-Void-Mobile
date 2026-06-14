package mobile;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.BaseScaleMode;

class MobileScaleMode extends BaseScaleMode
{
	override public function onMeasure(width:Int, height:Int):Void
	{
		var ratioX:Float = width / FlxG.width;
		var ratioY:Float = height / FlxG.height;

		deviceSize.set(width, height);
		gameSize.set(width, height);

		scale.x = ratioX;
		scale.y = ratioY;

		offset.x = 0;
		offset.y = 0;
	}
}
