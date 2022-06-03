package tyke;

import echo.util.Debug;
import tyke.Stage;
import tyke.Graphics;

interface Collidable {
	function collide(a:Body, b:Body, collisions:Array<CollisionData>):Void;
}

class HardLight implements Collidable {
	public var graphic(default, null):Shape;
	public var body(default, null):Body;
	public var entity(default, null):Collidable;

	public function new(?entity:Collidable, config:BodyOptions, world:World, shapes:ShapeRenderer, color:Color = Color.LIME) {
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

class EchoDebug extends Debug {
	public var canvas:RectangleRenderer;
	var rectangles:Array<Rectangle> = [];
	
	public function new(canvas:RectangleRenderer) {
		this.canvas = canvas;

		shape_color = 0x5b6ee1aa;
		shape_fill_color = 0xcbdbfcaa;
		shape_collided_color = 0xd95763aa;
		quadtree_color = 0x847e87aa;
		quadtree_fill_color = 0x9badb7aa;
		intersection_color = 0xcbdbfcaa;
		intersection_overlap_color = 0xd95763aa;
	}

	override public inline function draw_line(from_x:Float, from_y:Float, to_x:Float, to_y:Float, color:Int, alpha:Float = 1.) {
		var a = to_x - from_x;
		var b = to_y - from_y;
		var lineWidth = 3;
		var lineLength = Math.sqrt(a * a + b * b);
		var lineRotation = Math.atan2(from_x - to_x, -(from_y - to_y)) * (180 / Math.PI);
		rectangles.push(canvas.makeRectangle(from_x, from_y, lineWidth, lineLength, lineRotation, shape_color));
	}

	override public inline function draw_rect(min_x:Float, min_y:Float, width:Float, height:Float, color:Int, ?stroke:Int, alpha:Float = 1.) {
		// canvas.beginFill(color, alpha);
		// stroke != null ? canvas.lineStyle(shape_outline_width, stroke, 1) : canvas.lineStyle();
		// canvas.drawRect(min_x, min_y, width, height);
		// canvas.endFill();
		// todo !
		// rectangles.push(canvas.makeRectangle(min_x, min_y, width, height, 0, shape_fill_color));
	}

	override public inline function draw_circle(x:Float, y:Float, radius:Float, color:Int, ?stroke:Int, alpha:Float = 1.) {
		// todo !
		// canvas.drawCircle(x, y, radius);
	}

	override public function draw_polygon(count:Int, vertices:Array<Vector2>, color:Int, ?stroke:Int, alpha:Float = 1) {
		if (count < 2)
			return;

		var start_x = vertices[0].x;
		var start_y = vertices[0].y;
		var from_x = start_x;
		var from_y = start_y;
		for (i in 1...count) {
			var to_x = vertices[i].x;
			var to_y = vertices[i].y;
			draw_line(from_x, from_y, to_x, to_y, color, alpha);
			from_x = to_x;
			from_y = to_y;
		}
		draw_line(from_x, from_y, start_x, start_y, color, alpha);
	}

	override public inline function clear() {
		var i = rectangles.length;
		while(i > 0){
			var element = rectangles.pop();
			@:privateAccess
			canvas.buffer.removeElement(element);
			i--;
		}
	}
}
