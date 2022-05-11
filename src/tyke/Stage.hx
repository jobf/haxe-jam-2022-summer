package tyke;

import tyke.Keyboard;
import tyke.Echo;
import tyke.Graphics;

class Stage {
	var display:Display;
	var program:Program;
	var globalFrameBuffer:FrameBuffer;
	var coreLoop:PeoteViewLoop;
	var sprites:Array<SpriteRenderer> = [];
	var layers:Map<String, Layer> = [];

	public var width(get, null):Int;
	public var height(get, null):Int;

	public function new(display:Display, coreLoop:PeoteViewLoop) {
		this.display = display;
		this.coreLoop = coreLoop;
		var buffer = new Buffer<ViewElement>(1);
		program = new Program(buffer);
		program.setFragmentFloatPrecision("high");
		program.alphaEnabled = true;
		program.discardAtAlpha(null);
		display.addProgram(program);
		var view = new ViewElement(0, 0, display.width, display.height);
		buffer.addElement(view);
		final isGlobalFrameBufferPersistent = false;
		globalFrameBuffer = makeFrameBuffer("globalFramebuffer", isGlobalFrameBufferPersistent);
	}

	public function globalFilter(formula:String, inject:String) {
		program.injectIntoFragmentShader(inject, true);
		program.setColorFormula(formula);
	}

	function chainFrameBuffer(frameBuffer:FrameBuffer, name:String) {
		program.addTexture(frameBuffer.texture, name, true);
	}

	function makeFrameBuffer(name:String, isPersistent:Bool):FrameBuffer {
		var frameBuffer = coreLoop.getFrameBufferDisplay(display.x, display.y, display.width, display.height, isPersistent);
		chainFrameBuffer(frameBuffer, name);
		return frameBuffer;
	}

	public function createLayer(name:String, isPersistentFrameBuffer:Bool, useGlobalFrameBuffer:Bool = true):Layer {
		var fb = useGlobalFrameBuffer ? globalFrameBuffer : makeFrameBuffer(name, isPersistentFrameBuffer);
		var layer = new Layer(fb);
		layers[name] = layer;
		return layer;
	}

	function initGraphicsBuffer(name:String, buffer:IHaveGraphicsBuffer, isPersistentFrameBuffer:Bool, isIndividualFrameBuffer:Bool ) {
		var layer = createLayer(name, isPersistentFrameBuffer, !isIndividualFrameBuffer);
		layer.registerGraphicsBuffer(buffer);
		layer.addProgramToFrameBuffer(buffer.program);
		layers[name] = layer;
	}

	public function createShapeRenderLayer(isPersistentFrameBuffer:Bool = false, isIndividualFrameBuffer:Bool = false):ShapeRenderer {
		final name = "echo";
		var frames = new ShapeRenderer();
		initGraphicsBuffer(name, frames, isPersistentFrameBuffer, isIndividualFrameBuffer);
		return frames;
	}

	public function createSpriteRendererLayer(name:String, image:Image, frameSize:Int, isPersistentFrameBuffer:Bool = false, isIndividualFrameBuffer:Bool = false):SpriteRenderer {
		var frames = new SpriteRenderer(image, frameSize);
		initGraphicsBuffer(name, frames, isPersistentFrameBuffer, isIndividualFrameBuffer);
		return frames;
	}

	public function createGlyphRendererLayer(name:String, font:Font<FontStyle>, isPersistentFrameBuffer:Bool = false, isIndividualFrameBuffer:Bool = false):GlyphRenderer {
		var frames = new GlyphRenderer(font);
		initGraphicsBuffer(name, frames, isPersistentFrameBuffer, isIndividualFrameBuffer);
		return frames;
	}

	public function updateGraphicsBuffers() {
		for (layer in layers) {
			layer.updateGraphicsBuffers();
		}
	}

	function get_width():Int {
		return display.width;
	}

	function get_height():Int {
		return display.height;
	}

	public function centerX():Float {
		return width * 0.5;
	}

	public function centerY():Float {
		return height * 0.5;
	}
}

class ViewElement implements Element {
	@posX var x:Int = 0;
	@posY var y:Int = 0;

	@sizeX var w:Int;
	@sizeY var h:Int;

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int, height:Int) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

typedef IsComplete = Bool;

typedef GranularAction = {
	isEnabled:Bool,
	perform:Tick->IsComplete,
}

class Tweens {
	var actions:Array<GranularAction>;

	public function new() {
		actions = [];
	}

	public function update(tick:Tick) {
		for (a in actions) {
			if (a.isEnabled) {
				a.isEnabled = !a.perform(tick);
			}
		}
	}

	public function add(action:GranularAction) {
		actions.push(action);
	}

	public static var linear:(time:Float, begin:Float, change:Float,
		duration:Float) -> Float = (time, begin, change, duration) -> return change * time / duration + begin;
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
