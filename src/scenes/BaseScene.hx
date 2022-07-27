package scenes;

import pieces.BasePiece.PieceCore;
import tyke.Loop.Text;
import tyke.Loop.Glyphs;
import tyke.Graphics;
import tyke.Graphics.SpriteRenderer;
import input.Controller;
import lime.ui.KeyCode;
import tyke.Echo.EchoDebug;
import tyke.jam.Scene;

class BaseScene extends Scene {
	var tileSize:Int;
	var beachTiles:SpriteRenderer;
	var sprites:SpriteRenderer;
	var largeSprites:SpriteRenderer;
	var text:Text;
	var beachTilesLayer:Layer;
	var iconSprites:SpriteRenderer;
	var debugShapes:ShapeRenderer;
	var controller:Controller;
	var pieceCore:PieceCore;

	override function create() {
		tileSize = 32;

		// renderer for beach tiles
		beachTiles = sceneManager.stage.createSpriteRendererLayer("beachTiles", sceneManager.assets.imageCache[0], tileSize);
		beachTilesLayer = sceneManager.stage.getLayer("beachTiles");

		// renderer for sprites 32x32 - NB not actually used anymore
		sprites = sceneManager.stage.createSpriteRendererLayer("sprites", sceneManager.assets.imageCache[1], tileSize);

        // renderer for main game sprites (96x96 pixel)
		largeSprites = sceneManager.stage.createSpriteRendererLayer("largeSprites", sceneManager.assets.imageCache[2], 96);

        // renderer for icon sprites
        iconSprites = sceneManager.stage.createSpriteRendererLayer("iconSprites", sceneManager.assets.imageCache[3], 32, false, true);

		// renderer for body debugging
		debugShapes = sceneManager.stage.createShapeRenderLayer("debugShapes");
        
		// for writing messages
		text = Glyphs.initText(sceneManager.display, sceneManager.assets.fontCache[0]);

		// bind a key to reset the scene
		sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.resetScene());

		@:privateAccess
		controller = new Controller(sceneManager.gum.window);

		pieceCore = {
			world: sceneManager.world,
			tiles: largeSprites,
			shapes: debugShapes,
			peoteView: sceneManager.peoteView
		};

		trace('BaseScene initialized');
	}

	override function destroy() {
		controller.disable();
	}

	override function update(elapsedSeconds:Float) {}
}
