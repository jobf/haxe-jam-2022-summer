package scenes;

import pieces.Vehicle;

class GetawayScene extends BaseScene{
    override function create() {
        super.create();

		var x = Std.int(sceneManager.stage.centerX());
		var y = Std.int(sceneManager.stage.centerY());

        var player = new Vehicle(x, y, sceneManager.world);
	}

	override function destroy() {
	}

	override function update(elapsedSeconds:Float) {
        super.update(elapsedSeconds);
    }
}