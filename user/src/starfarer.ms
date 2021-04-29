// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
import "constants"
import "setup"
import "shipModel"
import "shipDisplay"


Starfarer = {}

Starfarer.init = function()
	// We'll directly load the freighter ship type for now:
	cd "../ships/freighter"
	import "shipData"
	globals.playerShip = shipData.ship
	cd "/usr/src"
	
	// And render that thing!
	self.renderer = new shipDisplay.Renderer
	self.renderer.renderShip playerShip
	
	self.mouseWasDown = false
end function

// cleanup before exit.
Starfarer.cleanup = function()
	clear
	key.clear
end function

// Handle a mouse click at the given position
Starfarer.handleClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	text.clear
	print "You clicked " + mapPos
end function

// Process all available input
Starfarer.processInput = function()
	mouseIsDown = mouse.button
	if mouseIsDown and not self.mouseWasDown then
		self.handleClick mouse
	end if
	self.mouseWasDown = mouseIsDown
	disp.background.scrollX = gfx.width - (mouse.x*.05)
	disp.background.scrollY = gfx.height - (mouse.y*.05)
end function

// Start Game/Main loop
Starfarer.start = function()
	//Main Loop
	curTime = time
	while true
		lastTime = curTime
		curTime = time
		dt = curTime - lastTime
		
		self.processInput
		shipDisplay.update dt
		yield
	end while
end function

game = new Starfarer
game.init
game.start






