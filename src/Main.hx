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
			displayIsScaled: true
		});

		var assets = new Assets({
			fonts: [],
			images: ["assets/ldtk/tracks/beach-proto-32.png"]
		});

		gum.changeLoop(new Scenes(assets));
	}
}

class Scenes extends SceneManager {
	public function new(assets:Assets) {
		super(assets, loop -> return new GetawayScene(this));
	}
}

class TestScene extends Scene {
	override function create() {
		// first need a shape renderer to draw shapes with
		var shapes = sceneManager.stage.createShapeRenderLayer("shapes");

		// init a new shape to show a graphic on screen
		var x = Std.int(sceneManager.stage.centerX());
		var y = Std.int(sceneManager.stage.centerY());
		var w = 320;
		var h = 32;
		var shape = shapes.makeShape(x, y, w, h, RECT, Color.BLUE);

		// init a new echo body to animate the shape with
		var body = new Body({
			shape: {
				width: w,
				height: h,
			},
			kinematic: true,
			mass: 1,
			x: x,
			y: y,
			rotational_velocity: 30,
		});

		// bind body on_move to graphic position
		body.on_move = (x, y) -> {
			shape.setPosition(x, y);
		};

		// bind body rotation to graphic rotation
		body.on_rotate = r -> {
			shape.rotation = r;
		};

		// add body to world or it will do nothing
		sceneManager.world.add(body);

		// bind a key to reset the scene
		sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.changeScene(new TestScene(sceneManager)));
	}

	override function destroy() {}

	override function update(elapsedSeconds:Float) {}
}
