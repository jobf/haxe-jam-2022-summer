package echo;

class Collider{
    var onCollide:Body -> Void;

    public function new(onCollide:Body->Void){
        this.onCollide = onCollide;
    }

    public function collideWith(collidingBody:Body){
        onCollide(collidingBody);
    }
}