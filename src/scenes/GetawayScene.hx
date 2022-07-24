package scenes;

import input.ComputerControl;
import tyke.Graphics.RectangleGeometry;
import levels.LevelScroller;
import levels.LevelManager;
import pieces.Vehicle;

class GetawayScene extends BaseScene {
    var player:Vehicle;
    var levelScroller:LevelScroller;
    var computerControl:ComputerControl;
    
    override function create() {
        super.create();

        var levels = new LevelManager(beachTiles, tileSize);
        
        var playerGeometry:RectangleGeometry = {
            y: Std.int(sceneManager.stage.centerY()),
            x: 42,
            width: 32,
            height: 16
        };

        player = new Vehicle(playerGeometry, sceneManager.world);
        controller.registerPlayer(player);

        var enemyGeometry:RectangleGeometry = {
            y: Std.int(sceneManager.stage.centerY()),
            x: 42,
            width: 32,
            height: 16
        };
        var enemy = new Vehicle(enemyGeometry, sceneManager.world);
        computerControl = new ComputerControl(enemy);
        
        levelScroller = new LevelScroller(beachTilesLayer.display, sceneManager.display.width, sceneManager.display.height, playerGeometry, player.body);
	}

	override function destroy() {
	}

	override function update(elapsedSeconds:Float) {
        super.update(elapsedSeconds);
        player.update(elapsedSeconds);
        levelScroller.update(elapsedSeconds);
        computerControl.update(elapsedSeconds);
    }


}
