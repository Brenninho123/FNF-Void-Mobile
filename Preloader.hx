package;

import flixel.system.FlxBasePreloader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.Lib;

@:bitmap("art/preloaderArt.png") class LogoImage extends BitmapData {}

class Preloader extends FlxBasePreloader
{
	static inline var BASE_WIDTH:Float = 1280;
	static inline var GROW_THRESHOLD:Float = 69;
	static inline var GROW_AMOUNT:Float = 0.5;

	var logo:Sprite;
	var percentText:TextField;
	var baseScale:Float = 1;

	public function new(MinDisplayTime:Float = 3, ?AllowedURLs:Array<String>)
	{
		super(MinDisplayTime, AllowedURLs);
	}

	override function create():Void
	{
		_width = Lib.current.stage.stageWidth;
		_height = Lib.current.stage.stageHeight;

		Lib.current.stage.addEventListener(Event.RESIZE, onStageResize);

		recalculateBaseScale();

		logo = new Sprite();
		logo.addChild(new Bitmap(new LogoImage(0, 0)));
		logo.scaleX = logo.scaleY = baseScale;
		addChild(logo);

		percentText = new TextField();
		percentText.selectable = false;
		percentText.mouseEnabled = false;
		percentText.autoSize = TextFieldAutoSize.CENTER;
		percentText.defaultTextFormat = new TextFormat(null, 16, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER);
		percentText.text = "0%";
		addChild(percentText);

		layoutElements();

		super.create();
	}

	function recalculateBaseScale():Void
	{
		baseScale = _width > 0 ? (_width / BASE_WIDTH) : 1;
		if (baseScale <= 0)
			baseScale = 1;
	}

	function layoutElements():Void
	{
		if (logo != null)
		{
			logo.x = (_width / 2) - (logo.width / 2);
			logo.y = (_height / 2) - (logo.height / 2);
		}

		if (percentText != null)
		{
			var anchorY:Float = logo != null ? (logo.y + logo.height) : (_height / 2);
			percentText.x = (_width / 2) - (percentText.width / 2);
			percentText.y = anchorY + 12;
		}
	}

	function onStageResize(e:Event):Void
	{
		_width = Lib.current.stage.stageWidth;
		_height = Lib.current.stage.stageHeight;
		recalculateBaseScale();
		if (logo != null)
			logo.scaleX = logo.scaleY = baseScale;
		layoutElements();
	}

	override function update(Percent:Float):Void
	{
		var clamped:Float = Percent < 0 ? 0 : (Percent > 100 ? 100 : Percent);

		if (logo != null)
		{
			if (clamped < GROW_THRESHOLD)
			{
				var eased:Float = easeOutQuad(clamped / GROW_THRESHOLD);
				var scale:Float = baseScale * (1 + eased * GROW_AMOUNT);
				logo.scaleX = logo.scaleY = scale;
			}
			else
			{
				logo.scaleX = logo.scaleY = baseScale;
			}
		}

		layoutElements();

		if (percentText != null)
			percentText.text = Std.int(clamped) + "%";

		super.update(clamped);
	}

	inline function easeOutQuad(t:Float):Float
	{
		return 1 - (1 - t) * (1 - t);
	}
}
