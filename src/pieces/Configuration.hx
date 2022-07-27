package pieces;

import tyke.Graphics.Geometry;
import echo.Collider;

@:structInit
class ObstacleConfiguration {
	public var spriteTileIndex:Int;
	public var collisionMode:CollisionType;
	public var hitboxWidth:Int;
	public var hitboxHeight:Int;
	public var shape:Geometry;
}

class Configuration {
    /**
        the int key is the index of the tile used in ldtk Obstacles tile set 
    **/
	public static var obstacles:Map<Int, ObstacleConfiguration> = [
		6 => {
			spriteTileIndex: 6,
			hitboxWidth: 32,
			hitboxHeight: 36,
			collisionMode: RAMP,
			shape: RECT
		},
        12 => {
            spriteTileIndex: 12,
            hitboxWidth: 70,
            hitboxHeight: 70,
            collisionMode: HOLE,
			shape: CIRCLE
        },
		13 => {
			spriteTileIndex: 13,
			hitboxWidth: 46,
			hitboxHeight: 50,
			collisionMode: SLICK,
			shape: RECT
		},
		14 => {
			spriteTileIndex: 14,
			hitboxWidth: 58,
			hitboxHeight: 50,
			collisionMode: ROCK,
			shape: RECT
		},
		15 => {
			spriteTileIndex: 15,
			hitboxWidth: 46,
			hitboxHeight: 46,
			collisionMode: INFLATABLE,
			shape: CIRCLE
		},
	];
}
