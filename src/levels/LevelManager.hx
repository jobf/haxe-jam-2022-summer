package levels;

import echo.Body;
import echo.World;
import tyke.Graphics.RectangleGeometry;
import pieces.Obstacle;
import tyke.Ldtk.LevelLoader;
import tyke.Graphics.SpriteRenderer;

class LevelManager {
	var tracks:Tracks;
	var levelSprites:SpriteRenderer;
	var obstacleSprites:SpriteRenderer;
	var world:World;
    public var obstacleBodies(default, null):Array<Body>;

	public function new(levelSprites:SpriteRenderer, obstacleSprites:SpriteRenderer, tilePixelSize:Int, world:World) {
		this.levelSprites = levelSprites;
		this.obstacleSprites = obstacleSprites;
		this.world = world;
        obstacleBodies = [];

		tracks = new Tracks();

		var beachTileMap = tracks.levels[0].l_Beach;
		LevelLoader.renderLayer(beachTileMap, (stack, cx, cy) -> {
			for (tileData in stack) {
				var tileX = cx * tilePixelSize;
				var tileY = cy * tilePixelSize;
				this.levelSprites.makeSprite(tileX, tileY, tilePixelSize, tileData.tileId);
			}
		});

		var obstacleTileMap = tracks.levels[0].l_Obstacles;
		LevelLoader.renderLayer(obstacleTileMap, (stack, cx, cy) -> {
			for (tileData in stack) {
				var tileX = cx * tilePixelSize;
				var tileY = cy * tilePixelSize;
				var geometry:RectangleGeometry = {
					y: tileY,
					x: tileX,
					width: tilePixelSize,
					height: tilePixelSize
				}

				var sprite = this.obstacleSprites.makeSprite(tileX, tileY, tilePixelSize, tileData.tileId);
				var obstacle = new Obstacle(determineObstacleType(tileData.tileId), geometry, world, sprite);
                trace('spawned Obstacle x $tileX y $tileY');
				obstacleBodies.push(obstacle.body);
			}
		});
	}

	/**
		converts the tile ID from the tile map used in ldtk to the ObstacleType enum for use in game 
	**/
	inline function determineObstacleType(tileId:Int):ObstacleType {
		return switch tileId {
			case 9: RAMP;
			case 8: HOLE;
			case _: UNDEFINED;
		}
	}
}
