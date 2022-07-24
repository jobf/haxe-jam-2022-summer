package pieces;

import tyke.Loop.CountDown;
import echo.World;
import echo.Body;

class Vehicle {
	public var body(default, null):Body;
	var accelerationCountDown:CountDown;

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

		accelerationCountDown = new CountDown(0.25, () -> applyAcceleration(), true);
	}

	inline function formatButtonIsDown(buttonIsDown:Bool):String {
		return buttonIsDown ? "press" : "release";
	}

	public function controlAccelerate(buttonIsDown:Bool) {
		trace('controlAccelerate ${formatButtonIsDown(buttonIsDown)}');
		
		accelerationIsActive = buttonIsDown;
		
		if (buttonIsDown) {
			accelerationCountDown.reset();
			increaseVelocityX();
		}
	}

	var accelerationIsActive:Bool;
	function applyAcceleration() {
		trace('applyAcceleration');
		if(accelerationIsActive){
			increaseVelocityX();
		}
	}

	var accelerationIncrement = 50;
	function increaseVelocityX() {
		trace('increaseVelocityX');
		body.velocity.x += accelerationIncrement;
	}


	public function controlReverse(buttonIsDown:Bool) {
		trace('controlReverse ${formatButtonIsDown(buttonIsDown)}');
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



	public function update(elapsedSeconds:Float){
		accelerationCountDown.update(elapsedSeconds);
	}

}
