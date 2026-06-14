package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			#if desktop
			new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated."),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
		]),
		new OptionCategory("Appearance", [
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
		]),
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input on the score screen."),
			new Optimization("No characters or backgrounds. Just a usual rhythm game layout."),
			new GraphicLoading("On startup, cache every character. (HIGH MEMORY)"),
			new BotPlay("Showcase your charts and mods with autoplay.")
		]),
		new OptionCategory("Saves and Data", [
			#if desktop
			new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		]),
		#if mobile
		new OptionCategory("Mobile Options", [
			new HitboxOption("Toggle the touch hitbox zones for note input."),
			new VSliceControlsOption("Toggle V-Slice style swipe controls.")
		])
		#end
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	#if mobile
	var touchStartY:Float = 0;
	var touchMoved:Bool = false;
	#end

	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		if (FlxG.save.data.antialiasing) menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic(Std.int(versionShit.width + 900), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);
		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		#if mobile
		var backHint:FlxText = new FlxText(0, 0, 0, "B", 28);
		backHint.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		backHint.scrollFactor.set();
		backHint.x = FlxG.width - backHint.width - 10;
		backHint.y = FlxG.height - backHint.height - 10;
		add(backHint);
		#end

		super.create();
	}

	var isCat:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					touchStartY = touch.screenY;
					touchMoved = false;

					var backZoneX = FlxG.width - 80;
					var backZoneY = FlxG.height - 80;
					if (touch.screenX >= backZoneX && touch.screenY >= backZoneY)
					{
						if (!isCat)
						{
							FlxG.switchState(new MainMenuState());
						}
						else
						{
							isCat = false;
							grpControls.clear();
							for (i in 0...options.length)
							{
								var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
								controlLabel.isMenuItem = true;
								controlLabel.targetY = i;
								grpControls.add(controlLabel);
							}
							curSelected = 0;
							changeSelection(curSelected);
						}
						return;
					}
				}

				if (touch.pressed)
				{
					var delta = touch.screenY - touchStartY;
					if (Math.abs(delta) > 20)
						touchMoved = true;
				}

				if (touch.justReleased)
				{
					var delta = touch.screenY - touchStartY;
					if (touchMoved)
					{
						if (delta < -20) changeSelection(-1);
						else if (delta > 20) changeSelection(1);
					}
					else
					{
						if (isCat)
						{
							if (currentSelectedCat.getOptions()[curSelected].press())
								grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						}
						else
						{
							currentSelectedCat = options[curSelected];
							isCat = true;
							grpControls.clear();
							for (i in 0...currentSelectedCat.getOptions().length)
							{
								var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
								controlLabel.isMenuItem = true;
								controlLabel.targetY = i;
								grpControls.add(controlLabel);
							}
							curSelected = 0;
							changeSelection();
						}
					}
				}
			}
			#end

			#if !mobile
			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
				}
				curSelected = 0;
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP) { FlxG.sound.play(Paths.sound('scrollMenu')); changeSelection(-1); }
				if (gamepad.justPressed.DPAD_DOWN) { FlxG.sound.play(Paths.sound('scrollMenu')); changeSelection(1); }
			}

			if (FlxG.keys.justPressed.UP) changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN) changeSelection(1);

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT) currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.pressed.LEFT) currentSelectedCat.getOptions()[curSelected].left();
					}
					else
					{
						if (FlxG.keys.justPressed.RIGHT) currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT) currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT) FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT) FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT) FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT) FlxG.save.data.offset -= 0.1;

					versionShit.text = "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - " + currentDescription;
				else
					versionShit.text = "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT) FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT) FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT) FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT) FlxG.save.data.offset -= 0.1;

				versionShit.text = "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription;
			}

			if (controls.RESET) FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
					}
					curSelected = 0;
					changeSelection();
				}
			}
			#end
		}

		FlxG.save.flush();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;
		if (curSelected < 0) curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length) curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";

		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - " + currentDescription;
			else
				versionShit.text = "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription;
		}
		else
			versionShit.text = "Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - " + currentDescription;

		var bullShit:Int = 0;
		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
	}
}

class HitboxOption extends Option
{
	public function new(desc:String = "")
	{
		super();
		description = desc;
		acceptValues = true;
		if (FlxG.save.data.hitboxMode == null)
			FlxG.save.data.hitboxMode = true;
	}

	private override function updateDisplay():String
		return "Hitbox Mode: " + (FlxG.save.data.hitboxMode ? "ON" : "OFF");

	public override function press():Bool
	{
		FlxG.save.data.hitboxMode = !FlxG.save.data.hitboxMode;
		display = updateDisplay();
		return true;
	}
}

class VSliceControlsOption extends Option
{
	public function new(desc:String = "")
	{
		super();
		description = desc;
		acceptValues = true;
		if (FlxG.save.data.vsliceControls == null)
			FlxG.save.data.vsliceControls = false;
	}

	private override function updateDisplay():String
		return "V Slice Controls: " + (FlxG.save.data.vsliceControls ? "ON" : "OFF");

	public override function press():Bool
	{
		FlxG.save.data.vsliceControls = !FlxG.save.data.vsliceControls;
		display = updateDisplay();
		return true;
	}
}
