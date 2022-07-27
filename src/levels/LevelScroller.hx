package levels;

import echo.Body;
import peote.view.Display;
import tyke.Graphics.RectangleGeometry;

class LevelScroller {
	var viewGeometry:RectangleGeometry;
	var display:Display;
	var target:Body;
	var margin:Int = 32 * 9;

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
		if (target.velocity.x > 0 && target.x > viewGeometry.x + viewGeometry.width - margin) {
			scrollRight();
		}
		if (viewGeometry.x > 0 && target.velocity.x < 0 && target.x < viewGeometry.x + margin) {
			scrollLeft();
		}
	}

	inline function scrollRight() {
		// trace('scrollRight');
		viewGeometry.x = Std.int(target.x + margin - viewGeometry.width);
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	inline function scrollLeft() {
		// trace('scrollLeft');
		viewGeometry.x = Std.int(target.x - margin);
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	public function edgeOfViewLeft():Int {
		return viewGeometry.x;
	}
}
