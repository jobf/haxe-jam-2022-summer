package tyke.jam;


class ArrayExtensions{
    public static function all<T>(array:Array<T>, call:T->Void){
        for(item in array) call(item);
    }

    public static function firstOrNull<T>(array:Array<T>, evaluate:T->Bool):T{
        for(item in array){
            if(evaluate(item)) return item;
        }
        return null;
    }
}