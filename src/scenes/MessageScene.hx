package scenes;

import peote.view.Color;
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
				action: entity -> return,
				color: Color.GREY4
			},
			{
				text: "Continue",
				action: entity -> sceneManager.changeScene(initNextScene()),
				color: Color.GREY6
			}
		];
		var containerGeometry:RectangleGeometry = {
			y: 0,
			x: 0,
			width: 625,
			height: 350
		};

		var rowsInGrid = 2;
		var columnsInGrid = 1;
		var margin = 10;

		var buttonGrid = new ButtonGrid(clickHandler, uiShapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid,columnsInGrid);
	}
}
