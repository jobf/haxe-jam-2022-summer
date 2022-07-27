package scenes;

import peote.view.Color;
import scenes.BaseScene;
import tyke.Graphics.RectangleGeometry;
import tyke.jam.EchoUi.ButtonConfig;
import tyke.jam.EchoUi.ButtonGrid;
import scenes.GetawayScene;

class EndScene extends BaseScene {

	override function create() {
		super.create();

		var buttonConfigs:Array<ButtonConfig> = [
			{
				text: "Play again",
				action: entity -> sceneManager.changeScene(new GetawayScene(sceneManager)),
				color: Color.GREY6
			}
		];
		var containerGeometry:RectangleGeometry = {
			y: 0,
			x: 0,
			width: 625,
			height: 360
		};

		var rowsInGrid = 2;
		var columnsInGrid = 1;
		var margin = 10;

		var buttonGrid = new ButtonGrid(clickHandler, uiShapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid, columnsInGrid);
	}
}