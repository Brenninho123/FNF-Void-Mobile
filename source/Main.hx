package;

import lime.app.Application;
#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import mobile.StorageUtil;
#if mobile
import mobile.MobileScaleMode;
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = TitleState;
	var framerate:Int = 120;
	var skipSplash:Bool = true;
	var startFullscreen:Bool = false;

	public static var watermarks:Bool = true;

	#if cpp
	public static var webmHandler:Dynamic = null;
	#end

	var game:FlxGame;
	var fpsCounter:FPS;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
			UncaughtErrorEvent.UNCAUGHT_ERROR,
			onUncaughtError
		);

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopImmediatePropagation();

		var msg:String = "Unknown error";
		try
		{
			msg = Std.string(e.error);
		}
		catch (ex:Dynamic) {}

		var timestamp:String = Date.now().toString().split(":").join("-").split(" ").join("_");
		var crashPath:String = "crash_logs/crash_" + timestamp + ".txt";
		StorageUtil.writeText(crashPath, "CRASH REPORT\n" + Date.now().toString() + "\n\n" + msg);

		#if mobile
		try
		{
			FlxG.switchState(new CrashState(msg));
		}
		catch (ex:Dynamic)
		{
			openfl.system.System.exit(0);
		}
		#else
		Sys.exit(1);
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

	private function setupGame():Void
	{
		#if (cpp && !mobile)
		initialState = Caching;
		#end

		try
		{
			game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
			addChild(game);
		}
		catch (e:Dynamic)
		{
			openfl.system.System.exit(0);
			return;
		}

		#if mobile
		try
		{
			FlxG.scaleMode = new MobileScaleMode();
		}
		catch (e:Dynamic) {}
		#end

		#if desktop
		try
		{
			DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode) { DiscordClient.shutdown(); });
		}
		catch (e:Dynamic) {}
		#end

		try
		{
			fpsCounter = new FPS(10, 3, 0xFFFFFF);
			addChild(fpsCounter);
			var fpsEnabled:Bool = FlxG.save.data.fps != null ? FlxG.save.data.fps : true;
			toggleFPS(fpsEnabled);
		}
		catch (e:Dynamic) {}
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		if (fpsCounter != null)
			fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor):Void
	{
		if (fpsCounter != null)
			fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float):Void
	{
		Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter != null ? fpsCounter.currentFPS : 0;
	}
}
