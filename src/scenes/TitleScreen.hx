package scenes;

import input.MenuController;
import peote.view.Color;
import scenes.BaseScene;
import tyke.Graphics.RectangleGeometry;
import tyke.jam.EchoUi.ButtonConfig;
import tyke.jam.EchoUi.ButtonGrid;
import scenes.GetawayScene;

class TitleScreen extends BaseScene {
	var controller:MenuController;

	override function create() {
		super.create();

		@:privateAccess
		controller = new MenuController(sceneManager.gum.window, () -> startGame());

		var buttonConfigs:Array<ButtonConfig> = [
			{
				text: "Play",
				action: entity -> startGame(),
				color: Color.GREY6
			}
		];

		var containerGeometry:RectangleGeometry = {
			y: 360 - 120,
			x: 0,
			width: 625,
			height: 170
		};

		var rowsInGrid = 2;
		var columnsInGrid = 1;
		var margin = 10;

		var buttonGrid = new ButtonGrid(clickHandler, uiShapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid,
			columnsInGrid);


		// need to enable controller before it will respond 
		controller.enable();
	}

	function startGame() {
		sceneManager.changeScene(new GetawayScene(sceneManager));
	}

	override function destroy() {
		// clean up controller
		controller.disable();
	}
}
