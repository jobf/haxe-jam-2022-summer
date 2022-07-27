package pieces;

import pieces.BasePiece;
import echo.Body;


class Obstacle extends BasePiece{
    public function new(core:PieceCore, options:PieceOptions) {
		super(core, options);
	}

    override function collideWith(body:Body) {
        super.collideWith(body);
        
        if(body.collider.type == VEHICLE){
            if(this.body.collider.type == RAMP){
                this.body.remove();
                // todo animate ramp collapse
                this.sprite.tile = this.sprite.tile + 2;
            }
            else if(this.body.collider.type == INFLATABLE){
                this.body.kinematic = false;
                this.body.velocity.set(body.velocity.x, 45);
            }
        }
    }
}
