package mobile;

import lime.system.System;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class StorageUtil
{
	public static var baseDirectory(get, never):String;

	static function get_baseDirectory():String
	{
		return System.applicationStorageDirectory;
	}

	public static function ensureDirectory(path:String):Void
	{
		#if sys
		if (path == null || path == "")
			return;
		if (!FileSystem.exists(path))
			FileSystem.createDirectory(path);
		#end
	}

	public static function getPath(relativePath:String):String
	{
		return Path.join([baseDirectory, relativePath]);
	}

	public static function exists(relativePath:String):Bool
	{
		#if sys
		return FileSystem.exists(getPath(relativePath));
		#else
		return false;
		#end
	}

	public static function readText(relativePath:String):String
	{
		#if sys
		var full:String = getPath(relativePath);
		return FileSystem.exists(full) ? File.getContent(full) : null;
		#else
		return null;
		#end
	}

	public static function writeText(relativePath:String, content:String):Bool
	{
		#if sys
		var full:String = getPath(relativePath);
		try
		{
			ensureDirectory(Path.directory(full));
			File.saveContent(full, content);
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#else
		return false;
		#end
	}

	public static function deleteFile(relativePath:String):Bool
	{
		#if sys
		var full:String = getPath(relativePath);
		try
		{
			if (FileSystem.exists(full))
				FileSystem.deleteFile(full);
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#else
		return false;
		#end
	}

	public static function listFiles(relativePath:String = ""):Array<String>
	{
		#if sys
		var full:String = getPath(relativePath);
		if (!FileSystem.exists(full) || !FileSystem.isDirectory(full))
			return [];
		return FileSystem.readDirectory(full);
		#else
		return [];
		#end
	}

	public static function isDirectory(relativePath:String):Bool
	{
		#if sys
		var full:String = getPath(relativePath);
		return FileSystem.exists(full) && FileSystem.isDirectory(full);
		#else
		return false;
		#end
	}
}
