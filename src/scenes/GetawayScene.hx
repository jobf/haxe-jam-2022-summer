package scenes;

import echo.Body;
import input.ComputerControl;
import tyke.Graphics.RectangleGeometry;
import levels.LevelScroller;
import levels.LevelManager;
import pieces.Vehicle;
import lime.ui.KeyCode;

class GetawayScene extends BaseScene {
	var player:Vehicle;
	var levelScroller:LevelScroller;
	var enemyManager:EnemyManager;

	override function create() {
		super.create();

		var levels = new LevelManager(beachTiles, largeSprites, tileSize, sceneManager.world);

		var playerGeometry:RectangleGeometry = {
			y: Std.int(sceneManager.stage.centerY()),
			x: 42,
			width: 32,
			height: 16
		};

		var playerExpired:Vehicle->Void = vehicle -> {
			sceneManager.changeScene(new EndScene(sceneManager));
		};

		final playerMaximumCrashes = 2;
		var sprite = largeSprites.makeSprite(playerGeometry.x, playerGeometry.y, 96, 0);
		player = new Vehicle(playerGeometry, sceneManager.world, sceneManager.peoteView, sprite, levels.minY, levels.maxY, playerExpired, playerMaximumCrashes);
		controller.registerPlayer(player);

		levelScroller = new LevelScroller(beachTilesLayer.display, sceneManager.display.width, sceneManager.display.height, playerGeometry, player.body);

		// register player and obstacle collisions
		sceneManager.world.listen(player.body, levels.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		enemyManager = new EnemyManager(sceneManager.world, largeSprites, sceneManager.peoteView, player, levels.minY, levels.maxY);

		// register player and enemy vehicle collisions
		sceneManager.world.listen(player.body, enemyManager.enemyBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player enemy');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		// register player and enemy spawn points
		sceneManager.world.listen(player.body, levels.enemySpawnZones, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player enemySpawnZone');
				final spawnY = 200;
				final spawnXOffset = 100;
				var spawnX = levelScroller.edgeOfViewLeft() - spawnXOffset;
				enemyManager.spawnCar(spawnX, spawnY, player.body.velocity.x * 2);
			}
		});

		// register player and end spawn points
		sceneManager.world.listen(player.body, levels.endSpawnZones, {
			enter: (body1, body2, collisionData) -> {
				// trace("end");
				sceneManager.changeScene(new EndScene(sceneManager));
			}
		});

		// register enemies and obstacle collisions
		sceneManager.world.listen(enemyManager.enemyBodies, levels.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision enemy obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		// allow using controller
		controller.enable();
	}

	override function destroy() {}

	override function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);
		player.update(elapsedSeconds);
		levelScroller.update(elapsedSeconds);
		enemyManager.update(elapsedSeconds);
	}
}
