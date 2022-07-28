package levels;

import peote.view.Color;
import pieces.BasePiece;
import pieces.Vehicle;
import peote.view.PeoteView;
import tyke.Graphics;
import echo.World;
import input.ComputerControl;
import echo.Body;

class EnemyManager {
	public var enemyBodies(default, null):Array<Body>;

	var computerControls:Array<ComputerControl>;
	var world:World;
	var sprites:SpriteRenderer;
	var peoteView:PeoteView;
	var player:Vehicle;

	var isColliding:Bool = false;
	var pieceCore:PieceCore;
	var level:LevelManager;

	public function new(world:World, pieceCore:PieceCore, player:Vehicle, level:LevelManager) {
		computerControls = [];
		enemyBodies = [];
		this.world = world;
		this.pieceCore = pieceCore;
		this.player = player;
		this.level = level;
	}

	public function spawnCar(x:Int, y:Int, initialVelocityX:Float) {
		var geometry:RectangleGeometry = {
			y: y,
			x: x,
			width: 32,
			height: 16
		};

		final tileSize = 96;
		final tileIndex = 1;

		final defaultMaxVelocityX = 400;
		final verticalVelocity:Float = 120;
		final jumpVelocity = -90;

		var enemy = new Vehicle(pieceCore, {
			spriteTileSize: tileSize,
			spriteTileId: tileIndex,
			shape: RECT,
			debugColor: Color.CYAN,
			collisionType: VEHICLE,
			bodyOptions: {
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
				velocity_x: initialVelocityX, // start moving
				max_velocity_x: initialVelocityX
			}
		}, {
			verticalVelocity: verticalVelocity,
			onExpire: vehicle -> expireEnemy(vehicle),
			minY: level.minY,
			maxY: level.maxY,
			jumpVelocity: jumpVelocity,
			defaultMaxVelocityX: defaultMaxVelocityX,
			crashesRemaining: 0 // enemy only have 1 hit point (maybe later enemies have more)
		});

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

	function expireEnemy(vehicle:Vehicle) {
		enemyBodies.remove(vehicle.body);
		vehicle.destroy();
		level.registerLostOneEnemy();
	}
}
