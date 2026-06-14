package;

class HitboxOption extends Option
{
	public function new(desc:String = "")
	{
		super();
		description = desc;
	}

	public override function getDisplay():String
	{
		return "Hitbox Mode: " + (FlxG.save.data.hitboxMode ? "ON" : "OFF");
	}

	public override function press():Bool
	{
		FlxG.save.data.hitboxMode = !FlxG.save.data.hitboxMode;
		return true;
	}

	public override function getValue():String
	{
		return "Hitbox Mode: " + (FlxG.save.data.hitboxMode ? "ON" : "OFF");
	}

	public override function getAccept():Bool
	{
		return true;
	}

	public override function getDescription():String
	{
		return description;
	}

	var description:String;
}

class VSliceControlsOption extends Option
{
	public function new(desc:String = "")
	{
		super();
		description = desc;
	}

	public override function getDisplay():String
	{
		return "V Slice Controls: " + (FlxG.save.data.vsliceControls ? "ON" : "OFF");
	}

	public override function press():Bool
	{
		FlxG.save.data.vsliceControls = !FlxG.save.data.vsliceControls;
		return true;
	}

	public override function getValue():String
	{
		return "V Slice Controls: " + (FlxG.save.data.vsliceControls ? "ON" : "OFF");
	}

	public override function getAccept():Bool
	{
		return true;
	}

	public override function getDescription():String
	{
		return description;
	}

	var description:String;
}
