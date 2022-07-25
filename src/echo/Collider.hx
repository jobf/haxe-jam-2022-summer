package echo;

class Collider{
    var onCollide:Body -> Void;
    public var type:CollisionType;

    public function new(type:CollisionType, onCollide:Body->Void){
        this.onCollide = onCollide;
        this.type = type;
    }

    public function collideWith(collidingBody:Body){
        onCollide(collidingBody);
    }
}

enum CollisionType{
    UNDEFINED;
    VEHICLE;
    RAMP;
    HOLE;
    WATER;
}