// This module adds the Door class, which represents a door on a ship.
// It is both model and view: that is, it contains the data which is part
// of a shipModel, but it's also a Sprite that can be loaded by shipDisplay.

if not globals.hasIndex("spriteControllers") then import "spriteControllers"


// Door: a wall that can open and close.
Door = spriteControllers.Animated
Door.name = "door"
Door.isOpen = false		// closed by default...
Door.canOpen = true		// but can be opened!
Door.tint = color.aqua
Door.curUsers = null	// list of Characters currently holding the door open

Door.make = function()
	noob = new Door
	noob.curUsers = []
	
	// clone the animations, so they don't share state with the base class
	noob.openAnim = Door.openAnim.clone
	noob.closeAnim = Door.closeAnim.clone

	noob.close
	noob.update 1

	return noob
end function

Door.open = function()
	self.play self.openAnim
	self.isOpen = true
	//print "Opening door"
end function

Door.close = function()
	self.play self.closeAnim
	self.isOpen = false
	//print "Closing door"
end function

Door.openForUser = function(user)
	self.curUsers.push user
	if not self.isOpen then self.open
end function

Door.userDone = function(user)
	self.curUsers.remove user
	if self.isOpen then self.close
end function

init = function()
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
init

// Door is an important enough class to push itself into the global namespace.
globals.Door = Door
