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
	var alterControlCountDown:CountDown;
    var player:Vehicle;
	var mode:ControlMode;

	public function new(vehicle:Vehicle, player:Vehicle) {
		this.vehicle = vehicle;
        this.player = player;
		this.mode = ENTERING;
		
		buttonStates = [
			0 => {
				isDown: false,
				action: (isDown, vehicle) -> vehicle.controlReverse(isDown)
			},
			1 => {
				isDown: false,
				action: (isDown, vehicle) -> vehicle.controlAccelerate(isDown)
			},
			// 2 => {
			//     isDown: false,
			//     action: (isDown, vehicle) -> vehicle.controlUp(isDown)
			// },
			// 3 => {
			//     isDown: false,
			//     action: (isDown, vehicle) -> vehicle.controlDown(isDown)
			// }
		];
		maximumStateId = 1;
		alterControlCountDown = new CountDown(2.0, () -> alterControl(), true);
	}

	public function update(elapsedSeconds:Float) {
		switch mode {
			case ENTERING: handleEnteringPhase(elapsedSeconds);
			case IDLE: handleIdlePhase(elapsedSeconds);
			case ATTACKING: handleAttackingPhase(elapsedSeconds);
		}
		// alterControlCountDown.update(elapsedSeconds);
		vehicle.update(elapsedSeconds);
	}

	function handleEnteringPhase(elapsedSeconds:Float) {
		//get distance between this vehicle and player
		var distanceToPlayer = player.body.x - vehicle.body.x;
		
		// if close enough, reduce speed so they don't immediately drive past
		final minimumDistanceFromPlayer = 300;
		if(distanceToPlayer <= minimumDistanceFromPlayer){
			vehicle.body.max_velocity = player.body.max_velocity;
			// start IDLE phase
			mode = IDLE;
		}
	}

	function handleIdlePhase(elapsedSeconds:Float) {}

	function handleAttackingPhase(elapsedSeconds:Float) {}

	var buttonStates:Map<Int, ButtonState>;
	var maximumStateId:Int;

	var lastChangedStateId:Int = -1;

	function alterControl() {
        return; // skip for now (will rework soon)

		var nextPressState = randomChance();

		// is button down
		if (lastChangedStateId >= 0) {
			if (buttonStates[lastChangedStateId].isDown != nextPressState) {
				buttonStates[lastChangedStateId].isDown = nextPressState;
				buttonStates[lastChangedStateId].control(vehicle);
			}
		} else {
			lastChangedStateId = randomInt(maximumStateId);
			if (buttonStates[lastChangedStateId].isDown != nextPressState) {
				buttonStates[lastChangedStateId].isDown = nextPressState;
				buttonStates[lastChangedStateId].control(vehicle);
			}
		}

		if (!nextPressState) {
			lastChangedStateId = -1;
		}
	}


}

@:structInit
class ButtonState {
	public var action:(isDown:Bool, vehicle:Vehicle) -> Void;
	public var isDown:Bool;

	public function control(vehicle:Vehicle) {
		action(isDown, vehicle);
	}
}

class EnemyManager {
	public var enemyBodies(default, null):Array<Body>;

	var computerControls:Array<ComputerControl>;
	var world:World;
	var sprites:SpriteRenderer;
    var player:Vehicle;

	public function new(world:World, sprites:SpriteRenderer, player:Vehicle) {
		computerControls = [];
		enemyBodies = [];
		this.world = world;
		this.sprites = sprites;
        this.player = player;
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
		var enemy = new Vehicle(hitbox, world, sprites.makeSprite(hitbox.x, hitbox.y, tileSize, tileIndex));
        
        enemy.body.max_velocity.x = initialVelocityX;
        enemy.body.velocity.x = initialVelocityX;

		var computerControl = new ComputerControl(enemy, player);
		computerControls.push(computerControl);

		// enemies array used for collisions listener
		enemyBodies.push(enemy.body);
	}

	public function update(elapsedSeconds:Float) {
        for(controller in computerControls){
            controller.update(elapsedSeconds);
        }
    }
}
