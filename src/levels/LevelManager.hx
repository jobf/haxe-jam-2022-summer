package levels;

import tyke.Ldtk.LevelLoader;
import tyke.Graphics.SpriteRenderer;

class LevelManager{
    var tracks:Tracks;
    var levelSprites:SpriteRenderer;
    var obstacleSprites:SpriteRenderer;

    public function new(levelSprites:SpriteRenderer, obstacleSprites:SpriteRenderer, tilePixelSize:Int){
        this.levelSprites = levelSprites;
        this.obstacleSprites = obstacleSprites;

        tracks = new Tracks();

        var beachTileMap = tracks.levels[0].l_Beach;
        LevelLoader.renderLayer(beachTileMap, (stack, cx, cy) -> {
            for(tileData in stack){
				var tileX = cx * tilePixelSize;
				var tileY = cy * tilePixelSize;
				this.levelSprites.makeSprite(tileX, tileY, tilePixelSize, tileData.tileId);
            }
        });

        var obstacleTileMap = tracks.levels[0].l_Obstacles;
        LevelLoader.renderLayer(obstacleTileMap, (stack, cx, cy) -> {
            for(tileData in stack){
				var tileX = cx * tilePixelSize;
				var tileY = cy * tilePixelSize;
				this.obstacleSprites.makeSprite(tileX, tileY, tilePixelSize, tileData.tileId);
            }
        });
    }
}