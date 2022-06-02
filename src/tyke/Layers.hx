package tyke;

import tyke.Grid;
import tyke.Glyph;

@:structInit
class LayerConfig<T> {
	public var numColumns:Int;
	public var numRows:Int;
	public var cellWidth:Int;
	public var cellHeight:Int;
	public var palette:Palette;
	public var cellInit:(Column, Row) -> T;
}

typedef GlyphGridConfig = LayerConfig<GlyphModel>

class GlyphGrid extends GridStructure<GlyphModel> {
	
	public var hasChanged:Bool = false;
	public var offsetX:Int;
	public var offsetY:Int;
	public var cellWidth(get, null):Float;
	public var cellHeight(get, null):Float;
	public var palette(default, null):Palette;

	var fontProgram:FontProgram<FontStyle>;
	var fontStyle:FontStyle;

	function get_cellWidth():Float {
		return fontStyle == null ? 20 : fontStyle.width;
	}

	function get_cellHeight():Float {
		return fontStyle == null ? 36 : fontStyle.height;
	}

	public function new(config:GlyphGridConfig, fontProgram:FontProgram<FontStyle>) {
		super(config.numColumns, config.numRows, config.cellInit);
		palette = config.palette;
		this.fontProgram = fontProgram;
		fontProgram.fontStyle.bgColor = 0x00000000;
		final space = 0x20;
		if (config.cellInit == null) {
			config.cellInit = (column, row) -> {
				var charCode = 0;
				var x = column * config.cellWidth;
				var y = row * config.cellHeight;
				return {
					char: charCode,
					glyph: fontProgram.createGlyph(space, x, y, fontProgram.fontStyle),
					paletteIndexFg: 10,
					paletteIndexBg: -1,
					bgIntensity: 1.0
				};
			}
		}
	}

	public function onTick(tick:Int):Void {
		// hasChanged = true;
	}

	public function draw() {
		// trace('draw');
		for (i => cell in cells) {
			cell.glyph.color = palette.colorOrDefault(cell.paletteIndexFg);
			var bgColor = palette.colorOrDefault(cell.paletteIndexBg);
			if (cell.paletteIndexBg > 0) {
				var alpha = Math.ceil(255 * cell.bgIntensity);
				cell.glyph.bgColor = bgColor.changeAlpha(alpha);
			}
			// null cell must be 'space' to have any graphic - todo draw at beginining
			fontProgram.glyphSetChar(cell.glyph, cell.char == 0x0 ? " ".charCodeAt(0) : cell.char);
		}
	}

	public function screenToGrid(pixelX:Float, pixelY:Float, pixelW:Float, pixelH:Float):Point {
		var pX = pixelX / pixelW;
		var pY = pixelY / pixelH;
		var numVisibleColumns = pixelW / fontProgram.fontStyle.width;
		var numVisibleRows = pixelH / fontProgram.fontStyle.height;
		var c = Math.floor(pX * numVisibleColumns);
		var r = Math.floor(pY * numVisibleRows);
		return {x: c, y: r};
	}

	public function windowToDisplay(mouseX:Float, mouseY:Float, windowWidth:Float, windowHeight:Float, displayWidth:Float, displayHeight:Float):Point {
		var pX = mouseX / windowWidth;
		var pY = mouseY / windowHeight;
		var x = Std.int(pX * displayWidth);
		var y = Std.int(pY * displayHeight);
		return {x: x, y: y};
	}

	public function writeText(column:Int, row:Int, text:String, trimAt:Int = 0) {
		var chars = text.split("");
		var width = trimAt == 0 ? chars.length : trimAt;
		for (x in 0...width) {
			var char = x < chars.length ? chars[x] : " ";
			trace('column $column $char');
			var cell = get(column + x, row);
			cell.char = char.charCodeAt(0);
			cell.paletteIndexFg = 9;
		}
		hasChanged = true;
	}
}

