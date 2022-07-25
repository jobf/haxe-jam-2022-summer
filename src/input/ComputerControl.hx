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
        buttonStates = [
            0 => {
                isDown: false,
                action: (isDown, vehicle) -> vehicle.controlReverse(isDown)
            },
            1 => {
                isDown: false,
                action: (isDown, vehicle) -> vehicle.controlAccelerate(isDown)
            },
            // 2 => {
            //     isDown: false,
            //     action: (isDown, vehicle) -> vehicle.controlUp(isDown)
            // },
            // 3 => {
            //     isDown: false,
            //     action: (isDown, vehicle) -> vehicle.controlDown(isDown)
            // }
        ];
        maximumStateId = 1;
		alterControlCountDown = new CountDown(2.0, () -> alterControl(), true);
	}

	public function update(elapsedSeconds:Float) {
		alterControlCountDown.update(elapsedSeconds);
        vehicle.update(elapsedSeconds);
	}

	var buttonStates:Map<Int, ButtonState>;
    var maximumStateId:Int;

    var lastChangedStateId:Int = -1;
	function alterControl() {
        var nextPressState = randomChance();
        
        // is button down
        if(lastChangedStateId >= 0){
            if(buttonStates[lastChangedStateId].isDown != nextPressState){
                buttonStates[lastChangedStateId].isDown = nextPressState;
                buttonStates[lastChangedStateId].control(vehicle);
            }
        }
        else{
            lastChangedStateId = randomInt(maximumStateId);
            if(buttonStates[lastChangedStateId].isDown != nextPressState){
                buttonStates[lastChangedStateId].isDown = nextPressState;
                buttonStates[lastChangedStateId].control(vehicle);
            }
        }
        
        if(!nextPressState){
            lastChangedStateId = -1;
        }
	}
}

@:structInit
class ButtonState {
	public var action:(isDown:Bool, vehicle:Vehicle)->Void;
	public var isDown:Bool;
    public function control(vehicle:Vehicle){
        action(isDown, vehicle);
    }
}