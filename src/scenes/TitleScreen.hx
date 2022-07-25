package scenes;

import input.Controller;
import tyke.jam.Scene;
import lime.ui.KeyCode;

class TitleScreen extends Scene {
  override function create() {
    trace("welcome to the title screen! press enter to play rectangles");

    sceneManager.keyboard.bind(KeyCode.RETURN, "PLAY", "Play the game", loop -> sceneManager.changeScene(new GetawayScene(sceneManager)));
  }
}
