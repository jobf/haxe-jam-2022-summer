package pieces;

import echo.World;
import echo.Body;

class Vehicle{
    public var body(default, null):Body;

    public function new(x:Int, y:Int, world:World){
        body = new Body({
			shape: {
				width: 32,
				height: 16,
			},
			kinematic: true,
			mass: 1,
			x: x,
			y: y,
            rotation: 1, // have a bug in debug renderer (does not draw rectangles if straight :thonk:)
        });

        world.add(body);
    }
}