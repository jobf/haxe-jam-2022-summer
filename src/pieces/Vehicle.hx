package pieces;

import peote.view.PeoteView;
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

	var verticalVelocity:Float = 120;

	public var isControllingVertical(default, null):Bool = false;

	var jumpVelocity = -90;

	var groundY:Float;
	var isOnGround:Bool = true;
	var isJumpInProgress:Bool = false;

	var isColliding:Bool = false;
	var minY:Int;
	var maxY:Int;
	var defaultMaxVelocityX = 400;
	var isCrashed:Bool = false;
	var isExpired:Bool = false;
	var crashesRemaining:Int;
	var sprite:Sprite;
	var onExpire:Vehicle->Void;

	var peoteView:PeoteView;

	var isParking:Bool;

	public function new(geometry:RectangleGeometry, world:World, peoteView:PeoteView, sprite:Sprite, minY:Int, maxY:Int, onExpire:Vehicle->Void, crashesRemaining:Int = 1) {
		this.minY = minY;
		this.maxY = maxY;
		this.crashesRemaining = crashesRemaining;
		this.geometry = geometry;
		this.sprite = sprite;
		this.onExpire = onExpire;
		this.peoteView = peoteView;
		body = new Body({
			shape: {
				width: geometry.width,
				height: geometry.height,
			},
			kinematic: false,
			mass: 1,
			x: geometry.x,
			y: geometry.y,
			material: {
				gravity_scale: 0,
			},
			max_velocity_x: defaultMaxVelocityX, // stop the vehicle going too fast
			rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
		});

		// set initial ground position
		groundY = geometry.y;

		// track geometry with body movement
		body.on_move = (x, y) -> {
			geometry.x = Std.int(x);
			geometry.y = Std.int(y);
			sprite.setPosition(x, y);
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
		if (!isOnGround) {
			return;
		}

		backwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			backwards.reset();
			backwards.increaseVelocityX();
		}
	}

	public function controlUp(buttonIsDown:Bool) {
		// trace('controlUp ${formatButtonIsDown(buttonIsDown)}');
		if (!isOnGround) {
			return;
		}

		if (buttonIsDown) {
			isControllingVertical = true;
			body.velocity.y = -verticalVelocity;
		} else {
			stopVerticalMovement();
		}

		// keep track of y position while grounded (used to know position to land)
		groundY = body.y;
	}

	public function controlDown(buttonIsDown:Bool) {
		// trace('controlDown ${formatButtonIsDown(buttonIsDown)}');
		if (!isOnGround) {
			return;
		}

		if (buttonIsDown) {
			isControllingVertical = true;
			body.velocity.y = verticalVelocity;
		} else {
			stopVerticalMovement();
		}

		// keep track of y position while grounded (used to know position to land)
		groundY = body.y;
	}

	inline function stopVerticalMovement() {
		isControllingVertical = false;
		body.velocity.y = 0;

		// keep track of y position while grounded (used to know position to land)
		groundY = body.y;
	}

	public function controlAction(buttonIsDown:Bool) {
		// trace('controlAction ${formatButtonIsDown(buttonIsDown)}');
	}

	public function update(elapsedSeconds:Float) {
		if (isExpired) {
			return;
		}

		if (isOnGround) {
			if (isControllingVertical) {
				// limit vertical movement if moving that way
				if (body.y <= minY) {
					stopVerticalMovement();
				}
				if (body.y >= maxY) {
					stopVerticalMovement();
				}
			}

			forwards.update(elapsedSeconds);
			backwards.update(elapsedSeconds);
		} else {
			// here we are off the ground (jumping)
			if (body.y >= groundY + 5) {
				// if we hit the last ground position need to land
				land();
			}
		}
	}

	inline function stop() {
		body.velocity.x = 0;
		body.velocity.y = 0;
	}

	public function resetMaxVelocityX() {
		body.velocity.x = defaultMaxVelocityX;
	}

	function collideWith(body:Body) {
		// trace('vehicle collide ${body.collider.type}');
		switch body.collider.type {
			case HOLE:
				fallInHole();
			case RAMP:
				jump();
			case VEHICLE:
				crash();
			case _:
				return;
		}
	}

	function fallInHole() {
		if (isColliding || isParking) {
			return;
		}

		if (isOnGround) {
			trace('fall in hole');
			isColliding = true;
			forwards.canMove = false;
			backwards.canMove = false;
			stop();
			onExpire(this);
		}
	}

	function jump() {
		if(isParking){
			return;
		}

		if (isOnGround) {
			isOnGround = false;
			isJumpInProgress = true;
			body.material.gravity_scale = 1;
			body.velocity.y = jumpVelocity;
			trace('jump');
		}
	}

	inline function land() {
		if (!isOnGround) {
			trace('landed');
			body.y = groundY;
			body.material.gravity_scale = 0;
			body.velocity.y = 0;
			isOnGround = true;
			isJumpInProgress = false;
			isColliding = false;
		}
	}

	function crash() {
		if (!isCrashed) {
			isCrashed = true;
			stop();
			crashesRemaining--;
			this.sprite.shake(peoteView.time);
		}
		if (crashesRemaining <= 0) {
			expire();
		}
	}

	function expire() {
		onExpire(this);
		isExpired = true;
	}

	public function destroy() {
		this.body.remove();
		this.sprite.visible = false;
	}
	public function parkAtSide() {
		trace('parkAtSide');
		isParking = true;
		body.y = minY + geometry.height + 1;
		stop();
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
