package;

import openfl.utils.Assets;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if mobile
import mobile.StorageUtil;
#end
#if sys
import sys.FileSystem;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var ASTC_EXT = "astc";

	static var currentLevel:String;
	static var astcExistsCache:Map<String, Bool> = new Map();
	static var overrideExistsCache:Map<String, Bool> = new Map();

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	static public function image(key:String, ?library:String)
	{
		#if mobile
		var overridePath = getStorageOverridePath('images/$key.png');
		if (overridePath != null)
			return overridePath;
		#end

		#if (mobile && cpp)
		if (FlxG.save.data.useAstc == true)
		{
			var astcPath = getAstcPath('images/$key', library);
			if (astcPath != null)
				return astcPath;
		}
		#end

		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	#if mobile
	static function getStorageOverridePath(relativePath:String):Null<String>
	{
		var cached = overrideExistsCache.get(relativePath);
		if (cached == false)
			return null;

		if (cached == null)
		{
			cached = StorageUtil.exists('overrides/$relativePath');
			overrideExistsCache.set(relativePath, cached);
		}

		return cached ? StorageUtil.getPath('overrides/$relativePath') : null;
	}
	#end

	#if (mobile && cpp)
	static function getAstcPath(baseKey:String, ?library:String):Null<String>
	{
		var basePath = getPath('$baseKey.$ASTC_EXT', BINARY, library);
		var cached = astcExistsCache.get(basePath);

		if (cached == null)
		{
			cached = OpenFlAssets.exists(basePath, BINARY);
			astcExistsCache.set(basePath, cached);
		}

		return cached ? basePath : null;
	}
	#end

	static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		var useCache = FlxG.save.data.cacheImages;
		#if !cpp
		useCache = false;
		#end
		if (isCharacter)
		{
			if (useCache)
			{
				#if cpp
				return FlxAtlasFrames.fromSparrow(imageCached(key), file('images/characters/$key.xml', library));
				#else
				return null;
				#end
			}
			else
				return FlxAtlasFrames.fromSparrow(image('characters/$key', library), file('images/characters/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	#if cpp
	inline static public function imageCached(key:String):FlxGraphic
	{
		var data = Caching.bitmapData.get(key);
		return data;
	}
	#end

	static public function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		var useCache = FlxG.save.data.cacheImages;
		#if !cpp
		useCache = false;
		#end
		if (isCharacter)
		{
			if (useCache)
			{
				#if cpp
				return FlxAtlasFrames.fromSpriteSheetPacker(imageCached(key), file('images/$key.txt', library));
				#else
				return null;
				#end
			}
			else
				return FlxAtlasFrames.fromSpriteSheetPacker(image('characters/$key'), file('images/characters/$key.txt', library));
		}
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
