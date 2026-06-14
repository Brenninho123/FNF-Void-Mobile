package;

import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if desktop
import Discord.DiscordClient;
#end
#if desktop
import Sys;
import sys.FileSystem;
#end
#if mobile
import mobile.Hitbox;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if desktop
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true;
	var idleBeat:Int = 2;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var spaceBGflash:FlxSprite;
	var holoBoppers:FlxSprite;
	var spacestage:FlxSprite;
	var spacestageAlt:FlxSprite;
	var darkSpaceBG:FlxSprite;
	var bgBreak:FlxSprite;
	var holoEmpty:FlxSprite;
	var holoEmptyAlt:FlxSprite;
	var holoEmptyV:FlxSprite;
	var holoBroken:FlxSprite;
	var oblivionDark1:FlxSprite;
	var oblivionDark2:FlxSprite;
	var oblivionDark3:FlxSprite;
	var bgGlitch:FlxSprite;
	var neoBoppin:FlxSprite;
	var specialAnim:FlxSprite;
	var camTint:FlxSprite;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	private var triggeredAlready:Bool = false;

	private var allowedToHeadbang:Bool = false;

	public static var songOffset:Float = 0;

	private var botPlayState:FlxText;
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis();

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	#if mobile
	var hitbox:Hitbox;
	#end

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		if (curSong != SONG.song)
		{
			if (curSong == 'gravity')
			{
				dad = new Character(dad.x, dad.y, 'hurt-void');
				add(dad);
				remove(dad);

				dad = new Character(dad.x, dad.y, 'darkcrazed-void');
				add(dad);
				remove(dad);

				dad = new Character(dad.x, dad.y, 'crazed-void');
				add(dad);
				remove(dad);
			}
		}

		#if !mobile
		FlxG.mouse.visible = false;
		#end
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		removedVideo = false;

		#if desktop
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false;
		#end

		#if desktop
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		detailsPausedText = "Paused - " + detailsText;

		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			if (type == "BPM Change")
			{
				var beat:Float = pos;
				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, value, endBeat, 0);

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name, pos, value, type));
		}

		SONG.eventObjects = convertedStuff;

		switch (songLowercase)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = ['HEY!', "You think you can just sing\nwith my daughter like that?", "If you want to date her...", "You're going to have to go \nthrough ME first!"];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = ["gah you think you're hot stuff?", "If you can beat me here...", "Only then I will even CONSIDER letting you\ndate my daughter!"];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
			case 'asteroids':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/asteroids/asteroidsDialogue'));
			case 'weightless':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/weightless/weightlessDialogue'));
			case 'event-horizon':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/event-horizon/event-horizonDialogue'));
			case 'ultraviolet':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/ultraviolet/ultravioletDialogue'));
			case 'gravity':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/gravity/gravityDialogue'));
			case 'singularity':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/singularity/singularityDialogue'));
		}

		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2: stageCheck = 'halloween';
				case 3: stageCheck = 'philly';
				case 4: stageCheck = 'limo';
				case 5: stageCheck = (songLowercase == 'winter-horrorland') ? 'mallEvil' : 'mall';
				case 6: stageCheck = (songLowercase == 'thorns') ? 'schoolEvil' : 'school';
				case 7: stageCheck = 'space';
				case 8: stageCheck = (songLowercase == 'singularity') ? 'oblivion' : 'darkSpace';
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				case 'halloween':
					curStage = 'spooky';
					halloweenLevel = true;
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');
					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					if (FlxG.save.data.antialiasing) halloweenBG.antialiasing = true;
					add(halloweenBG);
					isHalloween = true;

				case 'philly':
					curStage = 'philly';
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);
					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);
					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions) add(phillyCityLights);
					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						if (FlxG.save.data.antialiasing) light.antialiasing = true;
						phillyCityLights.add(light);
					}
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);
					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					if (FlxG.save.data.distractions) add(phillyTrain);
					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(trainSound);
					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					add(street);

				case 'limo':
					curStage = 'limo';
					defaultCamZoom = 0.90;
					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);
					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
					if (FlxG.save.data.distractions)
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);
						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}
					}
					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');
					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					if (FlxG.save.data.antialiasing) limo.antialiasing = true;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));

				case 'mall':
					curStage = 'mall';
					defaultCamZoom = 0.80;
					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					if (FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);
					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					if (FlxG.save.data.antialiasing) upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.distractions) add(upperBoppers);
					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					if (FlxG.save.data.antialiasing) bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					if (FlxG.save.data.antialiasing) tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);
					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					if (FlxG.save.data.antialiasing) bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.distractions) add(bottomBoppers);
					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					if (FlxG.save.data.antialiasing) fgSnow.antialiasing = true;
					add(fgSnow);
					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					if (FlxG.save.data.antialiasing) santa.antialiasing = true;
					if (FlxG.save.data.distractions) add(santa);

				case 'mallEvil':
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					if (FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);
					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					if (FlxG.save.data.antialiasing) evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);
					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					if (FlxG.save.data.antialiasing) evilSnow.antialiasing = true;
					add(evilSnow);

				case 'school':
					curStage = 'school';
					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);
					var repositionShit = -200;
					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);
					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);
					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);
					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);
					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);
					var widShit = Std.int(bgSky.width * 6);
					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);
					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);
					if (songLowercase == 'roses' && FlxG.save.data.distractions) bgGirls.getScared();
					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.distractions) add(bgGirls);

				case 'schoolEvil':
					curStage = 'schoolEvil';
					var posX = 400;
					var posY = 200;
					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

				default:
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					if (FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);
					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					if (FlxG.save.data.antialiasing) stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);
					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					if (FlxG.save.data.antialiasing) stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);
			}
		}

		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4: gfCheck = 'gf-car';
				case 5: gfCheck = 'gf-christmas';
				case 6: gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-car': curGf = 'gf-car';
			case 'gf-christmas': curGf = 'gf-christmas';
			case 'gf-pixel': curGf = 'gf-pixel';
			case 'gf-night': curGf = 'gf-night';
			default: curGf = 'gf';
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode) { camPos.x += 600; tweenCamIn(); }
			case "spooky": dad.y += 200;
			case "monster": dad.y += 100;
			case 'monster-christmas': dad.y += 130;
			case 'dad': camPos.x += 400;
			case 'pico': camPos.x += 600; dad.y += 300;
			case 'parents-christmas': dad.x -= 500;
			case 'senpai': dad.x += 150; dad.y += 360; camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry': dad.x += 150; dad.y += 360; camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions && !PlayStateChangeables.Optimize)
				{
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
				}
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'accretions': dad.x -= 10; dad.y -= 185;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		switch (curStage)
		{
			case 'limo': boyfriend.y -= 220; boyfriend.x += 260; if (FlxG.save.data.distractions) { resetFastCar(); add(fastCar); }
			case 'mall': boyfriend.x += 200;
			case 'mallEvil': boyfriend.x += 320; dad.y -= 80;
			case 'school': boyfriend.x += 200; boyfriend.y += 220; gf.x += 180; gf.y += 300;
			case 'schoolEvil': boyfriend.x += 200; boyfriend.y += 220; gf.x += 180; gf.y += 300;
			case 'space': dad.x -= 510; dad.y -= 20;
			case 'darkSpace':
				if (PlayState.SONG.song.toLowerCase() == 'security') { boyfriend.x += 90; boyfriend.y += 20; gf.x += 40; }
				dad.x -= 510; dad.y -= 20;
			case 'oblivion': dad.x -= 510; dad.y -= 20;
			case 'metro': boyfriend.x += 50; boyfriend.y += 20; dad.x -= 120; dad.y -= 50;
		}

		if (!PlayStateChangeables.Optimize)
		{
			add(gf);
			if (curStage == 'limo') add(limo);
			add(dad);
			add(boyfriend);
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll) songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this, 'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll) songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll) healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		var voidSongs = ['asteroids', 'weightless', 'event horizon', 'ultraviolet', 'gravity', 'singularity', 'security', 'stardust'];
		if (voidSongs.contains(PlayState.SONG.song.toLowerCase()))
		{
			kadeEngineWatermark = new FlxText(4, healthBarBG.y + 50, 0, SONG.song + " - " + CoolUtil.difficultyFromInt(storyDifficulty) + (Main.watermarks ? " | VsVoid by Starbreak" : ""), 16);
		}
		else
		{
			kadeEngineWatermark = new FlxText(4, healthBarBG.y + 50, 0, SONG.song + " - " + CoolUtil.difficultyFromInt(storyDifficulty) + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		}
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll) kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		originalX = scoreTxt.x;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep) add(replayTxt);

		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep) add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep) replayTxt.cameras = [camHUD];

		startingSong = true;

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;
						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) { startCountdown(); }});
						});
					});
				case 'senpai': schoolIntro(doof);
				case 'roses': FlxG.sound.play(Paths.sound('ANGRY')); schoolIntro(doof);
				case 'thorns': schoolIntro(doof);
				case 'asteroids': FlxG.sound.play(Paths.sound('Holocrowd')); spaceIntro(doof);
				case 'weightless': FlxG.sound.play(Paths.sound('Holocheer')); spaceIntro(doof);
				case 'ultraviolet': spaceIntro(doof);
				case 'gravity': spaceIntro(doof);
				case 'singularity': spaceIntro(doof);
				default: startCountdown();
			}
		}
		else
		{
			startCountdown();
		}

		if (!loadRep) rep = new Replay("na");

		#if !mobile
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		#end

		#if mobile
		hitbox = new Hitbox();
		hitbox.cameras = [camHUD];
		add(hitbox);
		#end

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses' || StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);
			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns') add(red);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;
			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() { add(dialogueBox); }, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer) { FlxG.camera.fade(FlxColor.WHITE, 1.6, false); });
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();
				remove(black);
			}
		});
	}

	function spaceIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-500, -300).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'weightless') dad.playAnim('confused', true);
		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'ultraviolet') dad.playAnim('confused', true);
		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'event-horizon') black.alpha = 0;

		new FlxTimer().start(0.08, function(tmr:FlxTimer)
		{
			black.alpha -= 0.05;
			if (black.alpha > 0)
			{
				tmr.reset(0.08);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdown();
				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if desktop
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;
		appearStaticArrows();

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];
				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);
					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y + 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y + 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}
			for (i in toBeRemoved) unspawnNotes.remove(i);
		}

		#if desktop
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) { case 'dad-battle': songLowercase = 'dadbattle'; case 'philly-nice': songLowercase = 'philly'; }
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					if (curStage.contains('school')) altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0: FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					if (curStage.startsWith('school')) ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) { ready.destroy(); }});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					if (curStage.startsWith('school')) set.setGraphicSize(Std.int(set.width * daPixelZoom));
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) { set.destroy(); }});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					if (curStage.startsWith('school')) go.setGraphicSize(Std.int(go.width * daPixelZoom));
					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) { go.destroy(); }});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
			if (charCode == value) return key;
		return null;
	}

	var keys = [false, false, false, false];

	#if !mobile
	private function releaseInput(evt:KeyboardEvent):Void
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
		var data = -1;

		switch (evt.keyCode) { case 37: data = 0; case 40: data = 1; case 38: data = 2; case 39: data = 3; }
		for (i in 0...binds.length) if (binds[i].toLowerCase() == key.toLowerCase()) data = i;
		if (data == -1) return;
		keys[data] = false;
	}

	private function handleInput(evt:KeyboardEvent):Void
	{
		if (PlayStateChangeables.botPlay || loadRep || paused) return;

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
		var data = -1;

		switch (evt.keyCode) { case 37: data = 0; case 40: data = 1; case 38: data = 2; case 39: data = 3; }
		for (i in 0...binds.length) if (binds[i].toLowerCase() == key.toLowerCase()) data = i;

		if (data == -1) return;
		if (keys[data]) return;

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);
		var dataNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		});

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		if (dataNotes.length != 0)
		{
			var coolNote = null;
			for (i in dataNotes) if (!i.isSustainNote) { coolNote = i; break; }
			if (coolNote == null) return;

			if (dataNotes.length > 1)
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) continue;
					var note = dataNotes[i];
					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}
	#end

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll) songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this, 'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll) songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog' | 'Weightless' | 'Event Horizon': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}

		if (useVideo) GlobalVideo.get().resume();

		#if desktop
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection> = songData.notes;
		var playerCounter:Int = 0;

		#if desktop
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) { case 'dad-battle': songLowercase = 'dadbattle'; case 'philly-nice': songLowercase = 'philly'; }
		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (isSM && !isStoryMode) songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end

		var daBeats:Int = 0;

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0) daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3) gottaHitNote = !section.mustHitSection;

				var oldNote:Note = (unspawnNotes.length > 0) ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.Optimize) continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0) swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.mustPress = gottaHitNote;
					if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2;
					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;
				if (swagNote.mustPress) swagNote.x += FlxG.width / 2;
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0) continue;

			if (SONG.noteStyle == null) { switch (storyWeek) { case 6: noteTypeCheck = 'pixel'; } }
			else noteTypeCheck = SONG.noteStyle;

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);
					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
					switch (Math.abs(i))
					{
						case 2: babyArrow.x += Note.swagWidth * 2; babyArrow.animation.add('static', [2]); babyArrow.animation.add('pressed', [6, 10], 12, false); babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3: babyArrow.x += Note.swagWidth * 3; babyArrow.animation.add('static', [3]); babyArrow.animation.add('pressed', [7, 11], 12, false); babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1: babyArrow.x += Note.swagWidth * 1; babyArrow.animation.add('static', [1]); babyArrow.animation.add('pressed', [5, 9], 12, false); babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0: babyArrow.x += Note.swagWidth * 0; babyArrow.animation.add('static', [0]); babyArrow.animation.add('pressed', [4, 8], 12, false); babyArrow.animation.add('confirm', [12, 16], 24, false);
					}
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4) babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
					var lowerDir:String = dataSuffix[i].toLowerCase();
					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);
					babyArrow.x += Note.swagWidth * i;
					if (FlxG.save.data.antialiasing) babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.alpha = 0;

			if (!isStoryMode)
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			switch (player)
			{
				case 0: cpuStrums.add(babyArrow);
				case 1: playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize) babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite) { spr.centerOffsets(); });
			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite) { if (isStoryMode) babyArrow.alpha = 1; });
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null) { FlxG.sound.music.pause(); vocals.pause(); }
			#if desktop
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
			#end
			if (!startTimer.finished) startTimer.active = false;
		}
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong) resyncVocals();
			if (!startTimer.finished) startTimer.active = true;
			paused = false;
			#if desktop
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			#end
		}
		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		#if desktop
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;
	public var currentBPM = 0;
	public var updateFrame = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();
			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;
					var endBeat:Float = Math.POSITIVE_INFINITY;
					TimingStruct.addTiming(beat, i.value, endBeat, 0);
					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}
					currentIndex++;
				}
			}
			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
		if (timingSeg != null)
		{
			var timingSegBpm = timingSeg.bpm;
			if (timingSegBpm != Conductor.bpm) Conductor.changeBPM(timingSegBpm, false);
		}

		var newScroll = PlayStateChangeables.scrollSpeed;
		for (i in SONG.eventObjects)
			if (i.type == "Scroll Speed Change" && i.position < curDecimalBeat)
				newScroll = i.value;
		PlayStateChangeables.scrollSpeed = newScroll;

		#if desktop
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		#end

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

		#if desktop
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);
			for (i in luaWiggles) i.update(elapsed);
			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');
			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false; kadeEngineWatermark.visible = false; healthBar.visible = false;
				iconP1.visible = false; iconP2.visible = false; scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true; kadeEngineWatermark.visible = true; healthBar.visible = true;
				iconP1.visible = true; iconP2.visible = true; scoreTxt.visible = true;
			}
			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');
			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length) playerStrums.members[i].visible = p2;
			}
		}
		#end

		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime()) notesHitArray.remove(cock);
				else balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS) maxNPS = nps;
		}

		#if !mobile
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old') iconP1.animation.play(SONG.player1);
			else iconP1.animation.play('bf-old');
		}
		#end

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight;
		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			if (FlxG.random.bool(0.1)) FlxG.switchState(new GitarooPause());
			else openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		#if desktop
		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo) { GlobalVideo.get().stop(); remove(videoSprite); FlxG.stage.window.onFocusOut.remove(focusOut); FlxG.stage.window.onFocusIn.remove(focusIn); removedVideo = true; }
			cannotDie = true;
			DiscordClient.changePresence("Chart Editor", null, null, true);
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			if (luaModchart != null) { luaModchart.die(); luaModchart = null; }
		}
		#end

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2) health = 2;
		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0) startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (allowedToHeadbang)
			{
				if (gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					switch (curSong)
					{
						case 'Philly Nice':
							if (curBeat < 250 && curBeat != 184 && curBeat != 216 && curBeat % 16 == 8 && !triggeredAlready) { gf.playAnim('cheer'); triggeredAlready = true; }
							else triggeredAlready = false;
						case 'Bopeebo':
							if (curBeat > 5 && curBeat < 130 && curBeat % 8 == 7 && !triggeredAlready) { gf.playAnim('cheer'); triggeredAlready = true; }
							else triggeredAlready = false;
						case 'Blammed':
							if (curBeat > 30 && curBeat < 190 && (curBeat < 90 || curBeat > 128) && curBeat % 4 == 2 && !triggeredAlready) { gf.playAnim('cheer'); triggeredAlready = true; }
							else triggeredAlready = false;
						case 'Cocoa':
							if (curBeat < 170 && (curBeat < 65 || curBeat > 130 && curBeat < 145) && curBeat % 16 == 15 && !triggeredAlready) { gf.playAnim('cheer'); triggeredAlready = true; }
							else triggeredAlready = false;
						case 'Eggnog':
							if (curBeat > 10 && curBeat != 111 && curBeat < 220 && curBeat % 8 == 7 && !triggeredAlready) { gf.playAnim('cheer'); triggeredAlready = true; }
							else triggeredAlready = false;
					}
				}
			}

			#if desktop
			if (luaModchart != null) luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0; var offsetY = 0;
				#if desktop
				if (luaModchart != null) { offsetX = luaModchart.getVar("followXOffset", "float"); offsetY = luaModchart.getVar("followYOffset", "float"); }
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if desktop
				if (luaModchart != null) luaModchart.executeState('playerTwoTurn', []);
				#end
				switch (dad.curCharacter)
				{
					case 'mom' | 'mom-car': camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry': camFollow.y = dad.getMidpoint().y - 430; camFollow.x = dad.getMidpoint().x - 100;
					case 'void' | 'mad-void' | 'crazed-void': camFollow.y = dad.getMidpoint().y - 40; camFollow.x = dad.getMidpoint().x + 170;
					case 'ac-void': camFollow.y = dad.getMidpoint().y - 70; camFollow.x = dad.getMidpoint().x + 170;
					case 'accretions': camFollow.y = dad.getMidpoint().y - 10; camFollow.x = dad.getMidpoint().x + 180;
					case 'starbreak' | 'starbreak-night': camFollow.y = dad.getMidpoint().y - 40; camFollow.x = dad.getMidpoint().x + 170;
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0; var offsetY = 0;
				#if desktop
				if (luaModchart != null) { offsetX = luaModchart.getVar("followXOffset", "float"); offsetY = luaModchart.getVar("followYOffset", "float"); }
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				#if desktop
				if (luaModchart != null) luaModchart.executeState('playerOneTurn', []);
				#end
				switch (curStage)
				{
					case 'limo': camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall': camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school' | 'schoolEvil': camFollow.x = boyfriend.getMidpoint().x - 200; camFollow.y = boyfriend.getMidpoint().y - 200;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				vocals.stop();
				FlxG.sound.music.stop();
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#if desktop
				DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
				#end
			}
			else health = 1;
		}

		if (!inCutscene && FlxG.save.data.resetButton)
		{
			#if !mobile
			if (FlxG.keys.justPressed.R)
			#else
			if (false)
			#end
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				vocals.stop();
				FlxG.sound.music.stop();
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#if desktop
				DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC);
				#end
			}
		}

		if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);
			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			#if mobile
			if (hitbox != null)
			{
				holdArray[0] = holdArray[0] || hitbox.isLeft;
				holdArray[1] = holdArray[1] || hitbox.isDown;
				holdArray[2] = holdArray[2] || hitbox.isUp;
				holdArray[3] = holdArray[3] || hitbox.isRight;
			}
			#end

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.tooLate) { daNote.active = false; daNote.visible = false; }
				else { daNote.visible = true; daNote.active = true; }

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) - daNote.noteYOff;
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2)) + daNote.noteYOff;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial') camZooming = true;
					var altAnim:String = "";
					if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) altAnim = '-alt';
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID) spr.animation.play('confirm', true);
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) { spr.centerOffsets(); spr.offset.x -= 13; spr.offset.y -= 13; }
							else spr.centerOffsets();
						});
					}
					#if desktop
					if (luaModchart != null) luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end
					dad.holdTimer = 0;
					if (SONG.needsVoices) vocals.volume = 1;
					daNote.active = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote) daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive) daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote) daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive) daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school')) daNote.x -= 11;
				}

				if ((daNote.mustPress && daNote.tooLate) && daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit) { daNote.kill(); notes.remove(daNote, true); }
					else
					{
						if (!daNote.isSustainNote) health -= 0.10;
						vocals.volume = 0;
						if (theFunne && !daNote.isSustainNote) noteMiss(daNote.noteData, daNote);
						if (daNote.isParent) { health -= 0.20; for (i in daNote.children) { i.alpha = 0.3; i.sustainActive = false; } }
						else if (!daNote.wasGoodHit && daNote.isSustainNote && daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
						{
							health -= 0.20;
							for (i in daNote.parent.children) { i.alpha = 0.3; i.sustainActive = false; }
							if (daNote.parent.wasGoodHit) misses++;
							updateAccuracy();
						}
					}
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
			cpuStrums.forEach(function(spr:FlxSprite) { if (spr.animation.finished) { spr.animation.play('static'); spr.centerOffsets(); } });

		if (!inCutscene && songStarted) keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE) endSong();
		#end
	}

	function endSong():Void
	{
		#if !mobile
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		#end
		if (useVideo) { GlobalVideo.get().stop(); FlxG.stage.window.onFocusOut.remove(focusOut); FlxG.stage.window.onFocusIn.remove(focusIn); PlayState.instance.remove(PlayState.instance.videoSprite); }
		if (isStoryMode) campaignMisses = misses;
		if (!loadRep) rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else { PlayStateChangeables.botPlay = false; PlayStateChangeables.scrollSpeed = 1; PlayStateChangeables.useDownscroll = false; }
		if (FlxG.save.data.fpsCap > 290) (cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		#if desktop
		if (luaModchart != null) { luaModchart.die(); luaModchart = null; }
		#end
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) { case 'Dad-Battle': songHighscore = 'Dadbattle'; case 'Philly-Nice': songHighscore = 'Philly'; }
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
		}
		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				storyPlaylist.remove(storyPlaylist[0]);
				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					paused = true;
					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen) { openSubState(new ResultsScreen()); new FlxTimer().start(1, function(tmr:FlxTimer) { inResults = true; }); }
					else { FlxG.sound.playMusic(Paths.music('freakyMenu')); Conductor.changeBPM(120); FlxG.switchState(new StoryMenuState()); }
					#if desktop
					if (luaModchart != null) { luaModchart.die(); luaModchart = null; }
					#end
					if (SONG.validScore) Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat) { case 'Dad-Battle': songFormat = 'Dadbattle'; case 'Philly-Nice': songFormat = 'Philly'; }
					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);
					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}
					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'singularity')
					{
						FlxG.sound.music.stop();
						FlxG.switchState(new Cutscene3SubState());
					}
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				paused = true;
				FlxG.sound.music.stop();
				vocals.stop();
				if (FlxG.save.data.scoreScreen) { openSubState(new ResultsScreen()); new FlxTimer().start(1, function(tmr:FlxTimer) { inResults = true; }); }
				else FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;
	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1) totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit': score = -300; combo = 0; misses++; health -= 0.06; ss = false; shits++; if (FlxG.save.data.accuracyMod == 0) totalNotesHit -= 1;
			case 'bad': daRating = 'bad'; score = 0; health -= 0.03; ss = false; bads++; if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.50;
			case 'good': daRating = 'good'; score = 200; ss = false; goods++; if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.75;
			case 'sick': if (health < 2) health += 0.04; if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 1; sicks++;
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			if (curStage.startsWith('school')) { pixelShitPart1 = 'weeb/pixelUI/'; pixelShitPart2 = '-pixel'; }

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			if (FlxG.save.data.changedHit) { rating.x = FlxG.save.data.changedHitX; rating.y = FlxG.save.data.changedHitY; }
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep) msTiming = 0;
			if (loadRep) msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null) remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating) { case 'shit' | 'bad': currentTimingShown.color = FlxColor.RED; case 'good': currentTimingShown.color = FlxColor.GREEN; case 'sick': currentTimingShown.color = FlxColor.CYAN; }
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				hits.shift(); hits.shift(); hits.shift(); hits.pop(); hits.pop(); hits.pop(); hits.push(msTiming);
				var total = 0.0;
				for (i in hits) total += i;
				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1) currentTimingShown.alpha = 1;
			if (!PlayStateChangeables.botPlay || loadRep) add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep) add(rating);

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				if (FlxG.save.data.antialiasing) rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				if (FlxG.save.data.antialiasing) comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
			var comboSplit:Array<String> = (combo + "").split('');
			if (combo > highestCombo) highestCombo = combo;
			if (comboSplit.length == 1) { seperatedScore.push(0); seperatedScore.push(0); }
			else if (comboSplit.length == 2) seperatedScore.push(0);
			for (i in 0...comboSplit.length) seperatedScore.push(Std.parseInt(comboSplit[i]));

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];
				if (!curStage.startsWith('school')) { if (FlxG.save.data.antialiasing) numScore.antialiasing = true; numScore.setGraphicSize(Std.int(numScore.width * 0.5)); }
				else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.updateHitbox();
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween) { numScore.destroy(); }, startDelay: Conductor.crochet * 0.002});
				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001, onUpdate: function(tween:FlxTween) { if (currentTimingShown != null) currentTimingShown.alpha -= 0.02; timeShown++; }});
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween) { coolText.destroy(); comboSpr.destroy(); if (currentTimingShown != null && timeShown >= 20) { remove(currentTimingShown); currentTimingShown = null; } rating.destroy(); }, startDelay: Conductor.crochet * 0.001});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		#if mobile
		if (hitbox != null)
		{
			for (i in 0...4)
			{
				if (hitbox.isJustPressed(i)) pressArray[i] = true;
				if (hitbox.isJustReleased(i)) releaseArray[i] = true;
				if (hitbox.isHeld(i)) holdArray[i] = true;
			}
		}
		#end

		#if desktop
		if (luaModchart != null)
		{
			if (controls.LEFT_P) luaModchart.executeState('keyPressed', ["left"]);
			if (controls.DOWN_P) luaModchart.executeState('keyPressed', ["down"]);
			if (controls.UP_P) luaModchart.executeState('keyPressed', ["up"]);
			if (controls.RIGHT_P) luaModchart.executeState('keyPressed', ["right"]);
		}
		#end

		if (PlayStateChangeables.botPlay) { holdArray = [false, false, false, false]; pressArray = [false, false, false, false]; releaseArray = [false, false, false, false]; }

		var anas:Array<Ana> = [null, null, null, null];
		for (i in 0...pressArray.length) if (pressArray[i]) anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
					goodNoteHit(daNote);
			});
		}

		if (pressArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;
			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var directionsAccounted:Array<Bool> = [false, false, false, false];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
				{
					if (directionList.contains(daNote.noteData))
					{
						directionsAccounted[daNote.noteData] = true;
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) { dumbNotes.push(daNote); break; }
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) { possibleNotes.remove(coolNote); possibleNotes.push(daNote); break; }
						}
					}
					else { directionsAccounted[daNote.noteData] = true; possibleNotes.push(daNote); directionList.push(daNote.noteData); }
				}
			});

			for (note in dumbNotes) { note.kill(); notes.remove(note, true); note.destroy(); }
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var hit = [false, false, false, false];

			if (perfectMode) goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				if (!FlxG.save.data.ghost)
					for (shit in 0...pressArray.length)
						if (pressArray[shit] && !directionList.contains(shit)) noteMiss(shit, null);

				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
					{
						if (mashViolations != 0) mashViolations--;
						hit[coolNote.noteData] = true;
						scoreTxt.color = FlxColor.WHITE;
						var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
						anas[coolNote.noteData].hit = true;
						anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
						anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
						goodNoteHit(coolNote);
					}
				}
			}
		}

		if (!loadRep) for (i in anas) if (i != null) replayAna.anaArray.push(i);

		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (loadRep) { var n = findByTime(daNote.strumTime); if (n != null) { goodNoteHit(daNote); boyfriend.holdTimer = daNote.sustainLength; } }
					else { goodNoteHit(daNote); boyfriend.holdTimer = daNote.sustainLength; }
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.playAnim('idle');

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
			if (!keys[spr.ID]) spr.animation.play('static');
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) { spr.centerOffsets(); spr.offset.x -= 13; spr.offset.y -= 13; }
			else spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes) if (i[0] == time) return i;
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length) if (rep.replay.songNotes[i][0] == time) return i;
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	#if cpp
	public static var webmHandler:WebmHandler;
	#else
	public static var webmHandler:Dynamic = null;
	#end

	public var playingDathing = false;
	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused) return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		if (FlxG.sound.music != null) { FlxG.sound.music.pause(); vocals.pause(); }
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn() {}

	public function backgroundVideo(source:String)
	{
		#if cpp
		useVideo = true;
		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);
		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = "WEBM SHIT";
		GlobalVideo.setWebm(webmHandler);
		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm) GlobalVideo.get().updatePlayer();
		GlobalVideo.get().show();
		if (GlobalVideo.isWebm) GlobalVideo.get().restart();
		else GlobalVideo.get().play();
		var data = webmHandler.webm.bitmapData;
		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);
		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));
		remove(gf); remove(boyfriend); remove(dad);
		add(videoSprite); add(gf); add(boyfriend); add(dad);
		if (!songStarted) webmHandler.pause();
		else webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			if (combo > 5 && gf.animOffsets.exists('sad')) gf.playAnim('sad');
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep) { saveNotes.push([daNote.strumTime, 0, direction, 166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166]); saveJudge.push("miss"); }
			}
			else if (!loadRep)
			{
				saveNotes.push([Conductor.songPosition, 0, direction, 166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166]);
				saveJudge.push("miss");
			}

			if (FlxG.save.data.accuracyMod == 1) totalNotesHit -= 1;
			if (daNote != null) { if (!daNote.isSustainNote) songScore -= 10; }
			else songScore -= 10;

			if (FlxG.save.data.missSounds) FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if desktop
			if (luaModchart != null) luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = [];
		notes.forEachAlive(function(daNote:Note) { if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate) { possibleNotes.push(daNote); possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); } });
		if (possibleNotes.length == 1) return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0) mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
		if (loadRep) { noteDiff = findByTime(note.strumTime)[3]; note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)]; }
		else note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss") return;

		if (!note.isSustainNote) notesHitArray.unshift(Date.now());
		if (!resetMashViolation && mashViolations >= 1) mashViolations--;
		if (mashViolations < 0) mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote) { popUpScore(note); combo += 1; }
			else totalNotesHit += 1;

			switch (note.noteData)
			{
				case 2: boyfriend.playAnim('singUP', true);
				case 3: boyfriend.playAnim('singRIGHT', true);
				case 1: boyfriend.playAnim('singDOWN', true);
				case 0: boyfriend.playAnim('singLEFT', true);
			}

			#if desktop
			if (luaModchart != null) luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote) array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			playerStrums.forEach(function(spr:FlxSprite) { if (Math.abs(note.noteData) == spr.ID) spr.animation.play('confirm', true); });

			note.kill();
			notes.remove(note, true);
			note.destroy();
			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions) { fastCar.x = -12600; fastCar.y = FlxG.random.int(140, 250); fastCar.velocity.x = 0; fastCarCanDrive = true; }
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions) { FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7); fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3; fastCarCanDrive = false; new FlxTimer().start(2, function(tmr:FlxTimer) { resetFastCar(); }); }
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void { if (FlxG.save.data.distractions) { trainMoving = true; if (!trainSound.playing) trainSound.play(true); } }

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700) { startedMoving = true; gf.playAnim('hairBlow'); }
			if (startedMoving)
			{
				phillyTrain.x -= 400;
				if (phillyTrain.x < -2000 && !trainFinishing) { phillyTrain.x = -1150; trainCars -= 1; if (trainCars <= 0) trainFinishing = true; }
				if (phillyTrain.x < -4000 && trainFinishing) trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions) { gf.playAnim('hairFall'); phillyTrain.x = FlxG.width + 200; trainMoving = false; trainCars = 8; trainFinishing = false; startedMoving = false; }
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');
		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);
		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) resyncVocals();
		#if desktop
		if (executeModchart && luaModchart != null) { luaModchart.setVar('curStep', curStep); luaModchart.executeState('stepHit', [curStep]); }
		songLength = FlxG.sound.music.length;
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic) notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		#if desktop
		if (executeModchart && luaModchart != null) { luaModchart.setVar('curBeat', curBeat); luaModchart.executeState('beatHit', [curBeat]); }
		#end

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf')
		{
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft')) dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight')) dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")) && dad.animation.curAnim.curFrame >= 10 && dad.curCharacter != 'gf' && dad.animation.curAnim.name != 'wink')
				if (curBeat % idleBeat == 0 || dad.curCharacter == "spooky") dad.dance(idleToBeat);
		}

		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35 || curSong.toLowerCase() == 'event horizon' && curBeat >= 392 && curBeat < 456 && camZooming && FlxG.camera.zoom < 1.35) { FlxG.camera.zoom += 0.015; camHUD.zoom += 0.03; }
			if (curSong.toLowerCase() == 'singularity')
			{
				if (curBeat >= 456 && curBeat < 468 && camZooming && FlxG.camera.zoom < 1.35 || curBeat >= 472 && curBeat < 488 && camZooming && FlxG.camera.zoom < 1.35) { FlxG.camera.zoom += 0.035; camHUD.zoom += 0.05; }
				if (bgGlitch.alpha > 0) { if (camZooming && FlxG.camera.zoom < 1.35 && curBeat < 600) { FlxG.camera.zoom += 0.025; camHUD.zoom += 0.03; } }
				else if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) { FlxG.camera.zoom += 0.015; camHUD.zoom += 0.03; }
			}
			else if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) { FlxG.camera.zoom += 0.015; camHUD.zoom += 0.03; }
		}

		iconP1.setGraphicSize(Std.int(iconP1.width = 180));
		iconP2.setGraphicSize(Std.int(iconP2.width = 180));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		FlxTween.tween(iconP1, {width: 150}, 0.15, {ease: FlxEase.quadOut});
		FlxTween.tween(iconP2, {width: 150}, 0.15, {ease: FlxEase.quadOut});

		if (curBeat % gfSpeed == 0) gf.dance();
		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % idleBeat == 0) boyfriend.playAnim('idle', idleToBeat);
		if (curBeat % 8 == 7 && curSong == 'Bopeebo') boyfriend.playAnim('hey', true);
		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48) { boyfriend.playAnim('hey', true); dad.playAnim('cheer', true); }

		switch (curStage)
		{
			case 'school': if (FlxG.save.data.distractions) bgGirls.dance();
			case 'mall': if (FlxG.save.data.distractions) { upperBoppers.animation.play('bop', true); bottomBoppers.animation.play('bop', true); santa.animation.play('idle', true); }
			case 'limo': if (FlxG.save.data.distractions) { grpLimoDancers.forEach(function(dancer:BackgroundDancer) { dancer.dance(); }); if (FlxG.random.bool(10) && fastCarCanDrive) fastCarDrive(); }
			case "philly":
				if (FlxG.save.data.distractions)
				{
					if (!trainMoving) trainCooldown += 1;
					if (curBeat % 4 == 0) { phillyCityLights.forEach(function(light:FlxSprite) { light.visible = false; }); curLight = FlxG.random.int(0, phillyCityLights.length - 1); phillyCityLights.members[curLight].visible = true; }
				}
				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) if (FlxG.save.data.distractions) { trainCooldown = FlxG.random.int(-4, 0); trainStart(); }
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) if (FlxG.save.data.distractions) lightningStrikeShit();
	}

	var curLight:Int = 0;
}
