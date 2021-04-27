// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
import "qa"
import "spriteControllers"

Door = new spriteControllers.Animated
Door.tint = color.blue

addSprite = function(image, x, y, baseClass)
	if baseClass == null then baseClass = Sprite
	if image isa string then image = file.loadImage(image)
	qa.assert image != null, "invalid image in shipDisplay.addSprite"
	sp = {}
	sp.__isa = baseClass
	sp.image = image
	sp.x = x
	sp.y = y
	disp.shipSprites.sprites.push sp
	return sp
end function

init = function()
	// clear the sprite display, and load the ship background
	disp.shipSprites.clear
	outer.ship = addSprite("/usr/ships/falcon/image.png", 200, 320)	
	
	// prepare the Door sprite subclass
	doorSheet = file.loadImage("/usr/pics/doors.png")
	frames = []
	for i in range(0,3)
		frames.push doorSheet.getImage(i*4, 0, 4, doorSheet.height)
	end for
	Door.openAnim = spriteControllers.newAnimation(frames)
	Door.openAnim.loop = false
	frames = [] + frames
	frames.reverse
	Door.closeAnim = spriteControllers.newAnimation(frames)
	Door.closeAnim.loop = false
	Door.play Door.closeAnim
	Door.update
	
	// instantiate a Door, just for testing
	d = new Door
	d.x = 260; d.y = 316
	disp.shipSprites.sprites.push d
	globals.door = d // for testing!
	
	// ToD:
	// We need some sort of data file (perhaps in GRFON format?) that defines
	// where things are in the map: walkable squares, doors, etc.  Then we
	// can instantiate a door for each place there should be one, and maybe
	// plop down a few crates or equipment panels after that.
	//
	// Note that even though it's just a giant image, our maps are very much
	// based on a (20-pixel) grid.  So all map coordinates should be given
	// in grid cells, not pixels.
end function

// demo: test/demonstrate this module on its own.
demo = function()
	for i in range(10)
		door.update
		wait 0.2
	end for
end function

init

if locals == globals then demo

