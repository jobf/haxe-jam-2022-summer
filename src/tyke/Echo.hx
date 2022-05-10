package tyke;

import tyke.Stage;
import tyke.Sprites;

enum Geometry {
	RECT;
	CIRCLE;
	POLYGON(numSides:Int);
}

class Utility {
	public function new(onCollide:Void->Void) {
		this.onCollide = onCollide;
	}

	var onCollide:Void->Void;

	public function collide() {
		onCollide();
	}
}

class DrawShapes implements IHaveGraphicsBuffer {
	// var display:Display;
	var buffer:Buffer<Shape>;
	var _program:Program;

	public var program(get, null):Program;

	public function get_program():Program {
		return _program;
	}

	public function new(bufferSize:Int = 256) {
		// this.display = display;
		buffer = new Buffer<Shape>(bufferSize, bufferSize, true);
		_program = new Program(buffer);
		_program.setFragmentFloatPrecision("high");
		_program.discardAtAlpha(null);
		final injectTimeUniform = false;
		_program.injectIntoFragmentShader(Shape.InjectFragment, injectTimeUniform);
		_program.setColorFormula(Shape.ColorFormula);
	}

	public function makeShape(body:BodyOptions, shape:Geometry, color:Color = Color.LIME):Shape {
		var width = Std.int(body.shape.width);
		var height = Std.int(body.shape.height);

		var shapeType:Int = switch (shape) {
			case CIRCLE: 1;
			case RECT: 0;
			case _: 2; // polygon
		}
		var numSides = switch (shape) {
			case CIRCLE: 1;
			case POLYGON(sides): sides;
			case _: 4;
		}

		var shape = new Shape(Std.int(body.x), Std.int(body.y), width, height, shapeType, numSides, color);
		buffer.addElement(shape);
		return shape;
	}

	public function updateGraphicsBuffers() {
		// trace('echo');
		buffer.update();
	}
}

	}

	public var visible(get, set):Bool;

	function get_visible():Bool {
		return color.alpha == 0;
	}

	function set_visible(isVisible:Bool):Bool {
		color.alpha = isVisible ? 0xff : 0x00;
		return isVisible;
	}
}
