package pieces;

import levels.LevelManager;
import echo.Body;
import ui.HUD;
import pieces.Vehicle;
import pieces.BasePiece;

class Player extends Vehicle {
	var hud:HUD;
	var level:LevelManager;

	public var totalCrashesRemaining(get, null):Int;

	function get_totalCrashesRemaining():Int {
		return vehicleOptions.crashesRemaining;
	}

	public function new(core:PieceCore, options:PieceOptions, vehicleOptions:VehicleOptions, level:LevelManager) {
		super(core, options, vehicleOptions);
		this.level = level;
	}

	override function update(elapsedSeconds:Float) {
		super.update(elapsedSeconds);

		// update HUD progress on level
		hud.updateEndText(body.x, level.finishLineX);

		// update HUD number of remaining enemies
		hud.updateEnemiesText(level.totalEnemiesRemaining);
	}

	// override function collideWith(body:Body) {
	// 	super.collideWith(body);

	// 	// update HUD number of remaining enemies
	// 	if (body.collider.type == VEHICLE) {
	// 		level.registerLostOneEnemy();
	// 		hud.updateEnemiesText(level.totalEnemiesRemaining);
	// 	}
	// }

	override function crash(damage:Int = 1) {
		super.crash(damage);

		// update HUD remaining health
		var remainingCrashes = vehicleOptions.crashesRemaining;
		if (remainingCrashes < 0) {
			remainingCrashes = 0;
		}
		hud.updateHealthText(remainingCrashes);
	}

	public function registerHud(hud:HUD) {
		this.hud = hud;
		hud.updateHealthText(totalCrashesRemaining);
		hud.updateEnemiesText(level.totalEnemiesRemaining);
	}
}
