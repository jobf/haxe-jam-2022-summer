package levels;

import echo.Body;
import peote.view.Display;
import tyke.Graphics.RectangleGeometry;

class LevelScroller {
	var viewGeometry:RectangleGeometry;
	var display:Display;
	var targetGeometry:RectangleGeometry;
	var target:Body;
	var margin:Int = 32 * 5;

	public function new(display:Display, viewWidth:Int, viewHeight:Int, targetGeometry:RectangleGeometry, target:Body) {
		this.display = display;
		viewGeometry = {
			y: 0,
			x: 0,
			width: viewWidth,
			height: viewHeight
		};

		this.targetGeometry = targetGeometry;
		this.target = target;
	}

	public function update(elapsedSeconds:Float) {
		if (target.velocity.x > 0 && targetGeometry.x > viewGeometry.x + viewGeometry.width - margin) {
			scrollRight();
		}
		if (viewGeometry.x > 0 && target.velocity.x < 0 && targetGeometry.x < viewGeometry.x + margin) {
			scrollLeft();
		}
	}

	inline function scrollRight() {
		// trace('scrollRight');
		viewGeometry.x = targetGeometry.x + margin - viewGeometry.width;
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	inline function scrollLeft() {
		// trace('scrollLeft');
		viewGeometry.x = targetGeometry.x - margin;
		display.xOffset = -viewGeometry.x;
		// viewGeometry.trace();
	}

	public function edgeOfViewLeft():Int {
		return viewGeometry.x;
	}
}
