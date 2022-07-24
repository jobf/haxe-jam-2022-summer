package pieces;

import echo.World;
import echo.Body;

class Vehicle {
	public var body(default, null):Body;

	public function new(x:Int, y:Int, world:World) {
		body = new Body({
			shape: {
				width: 32,
				height: 16,
			},
			kinematic: true,
			mass: 1,
			x: x,
			y: y,
			rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
		});

		world.add(body);
	}

	inline function formatButtonIsDown(buttonIsDown:Bool):String{
		return buttonIsDown ? "press" : "release";
	}

	public function controlAccelerate(buttonIsDown:Bool) {
		trace('control Accelerate ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlReverse(buttonIsDown:Bool) {
		trace('control Reverse ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlUp(buttonIsDown:Bool) {
		trace('control Up ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlDown(buttonIsDown:Bool) {
		trace('control Down ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlAction(buttonIsDown:Bool) {
		trace('control Action ${formatButtonIsDown(buttonIsDown)}');
	}
}
