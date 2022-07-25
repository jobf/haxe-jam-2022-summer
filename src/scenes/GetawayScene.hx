package scenes;

import echo.Body;
import input.ComputerControl;
import tyke.Graphics.RectangleGeometry;
import levels.LevelScroller;
import levels.LevelManager;
import pieces.Vehicle;

class GetawayScene extends BaseScene {
	var player:Vehicle;
	var levelScroller:LevelScroller;
	var computerControl:ComputerControl;
	var enemies:Array<Body>;

	override function create() {
		super.create();
		enemies = [];
		
		var levels = new LevelManager(beachTiles, sprites, tileSize, sceneManager.world);

		var playerGeometry:RectangleGeometry = {
			y: Std.int(sceneManager.stage.centerY()),
			x: 42,
			width: 32,
			height: 16
		};

		player = new Vehicle(playerGeometry, sceneManager.world, largeSprites.makeSprite(playerGeometry.x, playerGeometry.y, 96, 0));
		controller.registerPlayer(player);

		var enemyGeometry:RectangleGeometry = {
			y: Std.int(sceneManager.stage.centerY()),
			x: 42,
			width: 32,
			height: 16
		};

		var enemy = new Vehicle(enemyGeometry, sceneManager.world, largeSprites.makeSprite(playerGeometry.x, playerGeometry.y, 96, 1));
		computerControl = new ComputerControl(enemy);
		// enemies array used for collisions listener
		enemies.push(enemy.body);

		// register player and obstacle collisions
		sceneManager.world.listen(player.body, levels.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		// register enemies and obstacle collisions
		sceneManager.world.listen(enemies, levels.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision enemy obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		levelScroller = new LevelScroller(beachTilesLayer.display, sceneManager.display.width, sceneManager.display.height, playerGeometry, player.body);
	}

	override function destroy() {}

	override function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);
		player.update(elapsedSeconds);
		levelScroller.update(elapsedSeconds);
		computerControl.update(elapsedSeconds);
	}
}
