// This module sets up everything needed for the game: loads
// fonts and other resources, prepares the displays, etc.
// This module stuffs a fair number of things into the global
// namespace, since they are so commonly needed.  But we'll
// try to at least group things under their own little maps.

clear

// Prepare the "disp" map, containing all our displays.
// Set up and configure those displays.
globals.disp = {}

// disp.background: the starfield or whatever we use as the
// final background of the game
display(7).mode = displayMode.pixel
disp.background = display(7)
disp.background.clear color.black, 1920, 1280
disp.background.drawImage(file.loadImage("/usr/pics/stars.png"), 0, 0)

// disp.shipSprites: a SpriteDisplay for ship maps, plus 
// characters and objects that appear on or around the ships.
display(6).mode = displayMode.sprite
disp.shipSprites = display(6)
disp.shipSprites.clear

// disp.fog: a solid-color display that appears over the ship
// and its sprites, which we can use to show hide the ship
// (and background) intermittently due to dust clouds, sensor
// malfunctions, etc.
display(5).mode = displayMode.solidColor
disp.fog = display(5)
disp.fog.color = color.clear

// disp.uiPixel: a PixelDisplay for UI elements, including ship
// controls, status displays, event dialogs, etc.
// This is also the default gfx display.
display(4).mode = displayMode.pixel
disp.uiPixel = display(4)
disp.uiPixel.clear color.clear
globals.gfx = disp.uiPixel

// disp.uiSprites: a SpriteDisplay for UI elements, including
// a custom mouse cursor, buttons, etc.
display(3).mode = displayMode.sprite
disp.uiSprites = display(3)
disp.uiSprites.clear

// disp.curtain: a solid-color overlay used for fading to black,
// flashing red to show damage, etc.
display(2).mode = displayMode.solidColor
disp.curtain = display(2)
disp.curtain.color = color.clear

// disp.text: the standard text display.  We probably won't ever
// use this in the game, except for debugging.
display(1).mode = displayMode.text
globals.text = display(1) // map text globally
disp.text = text  // just an alias
text.color = color.orange
text.backColor = color.clear
text.clear

// Show what we're up to while loading the game.
showProgress = function(msg)
	gfx.fillRect 480-240, 100, 240*2, 24, "#000044"
	gfx.drawRect 480-240, 100, 240*2, 24, "#8888CC"
	loadFont("ArialBlack-14.bmf").printCentered msg, 480, 108
end function

// Load fonts
import "bmfFonts"
globals.fonts = {}

loadFont = function(filename)
	name = filename - ".bmf"
	name = name.replace("-", "")
	if not fonts.hasIndex(name) then
		path = file.child("/usr/fonts", filename)
		fonts[name] = bmfFonts.Font.load(path)
	end if
	return fonts[name]
end function

loadFonts = function()
	showProgress "Loading fonts"
	y = 600
	fontsFolder = "/usr/fonts"
	for fontFile in file.children(fontsFolder)
		if fontFile[-4:] != ".bmf" then continue
		showProgress "Loading fonts (" + (fontFile - ".bmf") + ")"
		loadFont fontFile
	end for
end function
loadFonts
gfx.clear color.clear

