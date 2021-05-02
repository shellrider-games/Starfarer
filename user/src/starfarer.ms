// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
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

	// And render that thing!
	self.renderer = new shipDisplay.Renderer
	self.renderer.renderShip playerShip
	globals.renderer = self.renderer
	
	//give us a character
	minion = new character.Character
	minion.setPosition self.renderer.mapToScreenPosition([2,2])
	globals.playerShip.minions.push minion
	disp.shipSprites.sprites.push minion
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
	for minion in globals.playerShip.minions
		minionCell = self.renderer.screenToMapPosition(minion.getPosition)
		if mapPos.col == minionCell.col and mapPos.row == minionCell.row then
			if key.pressed("left shift") then
				self.selectedMinion.push minion
			else
				self.selectedMinion = [minion]
			end if
		else
			if not key.pressed("left shift") then
				self.selectedMinion = []
			end if
		end if
	end for
end function

Starfarer.handleSecondaryClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	if playerShip.walkable([mapPos.col,mapPos.row]) then
		for minion in self.selectedMinion
			minion.path = pathfinding.findPath(playerShip, self.renderer.screenToMapPosition(minion.getPosition), mapPos)
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