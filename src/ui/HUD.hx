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

		enemiesSprite = iconSprites.makeSprite(enemiesIconX, y, tileSize, enemiesIconTileId);
		healthText = fontProgram.createLine("00", enemiesIconX + tileSize, y);

		healthSprite = iconSprites.makeSprite(healthIconX, y, tileSize, healthIconTileId);
		enemiesText = fontProgram.createLine("00", healthIconX + tileSize, y);

		endSprite = iconSprites.makeSprite(endIconX, y, tileSize, finishIconTileId);
		endText = fontProgram.createLine("00", endIconX + tileSize, y);
	}
}
