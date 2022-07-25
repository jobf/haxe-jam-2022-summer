package pieces;

import tyke.Graphics;
import tyke.Graphics.SpriteRenderer;
import echo.Body;
import echo.World;
import tyke.Graphics.RectangleGeometry;

enum ObstacleType{
    RAMP;
    HOLE;
    WATER;
}

class Obstacle{
    var body:Body;
    var sprite:Sprite;
    var type:ObstacleType;

    public function new(type:ObstacleType, geometry:RectangleGeometry, world:World, sprites:SpriteRenderer){
        this.type = type;
        body = new Body({
            shape: {
                width: geometry.width,
                height: geometry.height
            },
            kinematic: true,
            mass: 1,
            x: geometry.x,
            y: geometry.y
        });

        var spriteSize = 32;

        // convert ObstacleType to tileIndex
        var tileIndex:Int = switch type{
            case RAMP: 1;
            case WATER: 2;
            case HOLE: 0;
        }

        // instance a new sprite
        sprite = sprites.makeSprite(geometry.x, geometry.y, spriteSize, tileIndex);
        
        // bind movement in case we add moving obstacles
        body.on_move = (x, y) -> sprite.setPosition(x, y);
        
        // register body in physics simulation
        world.add(body);
    }

}