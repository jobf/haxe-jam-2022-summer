package scenes;

import input.Controller;
import lime.ui.KeyCode;
import tyke.Echo.EchoDebug;
import tyke.jam.Scene;

class BaseScene extends Scene {
    var debugRectangles:EchoDebug;
    var controller:Controller;
    
	override function create() {
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
