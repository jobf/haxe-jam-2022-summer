package pieces;

import echo.Collider;
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

	var groundY:Float;
	var isJumping:Bool = false;
	var isColliding:Bool = false;


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
			max_velocity_x: 300, // stop the vehicle going too fast
			rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
		});

		// track geometry with body movement
		body.on_move = (x, y) -> {
			geometry.x = Std.int(x);
			geometry.y = Std.int(y);
		};

		// register body in physics simulation
		world.add(body);

		// store reference to Collider helper class for use in collisions
		body.collider = new Collider(VEHICLE, body -> collideWith(body));

		// init acceleration logic
		forwards = new Accelerator(body, 50);
		backwards = new Accelerator(body, -50);
	}

	inline function formatButtonIsDown(buttonIsDown:Bool):String {
		return buttonIsDown ? "press" : "release";
	}

	public function controlAccelerate(buttonIsDown:Bool) {
		// trace('controlAccelerate ${formatButtonIsDown(buttonIsDown)}');

		forwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			forwards.reset();
			forwards.increaseVelocityX();
		}
	}

	public function controlReverse(buttonIsDown:Bool) {
		// trace('controlReverse ${formatButtonIsDown(buttonIsDown)}');

		backwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			backwards.reset();
			backwards.increaseVelocityX();
		}
	}

	public function controlUp(buttonIsDown:Bool) {
		// trace('controlUp ${formatButtonIsDown(buttonIsDown)}');

		if (buttonIsDown) {
			body.velocity.y -= yIncrement;
		} else {
			body.velocity.y = 0;
		}
	}

	public function controlDown(buttonIsDown:Bool) {
		// trace('controlDown ${formatButtonIsDown(buttonIsDown)}');

		if (buttonIsDown) {
			body.velocity.y += yIncrement;
		} else {
			body.velocity.y = 0;
		}
	}

	public function controlAction(buttonIsDown:Bool) {
		// trace('controlAction ${formatButtonIsDown(buttonIsDown)}');
	}

	public function update(elapsedSeconds:Float) {
		forwards.update(elapsedSeconds);
		backwards.update(elapsedSeconds);
		if (isJumping) {
			if (body.y >= groundY) {
				land();
			}
		}
	}

	inline function stop() {
		body.velocity.x = 0;
		body.velocity.y = 0;
	}

	function collideWith(body:Body) {
		if (!isColliding) {
			isColliding = true;
			trace('vehicle collide ${body.collider.type}');
			switch body.collider.type {
				case HOLE:
					fallInHole();
				case RAMP:
					jump();
				case _:
					isColliding = false;
			}
		}
	}

	function fallInHole() {
		trace('fall in hole');
		forwards.canMove = false;
		backwards.canMove = false;
		stop();
	}

	function jump() {
		if (!isJumping) {
			trace('jump');
			groundY = body.y;
			final trajectoryY = -50;
			body.velocity.set(body.velocity.x, trajectoryY);
			body.kinematic = false;
			isJumping = true;
		}
	}

	inline function land() {
		trace('land');
		body.y = groundY;
		body.velocity.y = 0;
		isJumping = false;
		body.kinematic = true;
		isColliding = false;
	}
}

class Accelerator {
	public var accelerationIsActive:Bool;

	public var canMove:Bool;

	var accelerationCountDown:CountDown;
	var accelerationIncrement:Float;
	var body:Body;
	var label:String;

	public function new(body:Body, accelerationIncrement:Float) {
		this.body = body;

		this.accelerationIncrement = accelerationIncrement;
		this.label = this.accelerationIncrement > 0 ? "forwards" : "reverse";
		accelerationCountDown = new CountDown(0.25, () -> applyAcceleration(), true);
		canMove = true;
	}

	public function applyAcceleration() {
		// trace('applyAcceleration $label');
		if (accelerationIsActive) {
			increaseVelocityX();
		}
	}

	public function increaseVelocityX() {
		if (canMove) {
			// trace('increaseVelocityX $label');
			body.velocity.x += accelerationIncrement;
		}
	}

	public function update(elapsedSeconds:Float) {
		accelerationCountDown.update(elapsedSeconds);
	}

	public function reset() {
		accelerationCountDown.reset();
	}
}
