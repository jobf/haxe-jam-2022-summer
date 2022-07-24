package scenes;

import tyke.Graphics.SpriteRenderer;
import input.Controller;
import lime.ui.KeyCode;
import tyke.Echo.EchoDebug;
import tyke.jam.Scene;

class BaseScene extends Scene {
    var tileSize:Int;
    var beachTiles:SpriteRenderer;
    var debugRectangles:EchoDebug;
    var controller:Controller;
    
	override function create() {
        tileSize = 32;
        
        // renderer for beach tiles
        beachTiles = sceneManager.stage.createSpriteRendererLayer("beachTiles", sceneManager.assets.imageCache[0], tileSize);
        
        // renderer for body debugging
        debugRectangles = new EchoDebug(sceneManager.stage.createRectangleRenderLayer("debugrectangles"));

		//bind a key to reset the scene
		sceneManager.keyboard.bind(KeyCode.R, "RESET", "Reset Scene", loop -> sceneManager.resetScene());

        @:privateAccess
        controller = new Controller(sceneManager.gum.window);

        trace('BaseScene initialized');
	}

	override function destroy() {
	}

	override function update(elapsedSeconds:Float) {
        // need to call draw on the debug renderer
        debugRectangles.draw(sceneManager.world);
    }

}
