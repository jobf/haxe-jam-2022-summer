package scenes;

import echo.Body;

class GetawayScene extends BaseScene{
    override function create() {
        super.create();

		var x = Std.int(sceneManager.stage.centerX());
		var y = Std.int(sceneManager.stage.centerY());
		var w = 320;
		var h = 32;

		var body = new Body({
			shape: {
				width: w,
				height: h,
			},
			kinematic: true,
			mass: 1,
			x: x,
			y: y,
			rotational_velocity: 30,
		});
        
		// add body to world or it will do nothing
		sceneManager.world.add(body);
	}

	override function destroy() {
	}

	override function update(elapsedSeconds:Float) {
        super.update(elapsedSeconds);
    }
}