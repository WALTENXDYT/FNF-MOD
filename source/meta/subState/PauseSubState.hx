package meta.subState;

import gameObjects.HealthIcon;
import gameObjects.font.Alphabet;
import meta.data.Controls.Control;
import meta.data.ClientPrefs;
import meta.data.Highscore;
import meta.data.Song;
import meta.state.PlayState;
import meta.state.MusicBeatState;
import meta.state.menus.StoryMenuState;
import meta.state.menus.FreeplayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var pauseOptions = [];
	var curSelected:Int = 0;

	var pausebg1:FlxSprite;
	var pausebg2:FlxSprite;
	var disk:FlxSprite;
	var diskbg:FlxSprite;
	var diskfg:FlxSprite;
	var icon:HealthIcon;
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var opponentText:FlxText;

	public function new(x:Float, y:Float)
	{
		super();
		if (CoolUtil.difficulties.length < 2)
			menuItemsOG.remove('Change Difficulty'); // No need to change difficulty if there is only one!

		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Toggle Practice Mode');
			menuItemsOG.insert(3, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length)
		{
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		if (!ClientPrefs.lowQuality)
		{
			var dadcolor = FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1],
				PlayState.instance.dad.healthColorArray[2]);

			var bfcolor = FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1],
				PlayState.instance.boyfriend.healthColorArray[2]);

			pausebg1 = new FlxSprite().loadGraphic(Paths.image('PauseMenuSprites/hoverleft'));
			pausebg1.updateHitbox();
			pausebg1.screenCenter();
			pausebg1.antialiasing = ClientPrefs.globalAntialiasing;
			if (!PlayState.instance.opponentChart)
				pausebg1.color = dadcolor;
			else
				pausebg1.color = bfcolor;
			add(pausebg1);
			pausebg1.x = -400;
			pausebg1.alpha = 0;
			FlxTween.tween(pausebg1, {
				x: 0,
				alpha: 1
			}, 1.3, {ease: FlxEase.quadOut});

			pausebg2 = new FlxSprite().loadGraphic(Paths.image('PauseMenuSprites/hoverright-720p')); // kill me
			pausebg2.updateHitbox();
			pausebg2.antialiasing = ClientPrefs.globalAntialiasing;
			if (!PlayState.instance.opponentChart)
				pausebg2.color = dadcolor;
			else
				pausebg2.color = bfcolor;
			add(pausebg2);
			pausebg2.x += 200;
			pausebg2.y += 200;
			pausebg2.alpha = 0;
			FlxTween.tween(pausebg2, {
				x: 0,
				y: 0,
				alpha: 1
			}, 1.3, {ease: FlxEase.quadOut});

			diskbg = new FlxSprite(FlxG.width - 350, FlxG.height - 390).loadGraphic(Paths.image('PauseMenuSprites/disk-bg'));
			diskbg.antialiasing = ClientPrefs.globalAntialiasing;
			add(diskbg);

			disk = new FlxSprite(FlxG.width - 348, FlxG.height - 338).loadGraphic(Paths.image('PauseMenuSprites/disk'));
			disk.antialiasing = ClientPrefs.globalAntialiasing;
			add(disk);

			if (!PlayState.instance.opponentChart)
				icon = new HealthIcon(PlayState.instance.dad.healthIcon);
			else
				icon = new HealthIcon(PlayState.instance.boyfriend.healthIcon);
			iconanimation();
			icon.setGraphicSize(Std.int(icon.width * 1.7));
			icon.antialiasing = ClientPrefs.globalAntialiasing;
			icon.x = FlxG.width - 230;
			icon.y = FlxG.height - 180;
			icon.flipX = true;
			icon.scrollFactor.set();
			add(icon);
			icon.x += 140;
			icon.y += 120;
			icon.alpha = 0;
			FlxTween.tween(icon, {
				x: icon.x - 150,
				y: icon.y - 170,
				alpha: 1
			}, 0.8, {ease: FlxEase.quadOut});

			diskfg = new FlxSprite(FlxG.width - 200, FlxG.height - 380).loadGraphic(Paths.image('PauseMenuSprites/idk'));
			diskfg.antialiasing = ClientPrefs.globalAntialiasing;
			add(diskfg);
		}

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blue balled: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		opponentText = new FlxText(20, 15 + 96, 0, "OPPONENT MODE", 32);
		opponentText.scrollFactor.set();
		opponentText.setFormat(Paths.font('vcr.ttf'), 32);
		opponentText.y = opponentText.y - 5;
		opponentText.alpha = 0;
		opponentText.updateHitbox();
		opponentText.visible = PlayState.instance.opponentChart;
		add(opponentText);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		opponentText.x = FlxG.width - (opponentText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(opponentText, {alpha: 1, y: opponentText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function iconanimation()
	{
		if (PlayState.instance.healthBar.percent > 85)
			icon.animation.curAnim.curFrame = 1;
		else if (PlayState.instance.healthBar.percent < 20)
			icon.animation.curAnim.curFrame = 2;
		else
			icon.animation.curAnim.curFrame = 0;
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		if (!ClientPrefs.lowQuality)
			disk.angle -= 0.45 / (ClientPrefs.framerate / 60);

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			if (daSelected != 'BACK' && difficultyChoices.contains(daSelected))
			{
				var name:String = PlayState.SONG.song.toLowerCase();
				var poop = Highscore.formatSong(name, curSelected);
				PlayState.SONG = Song.loadFromJson(poop, name);
				PlayState.storyDifficulty = curSelected;
				MusicBeatState.resetState();
				FlxG.sound.music.volume = 0;
				PlayState.changedDifficulty = true;
				PlayState.chartingMode = false;
				return;
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;

				case "Options":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					MusicBeatState.switchState(new options.OptionsState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if (PlayState.isStoryMode)
					{
						MusicBeatState.switchState(new StoryMenuState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					if (ClientPrefs.useClassicSongs)
					{
						FlxG.sound.playMusic(Paths.music('freakyMenuC'));
					}
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;

				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
