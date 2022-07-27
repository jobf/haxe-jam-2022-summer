package scenes;

import pieces.Player;
import ui.HUD;
import peote.view.Color;
import tyke.jam.Scene;
import input.ComputerControl;
import tyke.Graphics.RectangleGeometry;
import levels.LevelScroller;
import levels.LevelManager;

class GetawayScene extends BaseScene {
	var player:Player;
	var level:LevelManager;
	var levelScroller:LevelScroller;
	var enemyManager:EnemyManager;
	var hud:HUD;
	var levelsIds = [0, 1];

	override function create() {
		super.create();

		var currentLevel = 0; // for testing only
		var currentLevel = 1; // start at 1 normally

		level = new LevelManager(pieceCore, beachTiles, tileSize, sceneManager.world, levelsIds[currentLevel]);

		var geometry:RectangleGeometry = {
			y: Std.int(sceneManager.stage.centerY()),
			x: 42,
			width: 32,
			height: 16
		};

		final defaultMaxVelocityX = 400;
		final verticalVelocity:Float = 120;
		final jumpVelocity = -90;

		player = new Player(pieceCore, 
		{
			spriteTileSize: 96,
			spriteTileId: 0,
			shape: RECT,
			debugColor: Color.YELLOW,
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
				max_velocity_x: defaultMaxVelocityX, // stop the vehicle going too fast
			}
		},
		{
			verticalVelocity: verticalVelocity,
			onExpire: vehicle -> {
				var initSceneAfterMessageScene:Void->Scene = ()-> return new EndScene(sceneManager);
				sceneManager.changeScene(new MessageScene(sceneManager, "Too bad you smashed!", initSceneAfterMessageScene));
			},
			minY: level.minY,
			maxY: level.maxY,
			jumpVelocity: jumpVelocity,
			defaultMaxVelocityX: defaultMaxVelocityX,
			crashesRemaining: 2
		},
		level);
		
		controller.registerPlayer(player);

		levelScroller = new LevelScroller(beachTilesLayer.display, sceneManager.display.width, sceneManager.display.height, player.body);

		// register player and obstacle collisions
		sceneManager.world.listen(player.body, level.obstacleBodies, {
			enter: (body1, body2, collisionData) -> {
				trace('collision player obstacle');
				body1.collider.collideWith(body2);
				body2.collider.collideWith(body1);
			}
		});

		enemyManager = new EnemyManager(sceneManager.world, pieceCore, player, level.minY, level.maxY);

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
				var message = "Did not lose them all!";
				if(level.isWon())
				{
					message = "\\o/ lost them all!!!";
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

		hud = new HUD(iconSprites, text.fontProgram);
		player.registerHud(hud);

		// allow using controller
		controller.enable();

		#if !debug
		// hide all shapes (when no debugging)
		debugShapes.setVisibility(false);
		#end
	}

	override function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);

    player.update(elapsedSeconds);
		levelScroller.update(elapsedSeconds);
		enemyManager.update(elapsedSeconds);
	}

}
