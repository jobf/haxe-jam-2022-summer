package pieces;

import tyke.Graphics;
import tyke.Loop.CountDown;
import echo.World;
import echo.Body;

class Vehicle {
	public var body(default, null):Body;
	var geometry:RectangleGeometry;
	
	var forwards:Accelerator;
	var backwards:Accelerator;
	
	var yIncrement:Float = 120;

	public function new(geometry:RectangleGeometry, world:World) {
		this.geometry = geometry;
		body = new Body({
			shape: {
				width: geometry.width,
				height: geometry.height,
			},
			kinematic: true,
			mass: 1,
			x: geometry.x,
			y: geometry.y,
			max_velocity_x: 200, // stop the vehicle going too fast
			rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
		});

		// track geometry with body movement
		body.on_move = (x, y) -> {
			geometry.x = Std.int(x);
			geometry.y = Std.int(y);
		};

		// register body in physics simulation
		world.add(body);

		// init acceleration logic
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
		
		if(buttonIsDown) {
			body.velocity.y -= yIncrement;
		} else {
			body.velocity.y = 0;
		}
	}

	public function controlDown(buttonIsDown:Bool) {
		trace('controlDown ${formatButtonIsDown(buttonIsDown)}');
		
		if(buttonIsDown) {
			body.velocity.y += yIncrement;
		} else {
			body.velocity.y = 0;
		}
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
		// trace('applyAcceleration $label');
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
