package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Hitbox extends FlxGroup
{
	public var buttonLeft:FlxSprite;
	public var buttonDown:FlxSprite;
	public var buttonUp:FlxSprite;
	public var buttonRight:FlxSprite;

	public var trackedInputsLeft:Array<Int> = [];
	public var trackedInputsDown:Array<Int> = [];
	public var trackedInputsUp:Array<Int> = [];
	public var trackedInputsRight:Array<Int> = [];

	public var isLeft:Bool = false;
	public var isDown:Bool = false;
	public var isUp:Bool = false;
	public var isRight:Bool = false;

	public function new()
	{
		super();

		buttonLeft = makeButton(0, FlxColor.fromRGB(148, 0, 211, 90));
		buttonDown = makeButton(1, FlxColor.fromRGB(0, 0, 228, 90));
		buttonUp = makeButton(2, FlxColor.fromRGB(0, 200, 0, 90));
		buttonRight = makeButton(3, FlxColor.fromRGB(228, 0, 0, 90));

		add(buttonLeft);
		add(buttonDown);
		add(buttonUp);
		add(buttonRight);
	}

	function makeButton(index:Int, color:FlxColor):FlxSprite
	{
		var btn = new FlxSprite();
		var btnW = Std.int(FlxG.width / 4);
		var btnH = FlxG.height;
		btn.makeGraphic(btnW, btnH, FlxColor.TRANSPARENT);
		btn.x = btnW * index;
		btn.y = 0;
		btn.alpha = 0;
		btn.scrollFactor.set();
		return btn;
	}

	override public function update(elapsed:Float)
	{
		isLeft = false;
		isDown = false;
		isUp = false;
		isRight = false;

		trackedInputsLeft = [];
		trackedInputsDown = [];
		trackedInputsUp = [];
		trackedInputsRight = [];

		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				var tx = touch.screenX;
				var zoneW = FlxG.width / 4;

				if (tx < zoneW)
				{
					isLeft = true;
					trackedInputsLeft.push(touch.touchPointID);
				}
				else if (tx < zoneW * 2)
				{
					isDown = true;
					trackedInputsDown.push(touch.touchPointID);
				}
				else if (tx < zoneW * 3)
				{
					isUp = true;
					trackedInputsUp.push(touch.touchPointID);
				}
				else
				{
					isRight = true;
					trackedInputsRight.push(touch.touchPointID);
				}
			}
		}

		updateButtonAlpha(buttonLeft, isLeft);
		updateButtonAlpha(buttonDown, isDown);
		updateButtonAlpha(buttonUp, isUp);
		updateButtonAlpha(buttonRight, isRight);

		super.update(elapsed);
	}

	function updateButtonAlpha(btn:FlxSprite, pressed:Bool)
	{
		btn.alpha = pressed ? 0.3 : 0;
	}

	public function isJustPressed(data:Int):Bool
	{
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				var tx = touch.screenX;
				var zoneW = FlxG.width / 4;
				var zone = Std.int(tx / zoneW);
				if (zone == data)
					return true;
			}
		}
		return false;
	}

	public function isJustReleased(data:Int):Bool
	{
		for (touch in FlxG.touches.list)
		{
			if (touch.justReleased)
			{
				var tx = touch.screenX;
				var zoneW = FlxG.width / 4;
				var zone = Std.int(tx / zoneW);
				if (zone == data)
					return true;
			}
		}
		return false;
	}

	public function isHeld(data:Int):Bool
	{
		return switch (data)
		{
			case 0: isLeft;
			case 1: isDown;
			case 2: isUp;
			case 3: isRight;
			default: false;
		};
	}
}
