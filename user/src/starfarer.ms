// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
import "listUtil"
import "constants"
import "setup"
import "crewStatistics"
import "item"
import "shipModel"
import "stationModel"
import "shipDisplay"
import "character"
import "pathfinding"
import "uiWidgets"
import "stationUI"
import "starmap"
import "playerUI"

Starfarer = {}

Starfarer.STATE_AT_STATION = "AtStation"
Starfarer.STATE_NAVMAP = "NavMap"

Starfarer.STATE_NONE = "None"  // (initial state before set up)
Starfarer.state = Starfarer.STATE_NONE

Starfarer.stations = []  // all stations in the galaxy

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

	// generate a random galaxy full of stations
	self.stations = []
	for i in range(1, 10)
		self.stations.push stationModel.randomStation
	end for

	// And render that thing!
	self.renderer = new shipDisplay.Renderer
	self.renderer.renderShip playerShip
	globals.renderer = self.renderer
	
	self.mouseWasDownPrimary = false
	self.mouseWasDownSecondary = false
	
	self.enterState self.STATE_AT_STATION
end function

// cleanup before exit.
Starfarer.cleanup = function()
	clear
	key.clear
end function

Starfarer.enterState = function(newState)
	if newState == self.state then return	// no change
	self.exitState newState
	
	if newState == self.STATE_AT_STATION then
		self.station = self.stations.any
		stationUI.show self.station
		stationUI.navBtn.action = function()
			game.enterState Starfarer.STATE_NAVMAP
		end function
		crewStatistics.currentStation = self.station
		playerUI.show
		
	else if newState == self.STATE_NAVMAP then
		starmap.draw
		starmap.jumpBtn.action = function()
			game.enterState Starfarer.STATE_AT_STATION
		end function
		
	end if
	
	self.state = newState
end function

Starfarer.exitState = function(toNextState)
	if self.state == self.STATE_AT_STATION then
		stationUI.hide
		
	else if self.state == self.STATE_NAVMAP then
		starmap.hide
	end if
end function

Starfarer.selectedMinion = []

// Handle a mouse click at the given position
Starfarer.handlePrimaryClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	
	// If we click a minion, toggle its selection status.
	minion = playerShip.minionAt(mapPos.col, mapPos.row)
	if minion != null then
		if self.selectedMinion.contains(minion) then
			self.selectedMinion.removeVal minion
		else
			// with left-shift, add to selection; otherwise replace selection
			if key.pressed("left shift") then
				self.selectedMinion.push minion
			else
				self.selectedMinion = [minion]
			end if
		end if
		return
	end if
	
	// If we click anywhere else, and don't have a selected minion, ignore it.
	if not self.selectedMinion then return
	minion = self.selectedMinion[0]
	
	// If we click an Item, have the selected minion pick it up.
	cell = playerShip.getCell(mapPos.col,mapPos.row)
	if cell == null then return
	item = cell.contents
	if item != null then
		minion.pickUp item
		return
	end if
	
	// If we click anywhere else, and we're carrying something,
	// then drop it there.  Otherwise, just walk to that spot.
	if minion.carrying then
		minion.dropItem mapPos
	else
		for minion in self.selectedMinion
			minion.path = pathfinding.findPath(playerShip, minion, mapPos)
		end for
	end if
	
end function

Starfarer.handleSecondaryClick = function(pos)
	// Right-click not currently used.
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
	disp.background.scrollX = gfx.width - (mouse.x*.01)
	disp.background.scrollY = gfx.height - (mouse.y*.01)
end function

// Start Game/Main loop
Starfarer.run = function()
	//Main Loop
	currentTime = time
	while true
		lastTime = currentTime
		currentTime = time
		deltaTime = currentTime - lastTime
		self.processInput
		self.renderer.update deltaTime
		shipDisplay.update deltaTime
		playerShip.update deltaTime
		uiWidgets.update deltaTime
		playerUI.update deltaTime
		if self.state == self.STATE_NAVMAP then
			starmap.update deltaTime
		end if
		yield
	end while
end function

game = new Starfarer
game.init
game.run
