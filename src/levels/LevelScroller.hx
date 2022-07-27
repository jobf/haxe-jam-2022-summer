package levels;

import echo.Body;
import peote.view.Display;
import tyke.Graphics.RectangleGeometry;

class LevelScroller {
	var viewGeometry:RectangleGeometry;
	var display:Display;
	var target:Body;
	var marginX:Int = 32 * 9;
	var marginY:Int = 32;

	public function new(display:Display, viewWidth:Int, viewHeight:Int, target:Body) {
		this.display = display;
		viewGeometry = {
			y: 0,
			x: 0,
			width: viewWidth,
			height: viewHeight
		};

		this.target = target;
	}

	public function update(elapsedSeconds:Float) {
		if (target.velocity.x > 0 && target.x > viewGeometry.x + viewGeometry.width - marginX) {
			scrollRight();
		}
		if (viewGeometry.x > 0 && target.velocity.x < 0 && target.x < viewGeometry.x + marginX) {
			scrollLeft();
		}
		if (target.velocity.y > 0 && target.y > viewGeometry.y + viewGeometry.height - marginY) {
			scrollDown();
		}
		if (viewGeometry.y > 0 && target.velocity.y < 0 && target.y < viewGeometry.y + marginY) {
			scrollUp();
		}
	}

	inline function scrollRight() {
		// trace('scrollRight');
		viewGeometry.x = Std.int(target.x + marginX - viewGeometry.width);
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	inline function scrollLeft() {
		// trace('scrollLeft');
		viewGeometry.x = Std.int(target.x - marginX);
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	inline function scrollDown() {
		trace('scrollDown');
		viewGeometry.y = Std.int(target.y + marginY - viewGeometry.height);
		display.yOffset = -viewGeometry.y;
		// viewGeometry.trace();
	}

	inline function scrollUp() {
		trace('scrollUp');
		viewGeometry.y = Std.int(target.y - marginY);
		display.yOffset = -viewGeometry.y;
		// viewGeometry.trace();
	}

	public function edgeOfViewLeft():Int {
		return viewGeometry.x;
	}
}
