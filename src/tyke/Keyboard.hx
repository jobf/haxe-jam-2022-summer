package tyke;

@:generic
typedef KeyPress<T> = {
	description:String,
	label:String,
	code:KeyCode,
	handle:T->Void
}

@:generic
class KeyPresses<T> {
	var bindings:Map<KeyCode, KeyPress<T>>;
	var sortOrder:Array<Int>;
	var lastHandled:KeyCode;

	public function new(bindings:Array<KeyPress<T>>) {
		sortOrder = [];
		this.bindings = [];
		for (b in bindings) {
			_bind(b);
		}
	}

	public function handle(code:KeyCode, on:T) {
		lastHandled = code;
		// trace('keypress $code');
		if (bindings.exists(code)) {
			bindings[code].handle(on);
		}
	}

	function _bind(k:KeyPress<T>){
		sortOrder.push(k.code);
		bindings[k.code] = k; 
	}
	public function bind(code:KeyCode, label:String, description:String, handle:T->Void) {
		_bind({
			description: description,
			label: label,
			code: code,
			handle: handle
		});
	}

	function describe (k:KeyPress<T>):String{
		return '${k.label} ${k.description}';
	}

	public function listBindings():Array<String> {
		return [for(k in sortOrder) describe(bindings[k])];
	}

	public function lastPressed():KeyCode{
		return lastHandled;
	}
}