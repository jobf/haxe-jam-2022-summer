package input;

import tyke.Glyph.randomChance;
import tyke.Glyph.randomInt;
import tyke.Loop.CountDown;
import pieces.Vehicle;

class ComputerControl {
	var vehicle:Vehicle;
	var alterControlCountDown:CountDown;

	public function new(vehicle:Vehicle) {
		this.vehicle = vehicle;
		alterControlCountDown = new CountDown(2.0, () -> alterControl(), true);
	}

	public function update(elapsedSeconds:Float) {
		alterControlCountDown.update(elapsedSeconds);
        vehicle.update(elapsedSeconds);
	}

	var buttonStates:Map<Int, ButtonState> = [
		0 => {
			isDown: false,
			action: (isDown, vehicle) -> vehicle.controlAccelerate(isDown)
		}
	];

	function alterControl() {
		var chance = randomChance();
        var stateId = 0;
        if(buttonStates[stateId].isDown == chance){
            buttonStates[stateId].isDown = !chance;
            buttonStates[stateId].press(vehicle);
        }
	}
}

@:structInit
class ButtonState {
	public var action:(isDown:Bool, vehicle:Vehicle)->Void;
	public var isDown:Bool;
    public function press(vehicle:Vehicle){
        action(isDown, vehicle);
    }
}
