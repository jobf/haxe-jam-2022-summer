package input;

import echo.World;
import echo.Body;
import tyke.Graphics;
import tyke.Glyph;
import tyke.Loop.CountDown;
import pieces.Vehicle;

enum ControlMode {
	ENTERING;
	IDLE;
	ATTACKING;
}

class ComputerControl {
	var vehicle:Vehicle;
	var idleControlCountDown:CountDown;
	var attackControlCountDown:CountDown;
	var attackCountDown:CountDown;
	var player:Vehicle;
	var mode:ControlMode;

	public function new(vehicle:Vehicle, player:Vehicle) {
		this.vehicle = vehicle;
		this.player = player;
		this.mode = ENTERING;

		idleControlCountDown = new CountDown(1.0, () -> idleControl(), true);
		attackControlCountDown = new CountDown(2.0, () -> attackControl(), true);
		attackCountDown = new CountDown(1.0, () -> stopAttack(), false);
	}

	public function update(elapsedSeconds:Float) {
		switch mode {
			case ENTERING:
				handleEnteringPhase(elapsedSeconds);
			case IDLE:
				handleIdlePhase(elapsedSeconds);
			case ATTACKING:
				handleAttackingPhase(elapsedSeconds);
		}

		vehicle.update(elapsedSeconds);
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

			// start ATTACK phase
			mode = ATTACKING;
			attackControlCountDown.reset();
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

	function handleAttackingPhase(elapsedSeconds:Float) {
		attackControlCountDown.update(elapsedSeconds);
		if (isAligningForAttack) {
			// check if is aligned and stop aligning
			if (checkVerticalAlignmentToPlayer() == 0) {
				stopVerticalMovement();
				isAligningForAttack = false;
			}
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
			trace('need to move down');
			moveInDirection = 1;
		} else if (distanceToPlayer < -distanceToAttackFrom) {
			// move vertically down to align with player
			trace('need to move up');
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
}

class EnemyManager {
	public var enemyBodies(default, null):Array<Body>;

	var computerControls:Array<ComputerControl>;
	var world:World;
	var sprites:SpriteRenderer;
	var player:Vehicle;

	var isColliding:Bool = false;
	var minY:Int;
	var maxY:Int;

	public function new(world:World, sprites:SpriteRenderer, player:Vehicle, minY:Int, maxY:Int) {
		computerControls = [];
		enemyBodies = [];
		this.world = world;
		this.sprites = sprites;
		this.player = player;
		this.minY = minY;
		this.maxY = maxY;
	}

	public function spawnCar(x:Int, y:Int, initialVelocityX:Float) {
		var hitbox:RectangleGeometry = {
			y: y,
			x: x,
			width: 32,
			height: 16
		};

		final tileSize = 96;
		final tileIndex = 1;
		var enemy = new Vehicle(hitbox, world, sprites.makeSprite(hitbox.x, hitbox.y, tileSize, tileIndex), minY, maxY);

		enemy.body.max_velocity.x = initialVelocityX;
		enemy.body.velocity.x = initialVelocityX;

		var computerControl = new ComputerControl(enemy, player);
		computerControls.push(computerControl);

		// enemies array used for collisions listener
		enemyBodies.push(enemy.body);
	}

	public function update(elapsedSeconds:Float) {
		for (controller in computerControls) {
			controller.update(elapsedSeconds);
		}
	}
}
