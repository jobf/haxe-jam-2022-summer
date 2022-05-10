package tyke;

import tyke.Loop;
import tyke.Loop.Text;
import tyke.Stage;


class Sprite implements Element {
	// @posX public var x:Int;
	// @posY public var y:Int;
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float;
	@rotation public var rotation:Float;

	/** element width (can be negative when x is flipped, e.g. 400 would be -400)**/
	@sizeX public var w:Int;

	/** element height (can be negative when y is flipped, e.g. 400 would be -400)**/
	@sizeY public var h:Int;

	/** actual width (does not change when x is flipped )**/
	public var width(default, null):Int;

	/** actual height (does not change when y is flipped )**/
	public var height(default, null):Int;

	// Texture properties
	// @texSlot public var slot:Int = 1;
	// @texUnit() public var unit:Int = 1;
	@texSlot("base") public var slot:Int = 0;
	@color public var c:Color = 0xaabb00ff;
	@texTile() public var tile:Int = 0;

	// at what peote.time it have to shake
	@custom public var shakeAtTime:Float = -100.0;
	@custom public var shakeDurationX:Float = 1.2;
	@custom public var shakeDurationY:Float = 0.9;

	// params for shake: number of shakes, size in pixel, durationtime in seconds
	@posX @set("Position") @formula("x + shake(shakeAtTime, 7.0, 8.0, shakeDurationX)") public var x:Float;
	@posY @set("Position") @formula("y + shake(shakeAtTime, 5.0, 6.0, shakeDurationY)") public var y:Float;

	var OPTIONS = {alpha: true};

	public static var InjectVertex = "
	#define TWO_PI 6.28318530718
	float shake( float atTime, float freq, float size, float duration )
	{
		float t = max(0.0, uTime - atTime);				
		t = (clamp(t, 0.0, duration) / duration);			
		// return 1.0 - size + size * sin(freq * TWO_PI * t) * (t+0.5)*t*t*(t-1.0)*(t-1.0)*15.5;
		return size * sin(freq * TWO_PI * t) * (t+0.5)*t*t*(t-1.0)*(t-1.0)*15.5;
	}
	";

	public static var InjectFragment = "";

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int, height:Int, tile:Int = 0, tint:Int = 0xffffffFF, isVisible:Bool = true) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.width = this.w;
		this.height = this.h;
		this.c = tint;
		this.tile = tile;
		this.visible = isVisible;
	}

	public function shake(atTime:Float) {
		shakeAtTime = atTime;
		// buffer.updateElement(this);
	}

	public var isFlippedX(default, null):Bool;

	public function flipX(isFlipped:Bool) {
		isFlippedX = isFlipped;
		var flipBy = isFlippedX ? -1 : 1;
		// var adjustPosBy = isFlippedX ? width * 0.5 : 0;
		w = width * flipBy;
		// x += adjustPosBy;
	}

	public var visible(get, set):Bool;

	function get_visible():Bool {
		return c.alpha == 0;
	}

	function set_visible(isVisible:Bool):Bool {
		c.alpha = isVisible ? 0xff : 0x00;
		return isVisible;
	}
	var debugElement:Shape;
	public function attachDebug(debug:Shape){
		this.debugElement = debug;
	}

	public function move(x:Float, y:Float){
		this.x = x;
		this.y = y;
		if(debugElement != null){
			debugElement.x = x;
			debugElement.y = y;
		}
	}

	public function rotate(r:Float){
		this.rotation = r;
		if(debugElement != null){
			debugElement.rotation = r;
		}
	}
}

class Shape implements Element {
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float;
	@rotation public var rotation:Float;
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	@color public var color:Color = 0xaabb00ff;
	// @color public var c:Color = 0xaabb00ff;
	@posX @set("Position") public var x:Float;
	@posY @set("Position") public var y:Float;
	@custom @varying public var sides:Float = 3.0;
	@custom @varying public var shape:Float = 0.0;

	var OPTIONS = {alpha: true};

	public static var InjectFragment = "
    #define PI 3.14159265359
    #define TWO_PI 6.28318530718
    
    // from the book of shaders https://thebookofshaders.com/07/
	// only triangle is correct at the moment
	// todo ! calculate r for n sided polygons
	// or use vertices data from echo shape
    vec4 polygon(vec4 c, float sides){
        // Remap the coord for
        vec2 coord = vTexCoord;
        coord.y = (1.0 - coord.y);

        // Remap the space to -1. to 1.
        vec2 st = coord * 2.0-1.0;

        // Angle and radius from the current pixel
        float r = TWO_PI/sides;
        float a = atan(st.x,st.y) + PI;

        // Shaping function that modulate the distance
        float d = cos(floor(.5+a/r)*r-a)*length(st);
        float A = 1.0-smoothstep(.5,.51,d) == 1.0 ? c.a : 0.0;
        return vec4(c.rgb, A);
    }

