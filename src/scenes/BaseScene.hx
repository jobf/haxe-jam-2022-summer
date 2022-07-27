package scenes;

import tyke.jam.EchoUi;
import pieces.BasePiece.PieceCore;
import tyke.Loop.Text;
import tyke.Loop.Glyphs;
import tyke.Graphics;
import tyke.Graphics.SpriteRenderer;
import lime.ui.KeyCode;
import lime.ui.MouseButton;
import tyke.jam.Scene;
import echo.Body;

class BaseScene extends Scene {
	var tileSize:Int;
	var beachTiles:SpriteRenderer;
	var sprites:SpriteRenderer;
	var largeSprites:SpriteRenderer;
	var mouseCursorBody:Body;
	var uiShapes:ShapeRenderer;
	var text:Text;
	var clickHandler:ClickHandler;
	var beachTilesLayer:Layer;
	var iconSprites:SpriteRenderer;
	var debugShapes:ShapeRenderer;
	var pieceCore:PieceCore;

	override function create() {
		initGameGraphics();

		initUiGraphics();

		// bind a key to reset the scene
		sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.resetScene());

		pieceCore = {
			world: sceneManager.world,
			tiles: largeSprites,
			shapes: debugShapes,
			peoteView: sceneManager.peoteView
		};

		trace('BaseScene initialized');
	}

	inline function initGameGraphics(){
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
	}

	inline function initUiGraphics() {
		// a shape renderer to draw uiShapes with
		uiShapes = sceneManager.stage.createShapeRenderLayer("uiShapes");
		mouseCursorBody = new Body({
			shape: {
				solid: false,
				width: 3,
				height: 3,
			},
			kinematic: true,
			x: 0,
			y: 0,
		});

		// handler for mouse clicks
		clickHandler = new ClickHandler(mouseCursorBody, sceneManager.world);

		// glyphs for writing text
		text = Glyphs.initText(sceneManager.display, sceneManager.assets.fontCache[0]);
		text.fontProgram.fontStyle.bgColor = 0x00000000;
		text.fontProgram.fontStyle.color = 0x00000070;
	}


	override function onMouseDown(x:Float, y:Float, button:MouseButton) {
		super.onMouseDown(x, y, button);
		clickHandler.onMouseDown();
	}

	override function onMouseMove(x:Float, y:Float) {
		super.onMouseMove(x, y);
		mouseCursorBody.set_position(x, y);
	}
}
