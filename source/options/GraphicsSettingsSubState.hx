package options;

import meta.data.ClientPrefs;
#if desktop
import meta.data.Discord.DiscordClient;
#end
import meta.state.MusicBeatState;
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import meta.data.Controls;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Tweaking the Graphics'; // for Discord Rich Presence

		var option:Option = new Option('Auto Pause', "Whether or not to pause the game automatically when the window is unfocused", 'autoPause', 'bool', true);
		option.onChange = onChangeAutoPause;
		addOption(option);

		#if !mobile
		var option:Option = new Option('FPS Counter', "Whether to display the FPS Counter.", 'showFPS', 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('FPS Cap', "Define your maximum FPS.", 'framerate', 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Hide Girlfriend', "Whether to Hide or Show Girlfriend on Stages, this does not apply if GF is the opponent", 'hideGf',
			'bool', false);
		addOption(option);

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', // Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
			'lowQuality', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Max Optimization',
			'If checked, disables backgrounds, characters, and anything related to those in order to increase performance, this does not apply for Mods, or any HUD elements (such as Icons and Note Splashes).',
			'maxOptimization', 'bool', false);
		addOption(option);

		var option:Option = new Option('Memory Counter', "Whether to display approximately how much memory is being used.", 'memCounter', 'bool', false);
		// addOption(option);

		var option:Option = new Option('Memory Peak Counter', "Whether to display the highest memory value used.", 'memPeak', 'bool', false);
		// addOption(option);

		var option:Option = new Option('Show Current State', "Whether to display the current state/substate of the game (example: GraphicsSettingsSubState).",
			'showState', 'bool', false);
		addOption(option);

		#if desktop //no need for this at other platforms cuz only desktop has fullscreen as false by default
		var option:Option = new Option('Screen Resolution',
			'Choose your preferred screen resolution.',
			'screenRes',
			'string',
			'1280x720',
			['640x360', '852x480', '960x540', '1280x720', '1920x1080', '3840x2160', '7680x4320']);
		addOption(option);
		option.onChange = onChangeScreenRes;
		#end

		super();
	}

	function onChangeScreenRes()
	{
		var res = ClientPrefs.screenRes.split('x');

		if(!FlxG.fullscreen)
			FlxG.resizeWindow(Std.parseInt(res[0]), Std.parseInt(res[1]));

		Main.gameWidth = Std.parseInt(res[0]);
		Main.gameHeight = Std.parseInt(res[1]);
		FlxG.scaleMode = MusicBeatState.modeStage;
	}

	function onChangeAutoPause()
	{
		FlxG.autoPause = ClientPrefs.autoPause;
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end

	function onChangeFramerate()
	{
		if (ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}
