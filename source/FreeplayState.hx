package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	var charInputs:String;
	var secret:String = "STAR";

	static var secretUnlocked:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String, Array<SwagSong>> = [];

	#if mobile
	var touchStartY:Float = 0;
	var touchMoved:Bool = false;
	#end

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		}
		catch (ex) {}
	}

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		var altSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglistAlt'));

		songData = [];
		songs = [];

		if (!secretUnlocked)
		{
			for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');
				var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
				songs.push(meta);
				var format = StringTools.replace(meta.songName, " ", "-");
				switch (format)
				{
					case 'Dad-Battle': format = 'Dadbattle';
					case 'Philly-Nice': format = 'Philly';
				}
				var diffs = [];
				FreeplayState.loadDiff(0, format, meta.songName, diffs);
				FreeplayState.loadDiff(1, format, meta.songName, diffs);
				FreeplayState.loadDiff(2, format, meta.songName, diffs);
				FreeplayState.songData.set(meta.songName, diffs);
			}
		}

		if (secretUnlocked)
		{
			for (i in 0...altSonglist.length)
			{
				var data:Array<String> = altSonglist[i].split(':');
				var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
				songs.push(meta);
				var format = StringTools.replace(meta.songName, " ", "-");
				switch (format)
				{
					case 'Dad-Battle': format = 'Dadbattle';
					case 'Philly-Nice': format = 'Philly';
				}
				var diffs = [];
				FreeplayState.loadDiff(0, format, meta.songName, diffs);
				FreeplayState.loadDiff(1, format, meta.songName, diffs);
				FreeplayState.loadDiff(2, format, meta.songName, diffs);
				FreeplayState.songData.set(meta.songName, diffs);
			}
		}

		#if sys
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm"))
					{
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new SongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song, song, song]);
					}
				}
			}
		}
		#end

		#if desktop
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		if (FlxG.save.data.antialiasing) bg.antialiasing = true;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 105, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		#if mobile
		var backHint:FlxText = new FlxText(0, 0, 0, "B", 28);
		backHint.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		backHint.scrollFactor.set();
		backHint.x = FlxG.width - backHint.width - 10;
		backHint.y = FlxG.height - backHint.height - 10;
		add(backHint);
		#end

		changeSelection();
		changeDiff();

		charInputs = "";

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if (FlxG.sound.music.volume > 0.8)
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		#if !mobile
		checkCodeInput();

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP) changeSelection(-1);
			if (gamepad.justPressed.DPAD_DOWN) changeSelection(1);
			if (gamepad.justPressed.DPAD_LEFT) changeDiff(-1);
			if (gamepad.justPressed.DPAD_RIGHT) changeDiff(1);
		}

		if (upP) changeSelection(-1);
		if (downP) changeSelection(1);

		if (FlxG.keys.justPressed.LEFT) changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT) changeDiff(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (accepted)
			selectSong();
		#end

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
					FlxG.switchState(new MainMenuState());
					return;
				}

				var rightZone = FlxG.width * 0.65;
				if (touch.screenX >= rightZone)
				{
					var diffZoneY = FlxG.height * 0.5;
					if (touch.screenY < diffZoneY)
						changeDiff(-1);
					else
						changeDiff(1);
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
				else if (touch.screenX < FlxG.width * 0.65)
				{
					selectSong();
				}
			}
		}
		#end
	}

	function selectSong()
	{
		var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songFormat)
		{
			case 'Dad-Battle': songFormat = 'Dadbattle';
			case 'Philly-Nice': songFormat = 'Philly';
		}
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null) return;
		}
		catch (ex) { return; }

		PlayState.SONG = hmm;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;
		#if sys
		if (songs[curSelected].songCharacter == "sm")
		{
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (curDifficulty < 0) curDifficulty = 2;
		if (curDifficulty > 2) curDifficulty = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;
		if (curSelected < 0) curSelected = songs.length - 1;
		if (curSelected >= songs.length) curSelected = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';

		#if PRELOAD_ALL
		if (songs[curSelected].songCharacter == "sm")
		{
			var data = songs[curSelected];
			#if sys
			var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
			#end
		}
		else
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
				Conductor.changeBPM(hmm.bpm);
		}
		catch (ex) {}

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;
		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;
		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
	}

	#if !mobile
	function checkCodeInput()
	{
		if (FlxG.keys.justPressed.ANY)
		{
			if (FlxG.keys.justPressed.A) charInputs += 'A';
			else if (FlxG.keys.justPressed.B) charInputs += 'B';
			else if (FlxG.keys.justPressed.C) charInputs += 'C';
			else if (FlxG.keys.justPressed.D) charInputs += 'D';
			else if (FlxG.keys.justPressed.E) charInputs += 'E';
			else if (FlxG.keys.justPressed.F) charInputs += 'F';
			else if (FlxG.keys.justPressed.G) charInputs += 'G';
			else if (FlxG.keys.justPressed.H) charInputs += 'H';
			else if (FlxG.keys.justPressed.I) charInputs += 'I';
			else if (FlxG.keys.justPressed.J) charInputs += 'J';
			else if (FlxG.keys.justPressed.K) charInputs += 'K';
			else if (FlxG.keys.justPressed.L) charInputs += 'L';
			else if (FlxG.keys.justPressed.M) charInputs += 'M';
			else if (FlxG.keys.justPressed.N) charInputs += 'N';
			else if (FlxG.keys.justPressed.O) charInputs += 'O';
			else if (FlxG.keys.justPressed.P) charInputs += 'P';
			else if (FlxG.keys.justPressed.Q) charInputs += 'Q';
			else if (FlxG.keys.justPressed.R) charInputs += 'R';
			else if (FlxG.keys.justPressed.S) charInputs += 'S';
			else if (FlxG.keys.justPressed.T) charInputs += 'T';
			else if (FlxG.keys.justPressed.U) charInputs += 'U';
			else if (FlxG.keys.justPressed.V) charInputs += 'V';
			else if (FlxG.keys.justPressed.W) charInputs += 'W';
			else if (FlxG.keys.justPressed.X) charInputs += 'X';
			else if (FlxG.keys.justPressed.Y) charInputs += 'Y';
			else if (FlxG.keys.justPressed.Z) charInputs += 'Z';
			else if (FlxG.keys.justPressed.ZERO) charInputs += '0';
			else if (FlxG.keys.justPressed.ONE) charInputs += '1';
			else if (FlxG.keys.justPressed.TWO) charInputs += '2';
			else if (FlxG.keys.justPressed.THREE) charInputs += '3';
			else if (FlxG.keys.justPressed.FOUR) charInputs += '4';
			else if (FlxG.keys.justPressed.FIVE) charInputs += '5';
			else if (FlxG.keys.justPressed.SIX) charInputs += '6';
			else if (FlxG.keys.justPressed.SEVEN) charInputs += '7';
			else if (FlxG.keys.justPressed.EIGHT) charInputs += '8';
			else if (FlxG.keys.justPressed.NINE) charInputs += '9';

			if (secret.startsWith(charInputs))
			{
				if (charInputs == secret)
				{
					FlxG.sound.play(Paths.sound('Unlock', 'shared'), 1.0);
					secretUnlocked = true;
					FlxG.switchState(new MainMenuState());
				}
				else if (charInputs.length >= 5)
					charInputs = '';
			}
		}
	}
	#end
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	#if sys
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
