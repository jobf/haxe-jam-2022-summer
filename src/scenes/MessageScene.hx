package scenes;

import scenes.BaseScene;
import tyke.Graphics.RectangleGeometry;
import tyke.jam.EchoUi;
import tyke.jam.Scene;

class MessageScene extends BaseScene {
	var initNextScene:Void->Scene;
	var message:String;

	public function new(sceneManager:SceneManager, message:String, initNextScene:Void->Scene) {
		super(sceneManager);
		this.message = message;
		this.initNextScene = initNextScene;
	}

	override function create() {
		super.create();

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

		var buttonGrid = new ButtonGrid(clickHandler, uiShapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid,columnsInGrid);
	}
}