    // // https://github.com/ayamflow/glsl-2d-primitives/blob/master/polygon.glsl
    // vec4 polygon(vec4 c, float sides){
    //     vec2 st = vTexCoord * 2.0 - 1.0;
    //     st.y  = (1.0 - st.y);
    //     float angle = atan(st.x,st.y) + PI;
    //     float slice = TWO_PI / sides;
    //     // float radius = 0.4;
    //     float radius = 0.5;//1.0;//0.7;//sides / 10.0;
    //     // float x = vSize.x; 
    //     // float radius = 1.0 / cos(x) * (180.0 / sides);
    //     float s = step(radius, cos(floor(0.5 + angle / slice ) * slice - angle) * length(st));
    //     float A = 1.0 - s == 1.0 ? c.a : 0.0;
    //     return vec4(c.rgb, A);
    // }

    float circle(vec2 st, float radius)
    {
        vec2 dist = st-vec2(0.5);
        return 1.-smoothstep(radius-(radius*0.01),
                             radius+(radius*0.01),
                             dot(dist,dist)*4.0
                            );
    }

    vec4 compose(vec4 c, float shapeType, float numSides){
        // return vec4(0.8,0.8,0.8,1.0);
        if(shapeType <= 0.0 ){
            return c;
        }
        // circle
        if(shapeType == 1.0){
            float a = circle(vTexCoord, 1.0) == 1.0 ? c.a : 0.0;
			return vec4(c.rgb, a);
        }
        // polygon
        return polygon(c, numSides);
    }
    ";

	public static var ColorFormula = "compose(color, shape, sides)";

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int, height:Int, shapeType:Int, numSides:Float = 3.0, color:Int = 0xffffffFF) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.shape = shapeType;
		this.color = color;
		this.sides = numSides;
		// todo visible should honour alpha not be on or off
		// this.visible = true;
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

typedef AnimationId = String;

class Animation {
	public var frameCollections(default, null):Map<AnimationId, Array<Int>>;
	public var frameIndex(default, null):Int;
	public var currentAnimation(default, null):AnimationId;

	var onAdvance:Animation->Void;

	public function new(?frameCollections:Map<AnimationId, Array<Int>>, startIndex:Int = 0, ?onAdvance:Animation->Void) {
		this.frameCollections = frameCollections == null ? [] : frameCollections;
		frameIndex = startIndex;
		this.onAdvance = onAdvance;
	}

	public function advance() {
		if (frameCollections.exists(currentAnimation)) {
			frameIndex++;
			frameIndex = frameIndex % frameCollections[currentAnimation].length;
			if (onAdvance != null) {
				onAdvance(this);
			}
		}
		// if (frameIndex > frames.length - 1) {
		// 	frameIndex = 0;
		// }
	}

	public function addAnimation(name:String, frameIndexes:Array<Int>) {
		frameCollections[name] = frameIndexes;
	}

	public function setAnimation(key:AnimationId) {
		currentAnimation = key;
	}

	public function currentTile():Int {
		return frameCollections[currentAnimation][frameIndex];
	}
}

class GlyphFrames implements IHaveGraphicsBuffer {
	var text:Text;

	public var program(get, null):Program;

	function get_program():Program {
		return text.fontProgram;
	}

	public var fontProgram(get, null):FontProgram<FontStyle>;

	function get_fontProgram():FontProgram<FontStyle> {
		return text.fontProgram;
	}

	public function new(font:Font<FontStyle>) {
		text = Glyphs.initText(font);
	}

	/* redraw all sprites, e.g. call this in draw loop */
	public function updateGraphicsBuffers() {
		text.fontProgram.updateGlyphes();
	}
}

/* Handle Sprites from spritesheet Image */
class SpriteFrames implements IHaveGraphicsBuffer {
	var spriteSheet:Texture;
	var buffer:Buffer<Sprite>;
	var _program:Program;

	public var program(get, null):Program;

	function get_program():Program {
		return _program;
	}

	public function new(image:Image, frameSize:Int, bufferSize:Int = 256) {
		spriteSheet = new Texture(image.width, image.height);
		spriteSheet.tilesX = Std.int(image.width / frameSize);
		spriteSheet.tilesY = Std.int(image.height / frameSize);
		spriteSheet.setImage(image, 0);
		buffer = new Buffer<Sprite>(bufferSize, bufferSize, true);
		_program = new Program(buffer);
		_program.setFragmentFloatPrecision("high");
		_program.discardAtAlpha(null);
		_program.injectIntoVertexShader(Sprite.InjectVertex, true);
		_program.injectIntoFragmentShader(Sprite.InjectFragment, false);
		_program.addTexture(spriteSheet, "base");
	}

