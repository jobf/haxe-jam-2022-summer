package input;

import lime.ui.Gamepad;
import input2action.ActionMap;
import lime.ui.Window;
import input2action.Input2Action;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import input2action.ActionConfig;
import pieces.Vehicle;


class MenuController {
	var actionConfig:ActionConfig;
	var actionMap:ActionMap;
	var player:Vehicle;
	var input2Action:Input2Action;
	var window:Window;

	public function new(window:Window, onStartButtonPressed:Void->Void) {
		this.window = window;
		actionConfig = [
			{
				gamepad: [GamepadButton.START],
				keyboard: RETURN,
				action: "start"
			}
		];

		actionMap = [
			"start" => {
				action: (isDown, playerId) -> {
					onStartButtonPressed();
				},
				// up: true
			}
		];

		input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();

		// event handler for new plugged gamepads
		input2Action.onGamepadConnect = function(gamepad:Gamepad) {
			trace('player gamepad connected');
			input2Action.setGamepad(gamepad);
		}

		input2Action.onGamepadDisconnect = function(player:Int) {
			trace('player $player gamepad disconnected');
		}

	}
	
	public function enable() {
		input2Action.enable(window);
	}

	public function disable() {
		input2Action.disable(window);
	}

}