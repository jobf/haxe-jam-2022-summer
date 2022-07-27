package pieces;

import pieces.BasePiece;
import peote.view.PeoteView;
import echo.Collider;
import tyke.Graphics;
import tyke.Loop.CountDown;
import echo.World;
import echo.Body;

@:structInit
class VehicleOptions {
	public var minY:Int;
	public var maxY:Int;
	public var jumpVelocity:Float;
	public var verticalVelocity:Float;
	public var defaultMaxVelocityX:Float;
	public var crashesRemaining:Int;
	public var onExpire:Vehicle->Void;
}

class Vehicle extends BasePiece {
	public var isControllingVertical(default, null):Bool;
	var vehicleOptions:VehicleOptions;
	var groundY:Null<Float>;
	var forwards:Accelerator;
	var backwards:Accelerator;
	var slippingCountDown:CountDown;
	var isOnGround:Bool;
	var isExpired:Bool;
	var isSlipping:Bool;
	var isColliding:Bool;
	var isCrashed:Bool;
	var isParking:Bool;
	var isJumpInProgress:Bool;

	public function new(core:PieceCore, options:PieceOptions, vehicleOptions:VehicleOptions) {
		super(core, options);
		this.vehicleOptions = vehicleOptions;
		initVehicle();
	}

	inline function initVehicle() {
		// set initial ground position (used to determine where to land)
		groundY = options.bodyOptions.y;
		isOnGround = true;

		// init acceleration logic
		forwards = new Accelerator(body, 50);
		backwards = new Accelerator(body, -50);

		// init countdown used when vehicle is slipping
		slippingCountDown = new CountDown(2.0, () -> stopSlipping(), false);
	}

	inline function traceButtonState(name:String, buttonIsDown:Bool) {
		var state = buttonIsDown ? "press" : "release";
		trace('$name $state');
	}

	public function controlAccelerate(buttonIsDown:Bool) {
		// traceButtonState("controlAccelerate",buttonIsDown);

		forwards.accelerationIsActive = buttonIsDown;

		if (buttonIsDown) {
			forwards.reset();
			forwards.increaseVelocityX();
		}
	}

	public function controlReverse(buttonIsDown:Bool) {
		// traceButtonState("controlReverse",buttonIsDown);

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
		// traceButtonState("controlUp",buttonIsDown);

		if (!isOnGround) {
			return;
		}

		if (buttonIsDown) {
			isControllingVertical = true;
			body.velocity.y = -vehicleOptions.verticalVelocity;
		} else {
			stopVerticalMovement();
		}

		// keep track of y position while grounded (used to know position to land)
		groundY = body.y;
	}

	public function controlDown(buttonIsDown:Bool) {
		// traceButtonState("controlDown",buttonIsDown);

		if (!isOnGround) {
			return;
		}

		if (buttonIsDown) {
			isControllingVertical = true;
			body.velocity.y = vehicleOptions.verticalVelocity;
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
		// traceButtonState("controlAction",buttonIsDown);
	}

	override public function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);

		if (isExpired) {
			return;
		}

		if (isOnGround) {
			if (isSlipping) {
				// todo - fix this
				slippingCountDown.update(elapsedSeconds);
				// oscillate y position with sin wave
				var y = groundY + (Math.sin(core.peoteView.time) * 250);
				trace(y);
				body.y = groundY;
			} else {
				if (isControllingVertical) {
					// limit vertical movement if moving that way
					if (body.y <= vehicleOptions.minY) {
						stopVerticalMovement();
					}
					if (body.y >= vehicleOptions.maxY) {
						stopVerticalMovement();
					}
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

	public function resetMaxVelocityX() {
		body.velocity.x = vehicleOptions.defaultMaxVelocityX;
	}

	override function collideWith(body:Body) {
		super.collideWith(body);
		
		// trace('vehicle collide ${body.collider.type}');
		switch body.collider.type {
			case HOLE:
				fallInHole();
			case RAMP:
				jump();
			case VEHICLE:
				crash();
			case ROCK:
				// ensure expiry is triggered
				vehicleOptions.crashesRemaining = 0;
				crash();
			case SLICK:
				startSlipping();
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
			vehicleOptions.onExpire(this);
		}
	}

	function jump() {
		if (isParking) {
			return;
		}

		if (isOnGround) {
			isOnGround = false;
			isJumpInProgress = true;
			body.material.gravity_scale = 1;
			body.velocity.y = vehicleOptions.jumpVelocity;
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
			vehicleOptions.crashesRemaining--;
			this.sprite.shake(core.peoteView.time);
		}
		if (vehicleOptions.crashesRemaining <= 0) {
			expire();
		}
	}

	function expire() {
		vehicleOptions.onExpire(this);
		isExpired = true;
	}

	public function destroy() {
		this.body.remove();
		this.sprite.visible = false;
		this.debug.visible = false;
	}

	public function parkAtSide() {
		trace('parkAtSide');
		isParking = true;
		body.y = vehicleOptions.minY + options.bodyOptions.shape.height + 1;
		stop();
	}

	function startSlipping() {
		isSlipping = true;
	}

	function stopSlipping() {
		isSlipping = false;
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
