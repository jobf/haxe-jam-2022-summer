package ui;

import peote.text.Line;
import ob.gum.backends.PeoteView;
import peote.text.FontProgram;
import tyke.Graphics;

class HUD {
	var iconSprites:SpriteRenderer;
	var fontProgram:FontProgram<FontStyle>;

	var enemiesSprite:Sprite;
	var enemiesText:Line<FontStyle>;

	var healthSprite:Sprite;
	var healthText:Line<FontStyle>;

	var endSprite:Sprite;
	var endText:Line<FontStyle>;

	public function new(iconSprites:SpriteRenderer, fontProgram:FontProgram<FontStyle>) {
		this.iconSprites = iconSprites;
		this.fontProgram = fontProgram;

		final enemiesIconTileId = 0;
		final healthIconTileId = 8;
		final finishIconTileId = 16;

		final tileSize = 32;
		final top = 3;
		final halfTileSize = Std.int(tileSize * 0.5);
		final y = top + halfTileSize;

		var enemiesIconX = 174 + halfTileSize;
		var healthIconX = 304 + halfTileSize;
		var endIconX = 418 + halfTileSize;

		healthSprite = iconSprites.makeSprite(healthIconX, y, tileSize, healthIconTileId);
		healthText = fontProgram.createLine(formatNumber(0), healthIconX + tileSize, y);
        
		enemiesSprite = iconSprites.makeSprite(enemiesIconX, y, tileSize, enemiesIconTileId);
		enemiesText = fontProgram.createLine(formatNumber(0), enemiesIconX + tileSize, y);

		endSprite = iconSprites.makeSprite(endIconX, y, tileSize, finishIconTileId);
		endText = fontProgram.createLine("00", endIconX + tileSize, y);
	}

    inline function formatNumber(number:Int):String{
        if(number >= 100){
            number = 99;
        }
        return StringTools.lpad('$number', "0", 2);
    }

	public function updateEndText(playerX:Float, finishLineX:Int) {
		var percentComplete = Std.int((playerX / finishLineX) * 100);
		fontProgram.lineSetChars(endText, formatNumber(percentComplete));
		fontProgram.updateLine(endText);
	}

	public function updateHealthText(remainingCrashes:Int) {
        fontProgram.lineSetChars(healthText, formatNumber(remainingCrashes));
		fontProgram.updateLine(healthText);
    }

	public function updateEnemiesText(totalEnemiesRemaining:Int) {
        fontProgram.lineSetChars(enemiesText, formatNumber(totalEnemiesRemaining));
		fontProgram.updateLine(enemiesText);
    }
}
