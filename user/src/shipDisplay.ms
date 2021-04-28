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

Door.make = function(x, y, addToDisplay=true)
	noob = new Door
	noob.x = x; noob.y = y
	
	// clone the animations, so they don't share state with the base class
	noob.openAnim = Door.openAnim.clone
	noob.closeAnim = Door.closeAnim.clone

	noob.close
	if addToDisplay then disp.shipSprites.sprites.push noob
	
	return noob
end function

Door.open = function()
	self.play self.openAnim
end function

Door.close = function()
	self.play self.closeAnim
end function

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
end function

// demo: test/demonstrate this module on its own.
demo = function()	
	// instantiate a Door
	d = Door.make(260, 316)

	for i in range(10)
		d.update
		wait 0.2
	end for
end function

init

if locals == globals then demo

