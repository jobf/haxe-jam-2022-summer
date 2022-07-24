package tyke.jam;

import tyke.Loop.PhysicalStageLoop;

class SceneManager extends PhysicalStageLoop {
	var scene:Scene;

	public function new(assets:Assets, initScene:PhysicalStageLoop->Scene) {
		super(assets, () -> setupInitialScene(initScene));
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

    override function onUpdate(deltaMs:Int) {
        super.onUpdate(deltaMs);
        scene.update(deltaMs / 1000);
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
}
