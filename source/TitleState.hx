package;

#if sys
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

#if desktop
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var kadelogo:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		#if sys
		#if mobile
		var replaysPath = lime.system.System.applicationStorageDirectory + "replays";
		#else
		var replaysPath = Sys.getCwd() + "/assets/replays";
		#end
		if (!sys.FileSystem.exists(replaysPath))
			sys.FileSystem.createDirectory(replaysPath);
		#end

		@:privateAccess
		{
			var loaded = openfl.Assets.getLibrary("default").assetsLoaded;
		}

		#if !cpp
		FlxG.save.bind('funkin', 'ninjamuffin99');
		PlayerSettings.init();
		KadeEngineData.initSave();
		#end

		Highscore.load();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		startIntro();
		#end
		#end
	}

	var logoBl:FlxSprite;
	var titleBG:FlxSprite;
	var gfDance:FlxSprite;
	var titleVoid:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		titleBG = new FlxSprite(0, 1300).loadGraphic(Paths.image('titleBG'));
		if (FlxG.save.data.antialiasing)
			titleBG.antialiasing = true;
		titleBG.updateHitbox();
		add(titleBG);

		logoBl = new FlxSprite(-80, 30);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.9));
		if (FlxG.save.data.antialiasing)
			logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 30, false);
		logoBl.updateHitbox();

		titleVoid = new FlxSprite(540, -20);
		titleVoid.frames = Paths.getSparrowAtlas('titleVoid' + FlxG.random.int(1, 5));
		titleVoid.setGraphicSize(Std.int(titleVoid.width * 0.87));
		titleVoid.animation.addByPrefix('bop', 'void bumpin', 24, false);
		if (FlxG.save.data.antialiasing)
			titleVoid.antialiasing = true;
		add(titleVoid);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		if (FlxG.save.data.antialiasing)
			titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		kadelogo = new FlxSprite(0, FlxG.height * 0.32).loadGraphic(Paths.image('KadeEngineLogo'));
		add(kadelogo);
		kadelogo.visible = false;
		kadelogo.setGraphicSize(Std.int(kadelogo.width * 0.7));
		kadelogo.updateHitbox();
		kadelogo.screenCenter(X);
		if (FlxG.save.data.antialiasing)
			kadelogo.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		#if !mobile
		FlxG.mouse.visible = false;
		#end

		if (initialized)
		{
			skipIntro();
		}
		else
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(3.7, 0, 0.7);
			Conductor.changeBPM(120);
			initialized = true;
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		#if !mobile
		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
		#end

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
				var returnedData:Array<String> = [];

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);
					FlxG.switchState(new MainMenuState());
				}

				http.onError = function(error)
				{
					FlxG.switchState(new MainMenuState());
				}

				http.request();
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function createCoolTextKE(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 150;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		titleVoid.animation.play('bop', true);

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['created by', 'StarbreakMusic']);
			case 2:
				addMoreText('somehow');
			case 4:
				deleteCoolText();
			case 5:
				createCoolTextKE(['Made in']);
			case 7:
				kadelogo.visible = true;
			case 8:
				deleteCoolText();
				kadelogo.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
				kadelogo.visible = false;
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('FNF');
			case 14:
				addMoreText('Vs Void');
			case 15:
				addMoreText('Lets get it');
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(kadelogo);

			FlxG.camera.flash(FlxColor.WHITE, 3.4);
			remove(credGroup);

			FlxTween.tween(titleBG, {y: 0}, 2.8, {ease: FlxEase.expoOut});
			FlxTween.tween(logoBl, {y: -80}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);

			skippedIntro = true;
		}
	}
}
