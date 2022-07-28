package tyke.jam;

import lime.media.AudioBuffer;
import lime.app.Future;
import tyke.Loop.CountDown;
import lime.utils.Assets;
import lime.media.AudioSource;

class SoundManager {
	var musicFadeOutCountDown:CountDown;
	var music:AudioSource;
	var isStoppingMusic:Bool = false;
	var loadingMusic:Future<AudioBuffer>;

	public var isMusicPlaying(default, null):Bool;

	public function new() {
		musicFadeOutCountDown = new CountDown(0.2, () -> reduceMusicGain(), true);
		trace('initialized SoundManager');
	}

	/**
		can only be called after preload complete
	**/
	public function playMusic(assetPath:String) {
		trace('called playMusic()');
		loadingMusic = Assets.loadAudioBuffer(assetPath);
		loadingMusic.onComplete(buffer -> {
			music = new AudioSource(buffer);
			trace('init music AudioSource');
			music.play();
			trace('called music.play()');
			isMusicPlaying = true;
		});
		loadingMusic.onError(d -> {
			trace('error');
			trace(d);
		});
		loadingMusic.onProgress((i1, i2) -> {
			trace('loading music progress $i1 $i2');
		});
	}

	public function stopMusic() {
		if (isMusicPlaying && !isStoppingMusic) {
			trace('start fade out music');
			isStoppingMusic = true;
			musicFadeOutCountDown.reset();
		}
	}

	public function update(elapsedSeconds:Float) {
		if (isStoppingMusic) {
			musicFadeOutCountDown.update(elapsedSeconds);
		}
	}

	function reduceMusicGain():Void {
		trace('reduceMusicGain ${music.gain}');
		final fadeIncrement = 0.1;
		var nextGain = music.gain - fadeIncrement;
		if (nextGain < 0) {
			nextGain = 0;
		}
		music.gain = nextGain;
		if (music.gain <= 0) {
			music.stop();
			isStoppingMusic = false;
			isMusicPlaying = false;
		}
	}
}
