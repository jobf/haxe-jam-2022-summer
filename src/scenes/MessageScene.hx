package scenes;

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

class MessageScene extends BaseScene {
	var clickHandler:ClickHandler;
	var cursor:Body;
	var initNextScene:Void->Scene;
	var message:String;

	public function new(sceneManager:SceneManager, message:String, initNextScene:Void->Scene){
		super(sceneManager);
		this.message = message;
		this.initNextScene = initNextScene;
	}

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
				text: message,
				action: entity -> return
			},
			{
				text: "Continue",
				action: entity -> sceneManager.changeScene(initNextScene())
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
		// sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.changeScene(new TestScene(sceneManager)));
	}

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