package input;

import lime.ui.Gamepad;
import input2action.ActionMap;
import lime.ui.Window;
import input2action.Input2Action;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import input2action.ActionConfig;
import pieces.Vehicle;


class Controller {
	var actionConfig:ActionConfig;
	var actionMap:ActionMap;
	var player:Vehicle;

	public function new(window:Window) {
		actionConfig = [
			{
				gamepad: [GamepadButton.DPAD_LEFT, GamepadButton.LEFT_SHOULDER],
				keyboard: KeyCode.LEFT,
				action: "reverse"
			},
			{
				gamepad: [GamepadButton.DPAD_RIGHT, GamepadButton.RIGHT_SHOULDER],
				keyboard: KeyCode.RIGHT,
				action: "accelerate"
			},
			{
				gamepad: GamepadButton.DPAD_UP,
				keyboard: KeyCode.UP,
				action: "up"
			},
			{
				gamepad: GamepadButton.DPAD_DOWN,
				keyboard: KeyCode.DOWN,
				action: "down"
			},
			{
				gamepad: GamepadButton.B,
				keyboard: KeyCode.LEFT_SHIFT,
				action: "action"
			},
		];

		actionMap = [
			"reverse" => {
				action: (isDown, playerId) -> {
					player.controlReverse(isDown);
				},
				up: true
			},
			"accelerate" => {
				action: (isDown, playerId) -> {
					player.controlAccelerate(isDown);
				},
				up: true
			},
			"up" => {
				action: (isDown, playerId) -> {
					player.controlUp(isDown);
				},
				up: true
			},
			"down" => {
				action: (isDown, playerId) -> {
					player.controlDown(isDown);
				},
				up: true
			},
			"action" => {
				action: (isDown, playerId) -> {
					player.controlAction(isDown);
				},
				up: true
			},
		];

		var input2Action = new Input2Action(actionConfig, actionMap);
		input2Action.setKeyboard();

		// event handler for new plugged gamepads
		input2Action.onGamepadConnect = function(gamepad:Gamepad) {
			trace('player gamepad connected');
			input2Action.setGamepad(gamepad);
		}

		input2Action.onGamepadDisconnect = function(player:Int) {
			trace('player $player gamepad disconnected');
		}

		input2Action.enable(window);
	}

	public function registerPlayer(player:Vehicle) {
		this.player = player;
    }
}