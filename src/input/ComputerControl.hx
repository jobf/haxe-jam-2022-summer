package input;

import peote.view.Color;
import pieces.BasePiece.PieceCore;
import peote.view.PeoteView;
import echo.World;
import echo.Body;
import tyke.Graphics;
import tyke.Glyph;
import tyke.Loop.CountDown;
import pieces.Vehicle;

enum ControlMode {
	ENTERING; // moving from off screen to on
	IDLE; // moving across the road but not attacking
	ATTACKING; // tracking the player and attacking
	WAITING; // waiting by side of road
}

class ComputerControl {
	var vehicle:Vehicle;
	var idleControlCountDown:CountDown;
	var attackControlCountDown:CountDown;
	var attackCountDown:CountDown;
	var waitingCountDown:CountDown;
	var player:Vehicle;
	var mode:ControlMode;

	public function new(vehicle:Vehicle, player:Vehicle) {
		this.vehicle = vehicle;
		this.player = player;
		this.mode = ENTERING;

		idleControlCountDown = new CountDown(1.0, () -> idleControl(), true);
		attackControlCountDown = new CountDown(2.0, () -> attackControl(), true);
		attackCountDown = new CountDown(1.0, () -> stopAttack(), false);
		waitingCountDown = new CountDown(1.0, () -> waitControl(), false);
	}

	public function update(elapsedSeconds:Float) {
		if (vehicle.isAlive) {
			switch mode {
				case ENTERING:
					handleEnteringPhase(elapsedSeconds);
				case IDLE:
					handleIdlePhase(elapsedSeconds);
				case ATTACKING:
					handleAttackingPhase(elapsedSeconds);
				case WAITING:
					handleWaitingPhase(elapsedSeconds);
			}

			vehicle.update(elapsedSeconds);
		}
	}

	function handleEnteringPhase(elapsedSeconds:Float) {
		// get distance between this vehicle and player
		var distanceToPlayer = player.body.x - vehicle.body.x;

		// if close enough, reduce speed so they don't immediately drive past
		final minimumDistanceFromPlayer = 300;
		if (distanceToPlayer <= minimumDistanceFromPlayer) {
			vehicle.body.max_velocity = player.body.max_velocity;

			// start IDLE phase
			// mode = IDLE;
			// idleControlCountDown.reset();

			startAttackPhase();
		}
	}

	function handleIdlePhase(elapsedSeconds:Float) {
		idleControlCountDown.update(elapsedSeconds);
	}

	function idleControl() {
		if (vehicle.isControllingVertical) {
			// need to stop moving
			vehicle.controlDown(false);
			vehicle.controlUp(false);
		} else {
			// no vertical movement is happening yet

			// car will move up or down if oneOfThree is 1 or 2
			var oneOfThree = randomInt(2);
			if (oneOfThree != 0) {
				if (oneOfThree == 1) {
					moveUp();
				} else {
					moveDown();
				}
			}
		}
	}

	function startAttackPhase() {
		// start ATTACK phase
		mode = ATTACKING;
		attackControlCountDown.reset();
	}

	function handleAttackingPhase(elapsedSeconds:Float) {
		attackControlCountDown.update(elapsedSeconds);
		if (isAligningForAttack) {
			// check if is aligned and stop aligning
			if (checkVerticalAlignmentToPlayer() == 0) {
				stopVerticalMovement();
				isAligningForAttack = false;
			}
		}
		// todo - pass screenwidth in
		final screenwidth = 640;
		if (vehicle.body.x - player.body.x >= screenwidth * 2) {
			// start WAITING phase
			mode = WAITING;
			waitingCountDown.reset();
			vehicle.parkAtSide();
		}
	}

	function checkVerticalAlignmentToPlayer():Int {
		// get vertical distance between this vehicle and player
		var distanceToPlayer = player.body.y - vehicle.body.y;
		// trace('distanceToPlayer $distanceToPlayer');

		final distanceToAttackFrom = 10;
		var moveInDirection = 0;
		if (distanceToPlayer > distanceToAttackFrom) {
			// move vertically down to align with player
			// trace('need to move down');
			moveInDirection = 1;
		} else if (distanceToPlayer < -distanceToAttackFrom) {
			// move vertically down to align with player
			// trace('need to move up');
			moveInDirection = -1;
		}

		return moveInDirection;
	}

	inline function stopVerticalMovement() {
		vehicle.controlDown(false);
		vehicle.controlUp(false);
	}

	function attackControl() {
		var moveInDirection = checkVerticalAlignmentToPlayer();

		if (moveInDirection == 0) {
			// can attack
			if (vehicle.isControllingVertical) {
				// need to stop moving
				stopVerticalMovement();
			}
			startAttack();
		} else {
			isAligningForAttack = true;
			if (moveInDirection < 0) {
				moveUp();
			} else {
				moveDown();
			}
		}
	}

	inline function moveUp() {
		// move up
		trace('enemy move up');
		vehicle.controlUp(true);
	}

	inline function moveDown() {
		// move down
		trace('enemy move down');
		vehicle.controlDown(true);
	}

	var isAligningForAttack:Bool;

	inline function startAttack() {
		var speed = player.body.velocity.x * 2.5;
		vehicle.body.max_velocity.x = speed;
		vehicle.body.velocity.x = speed;
		attackCountDown.reset();
	}

	inline function stopAttack() {
		vehicle.resetMaxVelocityX();
	}

	function waitControl() {
		final distanceToStartFollowingFrom = 200;
		if (player.body.x - vehicle.body.x > distanceToStartFollowingFrom) {
			@:privateAccess
			vehicle.isParking = false;
			startAttackPhase();
		}
	}

	function handleWaitingPhase(elapsedSeconds:Float) {
		waitingCountDown.update(elapsedSeconds);
	}
}
