package tyke;

// import ldtk.Layer;
import ldtk.Layer_Tiles;
import ldtk.Layer_IntGrid;
import echo.util.TileMap;

class LevelLoader {
	public static function renderLayer(tileLayer:Layer_Tiles, handleTileStackAt:(stack:Array<{tileId:Int, flipBits:Int}>, cx:Int, cy:Int) -> Void) {
		for (cy in 0...tileLayer.cHei) {
			for (cx in 0...tileLayer.cWid) {
				if (tileLayer.hasAnyTileAt(cx, cy)) {
					handleTileStackAt(tileLayer.getTileStackAt(cx, cy), cx, cy);
				}
			}
		}
	}
}

class MapLoader {
	public static function bodiesFromIntGrid(tileMap:Layer_IntGrid):Array<Body> {
		var solidTiles = [];
		
		for (y in 0...tileMap.cHei) {
			for (x in 0...tileMap.cWid) {
				var t = tileMap.getInt(x, y);
				solidTiles.push(t == 0 ? 0 : 1);
			}
		}

		var tileSize = tileMap.gridSize;
		return TileMap.generate(solidTiles, tileSize, tileSize, tileMap.cWid, tileMap.cHei, -tileSize, -tileSize); // todo - why -tileSize ?
	}
}
