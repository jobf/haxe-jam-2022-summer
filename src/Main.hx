import tyke.Graphics;
import tyke.jam.EchoUi;
import tyke.jam.Scene;
import ob.gum.backends.PeoteView;
import ob.gum.Core;
import lime.ui.Window;
import ob.gum.backends.Lime;
import scenes.EndScene;
import scenes.BaseScene;
import scenes.TitleScreen;
import scenes.GetawayScene;

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
				"assets/ldtk/tracks/sprites-96.png",
				"assets/png/icons-32.png"
			]
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

	override function create() {
		super.create();

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

		var buttonGrid = new ButtonGrid(clickHandler, uiShapes, text.fontProgram, sceneManager.world, buttonConfigs, containerGeometry, margin, rowsInGrid, columnsInGrid);
	}

}
