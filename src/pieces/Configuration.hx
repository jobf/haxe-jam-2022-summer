package pieces;

import echo.Collider;

@:structInit
class ObstacleConfiguration {
	public var spriteTileIndex:Int;
	public var collisionMode:CollisionType;
	public var hitboxWidth:Int;
	public var hitboxHeight:Int;
}

class Configuration {
    /**
        the int key is the index of the tile used in ldtk Obstacles tile set 
    **/
	public static var obstacles:Map<Int, ObstacleConfiguration> = [
        8 => {
            spriteTileIndex: 12,
            hitboxWidth: 80,
            hitboxHeight: 80,
            collisionMode: HOLE
        },
		9 => {
			spriteTileIndex: 6,
			hitboxWidth: 32,
			hitboxHeight: 36,
			collisionMode: RAMP
		},
		10 => {
			spriteTileIndex: 13,
			hitboxWidth: 46,
			hitboxHeight: 50,
			collisionMode: SLICK
		},
		11 => {
			spriteTileIndex: 14,
			hitboxWidth: 58,
			hitboxHeight: 50,
			collisionMode: ROCK
		},
		12 => {
			spriteTileIndex: 15,
			hitboxWidth: 46,
			hitboxHeight: 46,
			collisionMode: INFLATABLE
		},
	];
}
