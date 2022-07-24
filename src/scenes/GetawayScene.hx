package scenes;

import pieces.Vehicle;

class GetawayScene extends BaseScene{
    var player:Vehicle;

    override function create() {
        super.create();

		var x = 42;
		var y = Std.int(sceneManager.stage.centerY());

        player = new Vehicle(x, y, sceneManager.world);
        controller.registerPlayer(player);
	}

	override function destroy() {
	}

	override function update(elapsedSeconds:Float) {
        super.update(elapsedSeconds);
        player.update(elapsedSeconds);
    }

}