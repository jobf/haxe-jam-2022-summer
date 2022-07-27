package levels;

import pieces.BasePiece.PieceCore;
import peote.view.Color;
import pieces.Configuration;
import echo.Collider;
import echo.Body;
import echo.World;
import tyke.Graphics.RectangleGeometry;
import pieces.Obstacle;
import tyke.Ldtk.LevelLoader;
import tyke.Graphics.SpriteRenderer;

class LevelManager {
	var tracks:Tracks;
	var pieceCore:PieceCore;
	var levelSprites:SpriteRenderer;
	var world:World;
	var levelId:Int;
	var tracksTileRenderSize:Int;
	public var totalEnemiesRemaining(default, null):Int;
	public var finishLineX(default, null):Int;

	public var minY(default, null):Int;
	public var maxY(default, null):Int;
	public var obstacleBodies(default, null):Array<Body>;
	public var enemyTriggerZones(default, null):Array<Body>;
	public var endTriggerZones(default, null):Array<Body>;

	public function new(pieceCore:PieceCore, levelSprites:SpriteRenderer, tracksTileRenderSize:Int, world:World, levelId:Int) {
		this.pieceCore = pieceCore;
		this.levelSprites = levelSprites;
		this.tracksTileRenderSize = tracksTileRenderSize;
		this.world = world;
		this.levelId = levelId;
		obstacleBodies = [];
		enemyTriggerZones = [];
		endTriggerZones = [];
		minY = 4 * 32;
		maxY = 420 - minY;
		tracks = new Tracks();

		setupTrackTiles();

		setupObstacles();

		setupEnemyTriggers();

		setupFinishLine();
	}

	function setupTrackTiles() {
		var beachTileMap = tracks.levels[levelId].l_Track;
		LevelLoader.renderLayer(beachTileMap, (stack, cx, cy) -> {
			for (tileData in stack) {
				var tileX = cx * tracksTileRenderSize;
				var tileY = cy * tracksTileRenderSize;
				levelSprites.makeSprite(tileX, tileY, tracksTileRenderSize, tileData.tileId);
			}
		});
	}

	function setupObstacles() {
		final obstacleTileSize = 96;
		var obstacleTileMap = tracks.levels[levelId].l_Obstacles;
		LevelLoader.renderLayer(obstacleTileMap, (stack, cx, cy) -> {
			for (tileData in stack) {
				if (Configuration.obstacles.exists(tileData.tileId)) {
					var config = Configuration.obstacles[tileData.tileId];
					
					var geometry:RectangleGeometry = {
						y: cy * tracksTileRenderSize,
						x: cx * tracksTileRenderSize,
						width: config.hitboxWidth,
						height: config.hitboxHeight
					}
					
					trace('init ${config.collisionMode} ${geometry.x} ${geometry.y}');

					// var sprite = this.largeSprites.makeSprite(geometry.x, geometry.y, obstacleTileSize, config.spriteTileIndex);
					var obstacle = new Obstacle(pieceCore, {
						spriteTileSize: obstacleTileSize,
						spriteTileId: config.spriteTileIndex,
						shape: config.shape,
						debugColor: 0xff101060,
						collisionType: config.collisionMode,
						bodyOptions: {
							shape: {
								width: geometry.width,
								height: geometry.height,
								solid: false
							},
							kinematic: true,
							mass: 1,
							x: geometry.x,
							y: geometry.y,
						}
					});

					// obstacleBodies array used for collision listener
					obstacleBodies.push(obstacle.body);
				} else {
					trace('warning no obstacle configuration for tile id ${tileData.tileId}');
				}
			}
		});
	}

	function setupEnemyTriggers() {
		var triggerZones = tracks.levels[levelId].l_HitBoxes.all_EnemyTrigger;
		totalEnemiesRemaining = triggerZones.length;
		for (triggerZone in triggerZones) {
			// adjust position and size for 32 pixel grid (map is made with 16 pixels)
			var x = triggerZone.cx * tracksTileRenderSize;
			var y = triggerZone.cy * tracksTileRenderSize;
			var w = triggerZone.width * 2;
			var h = triggerZone.height * 2;
			var hitZone = new Body({
				shape: {
					solid: false,
					width: w,
					height: h,
				},
				kinematic: true,
				mass: 0,
				x: x + (w * 0.5), // need to add half the width to position correctly (because body origin is in center)
				y: y + (h * 0.5), // need to add half the height to position correctly (because body origin is in center)
				rotation: 1 // needed to render debug (bug in rectangle render)
			});

			// register body in world
			world.add(hitZone);

			// enemyTriggerZones use in collision listener
			enemyTriggerZones.push(hitZone);
		}
	}

	function setupFinishLine() {
		var endZones = tracks.levels[levelId].l_HitBoxes.all_EndTrigger;
		for (endZone in endZones) {
			var x = endZone.cx * tracksTileRenderSize;
			var y = endZone.cy * tracksTileRenderSize;
			var w = endZone.width * 2;
			var h = endZone.height * 2;
			
			var endHitZone = new Body({
				shape: {
					solid: false,
					width: w,
					height: h,
				},
				kinematic: true,
				mass: 0,
				x: x + (w * 0.5),
				y: y + (h * 0.5),
				rotation: 1
			});
			
			finishLineX = Std.int(endHitZone.x);

			world.add(endHitZone);
			endTriggerZones.push(endHitZone);
		}
	}

	public function registerLostOneEnemy() {
		totalEnemiesRemaining--;
	}

	public function isWon():Bool {
		return totalEnemiesRemaining <= 0;
	}

}
