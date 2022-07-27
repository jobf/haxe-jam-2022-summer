package pieces;


import peote.view.PeoteView;
import tyke.Graphics;
import peote.view.Color;
import tyke.Graphics.Geometry;
import echo.Collider;
import echo.data.Options;
import echo.Body;
import echo.World;
import tyke.Loop.CountDown;
import tyke.Graphics.ShapeRenderer;
import tyke.Graphics.SpriteRenderer;

@:structInit
class PieceCore {
	public var tiles:SpriteRenderer;
	public var shapes:ShapeRenderer;
	public var world:World;
	public var peoteView:PeoteView;
}

@:structInit
class PieceOptions{
    public var bodyOptions:BodyOptions;
    public var shape:Geometry;
    public var debugColor:Color;
    public var spriteTileId:Int;
    public var spriteTileSize:Int;
    public var collisionType:CollisionType;
}

class BasePiece  {
	public var body(default, null):Body;
    public var sprite(default, null):Sprite;
	public var debug(default, null):Shape;

	var core:PieceCore;
	var options:PieceOptions;
    var behaviours:Array<CountDown>;

	public function new(core:PieceCore, options:PieceOptions) {
		this.core = core;
		this.options = options;
        behaviours = [];
        init();
	}

    inline function init(){
        // init graphics
        var x = Std.int(options.bodyOptions.x);
        var y = Std.int(options.bodyOptions.y);
        sprite = core.tiles.makeSprite(x, y, options.spriteTileSize, options.spriteTileId);
        debug = core.shapes.makeShape(x, y, Std.int(options.bodyOptions.shape.width), Std.int(options.bodyOptions.shape.height), options.shape, options.debugColor);

        // init body for arcade physics
        body = new Body(options.bodyOptions);
        
        // move graphics with body
        body.on_move = (x, y) -> {
            sprite.x = x;
            sprite.y = y;
            debug.x = x;
            debug.y = y;
        }
        
        // rotate graphics with body
        body.on_rotate = r -> {
            sprite.rotation = r;
            debug.rotation = r;
        }
        
		// store reference to Collider helper class for use in collisions
		body.collider = new Collider(options.collisionType, body -> collideWith(body));
		
        // register body in world
		core.world.add(body);
    }

	public function update(elapsedSeconds:Float) {
        for(b in behaviours){
            b.update(elapsedSeconds);
        }
    }

    inline function stop() {
		body.velocity.x = 0;
		body.velocity.y = 0;
	}

    function collideWith(body:Body) {
        // override me
    }
	
}
