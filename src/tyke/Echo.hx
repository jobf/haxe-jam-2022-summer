package tyke;

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

