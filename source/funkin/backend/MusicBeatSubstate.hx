package funkin.backend;

import funkin.backend.PlayerSettings;
import funkin.data.*;
import funkin.data.scripts.*;
import flixel.FlxSubState;
#if mobile
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import mobile.controls.MobileHitbox;
import mobile.controls.MobileVirtualPad;
#end

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls return PlayerSettings.player1.controls;

	public var scripted:Bool = false;
	public var scriptName:String = 'Placeholder';
	public var script:OverrideStateScript;
	
	#if mobile
	public var hitbox:MobileHitbox;
	public var virtualPad:MobileVirtualPad;

	public var virtualPadCam:FlxCamera;
	public var hitboxCam:FlxCamera;

    public function addVirtualPad(DPad:MobileDPadMode, Action:MobileActionMode)
	{
		virtualPad = new MobileVirtualPad(DPad, Action);
		add(virtualPad);
	}
	
	public function addVirtualPadCamera(DefaultDrawTarget:Bool = false)
	{
		if (virtualPad != null)
		{
			virtualPadCam = new FlxCamera();
			virtualPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(virtualPadCam, DefaultDrawTarget);
			
			virtualPad.cameras = [virtualPadCam];
		}
	}

	public function removeVirtualPad()
	{
		if (virtualPad != null)
		{
			remove(virtualPad);
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
		}

		if(virtualPadCam != null)
		{
			FlxG.cameras.remove(virtualPadCam);
			virtualPadCam = FlxDestroyUtil.destroy(virtualPadCam);
		}
	}

	public function addMobileControls(DefaultDrawTarget:Bool = false)
	{
		hitbox = new MobileHitbox();
		
		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, DefaultDrawTarget);
		
		hitbox.cameras = [hitboxCam];
		hitbox.visible = false;
		add(hitbox);
		
		for (hbox in hitbox.members)
		{
			hbox.scale.x = (FlxG.width / 4) / hbox.frameWidth;
			hbox.scale.y = FlxG.height / hbox.frameHeight;
			hbox.updateHitbox();
		}
		
		for (i in 0...hitbox.length)
		{
			hitbox.members[i].x = hitbox.members[i].width * i;
		}
	}

	public function removeMobileControls()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
		}

		if(hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
	}
	#end

	public function setUpScript(s:String = 'Placeholder')
	{
		scripted = true;
		scriptName = s;

		var scriptFile = FunkinIris.getPath('scripts/menus/substates/$scriptName', false);

		if (FileSystem.exists(scriptFile))
		{
			script = OverrideStateScript.fromFile(scriptFile);
			trace('$scriptName script [$scriptFile] found!');
		}
		else
		{
			// trace('$scriptName script [$scriptFile] is null!');
		}

		callOnScript('onCreate', []);
	}

	inline function isHardcodedState() return (script != null && !script.customMenu) || (script == null);

	inline function setOnScript(name:String, value:Dynamic)
	{
		if (script != null) script.set(name, value);
	}

	public function callOnScript(name:String, vars:Array<Any>, ignoreStops:Bool = false)
	{
		var returnVal:Dynamic = Globals.Function_Continue;
		if (script != null)
		{
			var ret:Dynamic = script.call(name, vars);
			if (ret == Globals.Function_Halt)
			{
				ret = returnVal;
				if (!ignoreStops) return returnVal;
			};

			if (ret != Globals.Function_Continue && ret != null) returnVal = ret;

			if (returnVal == null) returnVal = Globals.Function_Continue;
		}
		return returnVal;
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0) stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrotchet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
