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
	var buffer:Buffer<Shape>;
	var _program:Program;

	public var program(get, null):Program;

	public function get_program():Program {
		return _program;
	}

	public function new(bufferSize:Int = 256) {
		buffer = new Buffer<Shape>(bufferSize, bufferSize, true);
		_program = new Program(buffer);
		_program.setFragmentFloatPrecision("high");
		_program.discardAtAlpha(null);
		final injectTimeUniform = false;
		_program.injectIntoFragmentShader(Shape.InjectFragment, injectTimeUniform);
		_program.setColorFormula(Shape.ColorFormula);
	}

	public function makeShape(x:Int, y:Int, width:Int, height:Int, shape:Geometry, color:Color = Color.LIME):Shape {
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

		var shape = new Shape(Std.int(x), Std.int(y), width, height, shapeType, numSides, color);
		buffer.addElement(shape);
		return shape;
	}

	public function updateGraphicsBuffers() {
		// trace('echo');
		buffer.update();
	}
}



interface Collidable {
	function collide(a:Body, b:Body, collisions:Array<CollisionData>):Void;
}

class HardLight implements Collidable {
	public var graphic(default, null):Shape;
	public var body(default, null):Body;
	public var entity(default, null):Collidable;

	public function new(?entity:Collidable, config:BodyOptions, world:World, shapes:DrawShapes, color:Color = Color.LIME) {
		body = world.make(config);
		body.on_move = onMove;
		body.on_rotate = onRotate;
		body.hardlight = this;

		this.entity = entity == null ? this : entity;
		
		var geo:Geometry = switch (body.shape.type) {
			case CIRCLE: CIRCLE;
			case POLYGON: POLYGON(config.shape.sides);
			case _: RECT;
		};
		var x = Std.int(config.x);
		var y = Std.int(config.y);
		var width = Std.int(config.shape.width);
		var height = Std.int(config.shape.height);
		graphic = shapes.makeShape(x, y, width, height, geo, color);
	}

	var debounceDelay = 50;

	public function collide(body1:Body, body2:Body, collisions:Array<CollisionData>) {
		var timeNow = Date.now().getTime(); // todo ? use peote time
		if ((timeNow - lastCollideTime) > debounceDelay) {
			lastCollideTime = timeNow;
			lit = !lit;
			graphic.color.a = lit ? 0xaa : 0x99;
		}
	}

	function onMove(x:Float, y:Float) {
		graphic.setPosition(x, y);
	}

	function onRotate(r:Float) {
		graphic.rotation = r;
	}

	function destroy() {
		body.active = false;
		// body.dispose(); todo - do all dispose together once per update 
		graphic.visible = false;
	}
	

	var lastCollideTime:Float;

	var lit:Bool;
}