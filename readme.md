# tyk(e)

A grid and a game loop, what more do you want...

~~glyphs~~ ~~sprites~~ ~~shaders~~?

api is still in the oven!

## Samples

Samples I am using to test the API etc. (works in progress).

### glyph manipulation, sprites, physics, shaders

https://jobf.github.io/tyke/

### glyph manipulation

https://jobf.github.io/tyke/glyph/

### physics

https://jobf.github.io/tyke/shapes/


## Quick start

You need [haxe](https://haxe.org/download/) and [lime](https://lib.haxe.org/p/lime/) installed first

### Install Dependencies

```thank you kindly ♥
# gl
haxelib git peote-view https://github.com/maitag/peote-view.git

# glyph
haxelib install json2object
haxelib git peote-text https://github.com/maitag/peote-text.git

# physics
haxelib install hxmath
haxelib git echo https://github.com/AustinEast/echo.git

# input (keyboard/game controller)
haxelib git input2action https://github.com/maitag/input2action.git

# glue
haxelib git ob.gum https://github.com/jobf/ob.gum.git
```

### Run

```shell
# change working directory
cd samples

# html5
lime test html5

# hashlink 
lime test hl

# =^.^=
lime test neko
```

#### Samples

There are multiple samples in the samples directory.

There are scripts to run each, following the command structure beneath.

```shell
lime test hl --app-main=App.CascadeApp
```