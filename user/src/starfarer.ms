// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
import "listUtil"
import "constants"
import "setup"
import "shipModel"
import "shipDisplay"
import "character"
import "pathfinding"

Starfarer = {}

Starfarer.init = function()
	// We'll directly load the freighter ship type for now:
	cd "../ships/freighter"
	import "shipData"
	globals.playerShip = shipData.ship
	cd "/usr/src"

	// give us a character
	minion = new character.Character
	minion.setMapPos [2, 2]
	minion.boardShip playerShip

	// And render that thing!
	self.renderer = new shipDisplay.Renderer
	self.renderer.renderShip playerShip
	globals.renderer = self.renderer
	


	self.mouseWasDownPrimary = false
	self.mouseWasDownSecondary = false
end function

// cleanup before exit.
Starfarer.cleanup = function()
	clear
	key.clear
end function

Starfarer.selectedMinion = []

// Handle a mouse click at the given position
Starfarer.handlePrimaryClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	
	// If we click a minion, toggle its selection status.
	m = playerShip.minionAt(mapPos)
	if m != null then
		if self.selectedMinion.contains(m) then
			self.selectedMinion.removeVal m
		else
			// with left-shift, add to selection; otherwise replace selection
			if key.pressed("left shift") then
				self.selectedMinion.push m
			else
				self.selectedMinion = [m]
			end if
		end if
		return
	end if
	
	// If we click anywhere else, and don't have a selected minion, ignore it.
	if not self.selectedMinion then return
	m = self.selectedMinion[0]
	
	// If we click an Item, have the selected minion pick it up.
	cell = playerShip.getCell(mapPos)
	if cell == null then return
	item = cell.contents
	if item != null then
		m.pickUp item
		return
	end if
	
	// If we click anywhere else, and we're carrying something,
	// then drop it there.  Otherwise, just walk to that spot.
	if m.carrying then
		m.dropItem mapPos
	else
		for m in self.selectedMinion
			m.path = pathfinding.findPath(playerShip, m, mapPos)
		end for
	end if
	
end function

Starfarer.handleSecondaryClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	if playerShip.walkable([mapPos.col,mapPos.row]) then
		for minion in self.selectedMinion
			minion.path = pathfinding.findPath(playerShip, minion, mapPos)
		end for	
	end if
end function

// Process all available input
Starfarer.processInput = function()
	mouseIsDownPrimary = mouse.button(0)
	mouseIsDownSecondary = mouse.button(1)
	if mouseIsDownPrimary and not self.mouseWasDownPrimary then
		self.handlePrimaryClick mouse
	end if
	if mouseIsDownSecondary and not self.mouseWasDownSecondary then
		self.handleSecondaryClick mouse
	end if
	self.mouseWasDownPrimary = mouseIsDownPrimary
	self.mouseWasDownSecondary = mouseIsDownSecondary
	disp.background.scrollX = gfx.width - (mouse.x*.025)
	disp.background.scrollY = gfx.height - (mouse.y*.025)
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
		playerShip.update dt
		if key.available then
			if key.get == "1" then d.close else d.open
		end if
		yield
	end while
end function

game = new Starfarer
game.init
game.start