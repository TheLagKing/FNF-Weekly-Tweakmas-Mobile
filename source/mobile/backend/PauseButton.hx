package mobile.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

/**
 * Pause? PAUSE!!
 *
 * @author FalsoNova (Falso.BR)
 * why tf did i have to fix this :( -TheLagKing
 */
class PauseButton extends FlxSprite
{
	public var onClick:Void->Void;

	private var _lastTouchId:Int = -1;

	public function new(x:Float = 0, y:Float = 0, ?onClick:Void->Void)
	{
		var posX:Float = (x == 0) ? 25 : x;
		var posY:Float = (y == 0) ? 25 : y;

		super(posX, posY);

		#if mobile
		var bitmap:BitmapData = null;
		var path:String = 'assets/mobile/pauseButton.png';

		try
		{
		#if ios
		bitmap = openfl.utils.Assets.getBitmapData(path);
		#else
		bitmap = BitmapData.fromFile(path);
		#end
		}

		if (bitmap != null)
		{
			loadGraphic(FlxGraphic.fromBitmapData(bitmap));
		}

		antialiasing = true;
		scrollFactor.set(0, 0);
		alpha = 0.6;
		scale.set(0.8, 0.8);
		updateHitbox();
		centerOffsets();

		this.onClick = onClick;
		#else
        trace('PauseButton only Avaliable for Mobile Targets!');
		visible = false;
		active = false;
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		if (!visible || !active || onClick == null) return;
		
		for (touch in FlxG.touches.list)
		{
			if (_lastTouchId == -1)
			{
				if (touch.justPressed && touch.overlaps(this))
				{
					_lastTouchId = touch.touchPointID;
					onClick();
					break;
				}
			}
			else if (_lastTouchId == touch.touchPointID && !touch.pressed)
			{
				_lastTouchId = -1;
			}
		}
		#end
	}

	/**
	 * A function to create
	 */
	public static function create(camera:FlxCamera, ?onClick:Void->Void):PauseButton
	{
		var btn = new PauseButton(0, 0, onClick);
		btn.cameras = [camera];
		return btn;
	}
}