// This module adds the Door class, which represents a door on a ship.
// It is both model and view: that is, it contains the data which is part
// of a shipModel, but it's also a Sprite that can be loaded by shipDisplay.

import "miscUtil"
ensureImport "spriteControllers"
ensureImport "sounds"
ensureImport "listUtil"
ensureImport "pics"

// Door: a wall that can open and close.
Door = new spriteControllers.Animated
Door.name = "door"
Door.isOpen = false		// closed by default...
Door.canOpen = true		// but can be opened!
Door.tint = color.aqua
Door.curUsers = null	// list of Characters currently holding the door open
Door.power = 1			// power level (0-3)

Door.make = function()
	noob = new Door
	noob.curUsers = []
	
	// clone the animations, so they don't share state with the base class
	noob.openAnim = Door.openAnim.clone
	noob.closeAnim = Door.closeAnim.clone

	noob.close false
	noob.update 1

	return noob
end function

Door.open = function(withSound=true)
	self.play self.openAnim
	self.isOpen = true
	if withSound then sounds.doorOpen.playAt self.x
end function

Door.close = function(withSound=true)
	self.play self.closeAnim
	self.isOpen = false
	if withSound then sounds.doorClose.playAt self.x
end function

Door.toggle = function(withSound=true)
	if self.isOpen then self.close else self.open
end function

Door.openForUser = function(user)
	self.curUsers.push user
	if not self.isOpen then self.open
end function

Door.userDone = function(user)
	self.curUsers.remove user
	// auto-close after use, if door system has power
	if not self.curUsers and self.power > 0 then
		if self.isOpen then self.close
	end if
end function

init = function()
	// prepare the Door sprite subclass
	doorSheet = pics.get("doors")
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
init

// Door is an important enough class to push itself into the global namespace.
globals.Door = Door
