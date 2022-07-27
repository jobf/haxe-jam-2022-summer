package scenes;

import tyke.jam.Scene;
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
	var levelsIds = [0, 1];

	override function create() {
		super.create();

		var currentLevel = 0; // for testing only
		// var currentLevel = 1; // start at 1 normally

		var level = new LevelManager(beachTiles, largeSprites, tileSize, sceneManager.world, levelsIds[currentLevel]);

		var playerGeometry:RectangleGeometry = {
			y: Std.int(sceneManager.stage.centerY()),
			x: 42,
			width: 32,
			height: 16
		};

		var playerExpired:Vehicle->Void = vehicle -> {
			var initSceneAfterMessageScene:Void->Scene = ()-> return new EndScene(sceneManager);
			sceneManager.changeScene(new MessageScene(sceneManager, "Too bad you smashed!", initSceneAfterMessageScene));
		};

		final playerMaximumCrashes = 2;
		var sprite = largeSprites.makeSprite(playerGeometry.x, playerGeometry.y, 96, 0);
		player = new Vehicle(playerGeometry, sceneManager.world, sceneManager.peoteView, sprite, level.minY, level.maxY, playerExpired, playerMaximumCrashes);
		controller.registerPlayer(player);

		levelScroller = new LevelScroller(beachTilesLayer.display, sceneManager.display.width, sceneManager.display.height, playerGeometry, player.body);

		// register player and obstacle collisions
		sceneManager.world.listen(player.body, level.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		enemyManager = new EnemyManager(sceneManager.world, largeSprites, sceneManager.peoteView, player, level.minY, level.maxY);

		// register player and enemy vehicle collisions
		sceneManager.world.listen(player.body, enemyManager.enemyBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player enemy');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		// register player and enemy trigger points
		sceneManager.world.listen(player.body, level.enemyTriggerZones, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player enemyTriggerZone');
				final triggerY = 200;
				final triggerXOffset = 100;
				var triggerX = levelScroller.edgeOfViewLeft() - triggerXOffset;
				enemyManager.spawnCar(triggerX, triggerY, player.body.velocity.x * 2);
			}
		});

		// register player and end trigger points
		sceneManager.world.listen(player.body, level.endTriggerZones, {
			enter: (body1, body2, collisionData) -> {
				// trace("end");
				var message = "You didn't lose them all!";
				if(level.isWon())
				{
					message = "You lost them all!!!";
				}
				var initSceneAfterMessageScene:Void->Scene = ()-> return new EndScene(sceneManager);
				sceneManager.changeScene(new MessageScene(sceneManager, message, initSceneAfterMessageScene));
			}
		});

		// register enemies and obstacle collisions
		sceneManager.world.listen(enemyManager.enemyBodies, level.obstacleBodies, {
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
