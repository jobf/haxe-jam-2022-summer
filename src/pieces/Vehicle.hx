package pieces;

import tyke.Loop.CountDown;
import echo.World;
import echo.Body;

class Vehicle {
	public var body(default, null):Body;

	var forwards:Accelerator;
	var backwards:Accelerator;

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
			max_velocity_x: 200, // stop the vehicle going too fast
			rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
		});

		world.add(body);
		forwards = new Accelerator(body, 50);
		backwards = new Accelerator(body, -50);
	}

	inline function formatButtonIsDown(buttonIsDown:Bool):String {
		return buttonIsDown ? "press" : "release";
	}

	public function controlAccelerate(buttonIsDown:Bool) {
		trace('controlAccelerate ${formatButtonIsDown(buttonIsDown)}');

		forwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			forwards.reset();
			forwards.increaseVelocityX();
		}
	}

	public function controlReverse(buttonIsDown:Bool) {
		trace('controlReverse ${formatButtonIsDown(buttonIsDown)}');

		backwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			backwards.reset();
			backwards.increaseVelocityX();
		}
	}

	public function controlUp(buttonIsDown:Bool) {
		trace('controlUp ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlDown(buttonIsDown:Bool) {
		trace('controlDown ${formatButtonIsDown(buttonIsDown)}');
	}

	public function controlAction(buttonIsDown:Bool) {
		trace('controlAction ${formatButtonIsDown(buttonIsDown)}');
	}

	public function update(elapsedSeconds:Float) {
		forwards.update(elapsedSeconds);
		backwards.update(elapsedSeconds);
	}
}

class Accelerator {
	public var accelerationIsActive:Bool;

	var accelerationCountDown:CountDown;
	var accelerationIncrement:Float;
	var body:Body;
	var label:String;

	public function new(body:Body, accelerationIncrement:Float) {
		this.body = body;
		this.accelerationIncrement = accelerationIncrement;
		this.label = this.accelerationIncrement > 0 ? "forwards" : "reverse";
		accelerationCountDown = new CountDown(0.25, () -> applyAcceleration(), true);
	}

	public function applyAcceleration() {
		trace('applyAcceleration $label');
		if (accelerationIsActive) {
			increaseVelocityX();
		}
	}

	public function increaseVelocityX() {
		trace('increaseVelocityX $label');
		body.velocity.x += accelerationIncrement;
	}

	public function update(elapsedSeconds:Float) {
		accelerationCountDown.update(elapsedSeconds);
	}

	public function reset() {
		accelerationCountDown.reset();
	}
}
