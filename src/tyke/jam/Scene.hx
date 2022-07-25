package tyke.jam;

import tyke.Loop.PhysicalStageLoop;

class SceneManager extends PhysicalStageLoop {
	var scene:Scene;

	public function new(assets:Assets, initScene:PhysicalStageLoop->Scene, ?width:Int, ?height:Int) {
		super(assets, () -> setupInitialScene(initScene), width, height);
	}

	function setupInitialScene(initScene:PhysicalStageLoop->Scene):Void {
		changeScene(initScene(this));
		gum.toggleUpdate(true);
	}

	public function changeScene(nextScene:Scene) {
		if (scene != null) {
			scene.destroy();
		}
		setupPeoteView();
		initWorldAndStage();
        scene = nextScene;
        scene.create();
	}

	public function resetScene() {
		changeScene(scene);
	}

    override function onUpdate(deltaMs:Int) {
        super.onUpdate(deltaMs);
        scene.update(deltaMs / 1000);
    }

	override function onMouseMove(x:Float, y:Float) {
		super.onMouseMove(x, y);
		scene.onMouseMove(x, y);
	}

	override function onMouseDown(x:Float, y:Float, button:MouseButton) {
		super.onMouseDown(x, y, button);
		scene.onMouseDown(x, y, button);
	}

	override function onMouseUp(x:Float, y:Float, button:MouseButton) {
		super.onMouseUp(x, y, button);
		scene.onMouseUp(x, y, button);
	}

	override function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {
		super.onMouseScroll(deltaX, deltaY, wheelMode);
		scene.onMouseScroll(deltaX, deltaY, wheelMode);
	}
}

class Scene {
	var sceneManager:SceneManager;
	public function new(sceneManager:SceneManager){
		this.sceneManager = sceneManager;
	}
	public function create(){}
	public function destroy(){}
	public function update(elapsedSeconds:Float){}

	public function onMouseMove(x:Float, y:Float) {}

	public function onMouseDown(x:Float, y:Float, button:MouseButton) {}

	public function onMouseUp(x:Float, y:Float, button:MouseButton) {}

	public function onMouseScroll(deltaX:Float, deltaY:Float, wheelMode:MouseWheelMode) {}
}