	public function makeSprite(x:Int, y:Int, spriteSize:Int, tileIndex:Int, framesIndex:Int = 0, isVisible:Bool = true):Sprite {
		var sprite = new Sprite(x, y, spriteSize, spriteSize, tileIndex, isVisible);
		buffer.addElement(sprite);
		return sprite;
	}

	/* redraw all sprites, e.g. call this in draw loop */
	public function updateGraphicsBuffers() {
		buffer.update();
	}
}

class FilterElement implements Element {
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;

	@sizeX public var w:Int = 100;
	@sizeY public var h:Int = 100;
	@texSlot("base") public var slot:Int = 0;
	@color public var c:Color = 0xff0000ff;

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int = 100, height:Int = 100, color:Color) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = color;
	}
}

class ColorFilterFormulas {
	public static var Hues = '
	vec4 compose(){
		// time varying pixel color
		vec3 col = 0.5 + 0.5*cos(uTime+vTexCoord.xyx+vec3(0,2,4));
		return vec4(col * 0.5, 0.5);
	}
	';

	public static var Gradient = '
	vec4 compose(){
		// y varying pixel alpha
		float fmin = 0.3;
		float fmod = mod(vTexCoord.y, 2.0);
		float fstep = fmin + (1.0 - fmin) * fmod;
		return vec4(1.0, 1.0, 1.0, fstep);
	}
	';
}

class FrameBufferFormulas {
	public static var PassThroughFilter = '
	vec4 globalCompose( int textureID ){
		return getTextureColor(textureID, vTexCoord);
	}';

	// needs work, see https://www.shadertoy.com/view/XdScD1
	public static var TwistingRings = '
	#define TWO_PI 6.2831

	vec2 rotate (vec2 coord, float angle, vec2 iResolution){
		float sin_factor = sin(angle);
		float cos_factor = cos(angle);
		vec2 c = vec2((coord.x - 0.5) * (iResolution.x / iResolution.y), coord.y - 0.5) * mat2(cos_factor, sin_factor, -sin_factor, cos_factor);
		c += 0.5;
    	return c;
	}

	vec4 globalCompose( int textureID ){
		vec2 res = getTextureResolution(textureID);
		vec2 uv = vTexCoord ;
		vec2 tc = uv / res;
		tc = vTexCoord;
		
		float rings = 30.0;
		float d = 1.0 - floor(distance(vec2(0.5 * (res.x/res.y), 0.5),vec2(tc.x * (res.x/res.y), tc.y))*rings)/rings;
		
		return getTextureColor(textureID, tc + rotate(tc, uTime, res)*d);
	}
	';


	// inspired by https://www.shadertoy.com/view/4sBBDK
	public static var DotScreen = '
	float greyScale(in vec3 col) {
		return dot(col, vec3(0.2126, 0.7152, 0.0722));
	}

	mat2 rotate2d(float angle){
		return mat2(cos(angle), -sin(angle), sin(angle),cos(angle));
	}

	float dotScreen(in vec2 uv, in float angle, in float scale, vec2 res) {
		float s = sin( angle ), c = cos( angle );
		vec2 p = (uv - vec2(0.5)) * res.xy;
		vec2 q = rotate2d(angle) * p * scale; 
		return ( sin( q.x ) * sin( q.y ) ) * 4.0;
	}

	vec4 globalCompose( int textureID ){
		vec2 uv = vTexCoord;
		vec3 col = getTextureColor(textureID, vTexCoord).rgb; 
		float grey = greyScale(col); 
		float angle = 0.4;
		float scale = 1.0 + 0.8 * sin(uTime); 
		vec2 res = getTextureResolution(textureID);
		col = vec3( grey * 10.0 - 5.0 + dotScreen(uv, angle, scale, res ) );
		vec3 tex = getTextureColor(textureID, vTexCoord).rgb;
		return vec4( mix(col, tex, 0.9), 1.0 );
	}
	';
}

class Filter {
	var buffer:Buffer<FilterElement>;
	var program:Program;

	public function new(width:Int, height:Int, colorFormula:String, injectTimeUniform:Bool = false) {
		final bufferSize = 1;
		buffer = new Buffer<FilterElement>(bufferSize, bufferSize, true);
		program = new Program(buffer);
		// program.setFragmentFloatPrecision("high");
		program.discardAtAlpha(null);
		var color = 0x113366.RGBA(0xcc);
		var element = new FilterElement(0, 0, width, height, 0x000000ff);
		buffer.addElement(element);
		program.injectIntoFragmentShader(colorFormula, injectTimeUniform);
		program.setColorFormula('compose()');
	}

	/* register for drawing on a Display */
	public function addToDisplay(display:Display) {
		display.addProgram(program);
	}
}
