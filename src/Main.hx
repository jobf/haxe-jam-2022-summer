import scenes.EndScene;
import scenes.BaseScene;
import lime.ui.MouseButton;
import tyke.Graphics.RectangleGeometry;
import tyke.Loop.Text;
import tyke.jam.EchoUi.ButtonConfig;
import tyke.jam.EchoUi.ClickHandler;
import tyke.jam.EchoUi.ButtonGrid;
import tyke.Loop.Glyphs;
import scenes.TitleScreen;
import scenes.GetawayScene;
import lime.ui.KeyCode;
import echo.Body;
import peote.view.Color;
import tyke.jam.Scene;
import ob.gum.backends.PeoteView;
import ob.gum.Core;
import lime.ui.Window;
import ob.gum.backends.Lime;

class Main extends App {
	override function init(window:Window, ?config:GumConfig) {
    super.init(window, {
			framesPerSecond: 30,
			drawOnlyWhenRequested: false,
			displayWidth: 640,
			displayHeight: 360,
			displayIsScaled: false
		});

		var assets = new Assets({
			fonts: ["assets/fonts/tiled/hack_ascii.json"],
			images: [
				"assets/ldtk/tracks/track-tiles-32.png",
				"assets/ldtk/tracks/sprites-32.png",
				"assets/ldtk/tracks/sprites-96.png"]
		});

		gum.changeLoop(new Scenes(assets));
	}
}

class Scenes extends SceneManager {
	public function new(assets:Assets) {
		final levelWidth = 8192;
		// super(assets, loop -> return new TestScene(this), levelWidth);
		// super(assets, loop -> return new GetawayScene(this), levelWidth);
		super(assets, loop -> return new TitleScreen(this), levelWidth);
		// super(assets, loop -> return new EndScene(this), levelWidth);
	}
}

class TestScene extends BaseScene {
	var clickHandler:ClickHandler;
	var cursor:Body;

	override function create() {
		super.create();

		// first need a shape renderer to draw shapes with
		var shapes = sceneManager.stage.createShapeRenderLayer("shapes");
		cursor = new Body({
			shape: {
				solid: false,
				width: 3,
				height: 3,
			},
			kinematic: true,
			x: 0,
			y: 0,
		});

		clickHandler = new ClickHandler(cursor, sceneManager.world);

		var buttonConfigs:Array<ButtonConfig> = [
			{
				text: "click",
				action: entity -> trace('click')
			},
			{
				text: "clack",
				action: entity -> trace('clack')
			}
		];
		var containerGeometry:RectangleGeometry = {
			y: 0,
			x: 0,
			width: 640,
			height: 360
		};

		var rowsInGrid = 2;
		var columnsInGrid = 1;
		var margin = 10;

		var buttonGrid = new ButtonGrid(clickHandler, shapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid, columnsInGrid);
		// bind a key to reset the scene
		sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.changeScene(new TestScene(sceneManager)));
	}

	override function destroy() {}

	override function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);
		// sceneManager.world.step(elapsedSeconds);
	}

	override function onMouseDown(x:Float, y:Float, button:MouseButton) {
		super.onMouseDown(x, y, button);
		clickHandler.onMouseDown();
	}

	override function onMouseMove(x:Float, y:Float) {
		super.onMouseMove(x, y);
		cursor.set_position(x, y);
	}
}
