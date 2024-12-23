// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
import "listUtil"
import "stringUtil"
import "miscUtil"; for f in ["min", "max"]; globals[f] = miscUtil[f]; end for
ensureImport "constants"
ensureImport "setup"
ensureImport "spriteUtil"
ensureImport "item"
ensureImport "systems"
ensureImport "shipModel"
ensureImport "stationModel"
ensureImport "shipDisplay"
ensureImport "character"
ensureImport "pathfinding"
ensureImport "uiWidgets"
ensureImport "stationUI"
ensureImport "starmap"
ensureImport "playerUI"
ensureImport "minionUI"
ensureImport "effects"
ensureImport "qa"
ensureImport "encounters"

Starfarer = {}

Starfarer.STATE_NONE = "None"  // (initial state before set up)
Starfarer.STATE_AT_STATION = "AtStation"
Starfarer.STATE_NAVMAP = "NavMap"
Starfarer.STATE_TRAVEL = "Travel"
Starfarer.STATE_COMBAT = "Combat"
Starfarer.STATE_COMBAT_OVER = "CombatOver"
Starfarer.state = Starfarer.STATE_NONE
Starfarer.timeInState = 0
Starfarer.stations = []  // all stations in the galaxy
Starfarer.combatEncounter = null	// current Encounter we're fighting in

Starfarer.money = 1000
Starfarer.fuel = 10
Starfarer.maxFuel = 12

Starfarer.init = function()
	globals.playerShip = shipModel.newShipOfDesign("Wren")
	playerShip.isPlayer = true
	playerShip.distributePower

	// give us a character
	minion = new character.Character
	minion.health = 9
	minion.setMapPos [2, 2]
	minion.boardShip playerShip
	globals.arthur = minion // for debugging!

	// generate a random galaxy full of stations
	self.stations = stationModel.manyRandomStations(30)
	self.station = self.stations.any

	// And render that thing!
	self.renderer = new shipDisplay.Renderer
	self.renderer.renderShip playerShip
	
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
		playerShip.healCrew
		playerUI.show
		minionUI.show playerShip.minions
		stationUI.tabs = []
		stationUI.activeButtons = []
		self.station.fillCantina
		stationUI.show self.station
		stationUI.navBtn.action = function()
			self.enterState Starfarer.STATE_NAVMAP
		end function
		
	else if newState == self.STATE_NAVMAP then
		if self.fuel > 0 then jumpLimit = 200 else jumpLimit = 0
		starmap.draw self.stations, self.station, jumpLimit
		starmap.backBtn.action = function()
			self.enterState Starfarer.STATE_AT_STATION
		end function
		starmap.jumpCallback = function(newStation)
			if newStation == self.station then
				self.enterState Starfarer.STATE_AT_STATION
			else
				self.nextStation = newStation
				self.enterState Starfarer.STATE_TRAVEL
			end if
		end function
	
	else if newState == self.STATE_COMBAT then
		playerShip.inCombat = true
		if self.combatEncounter and self.combatEncounter.ship then
			self.combatEncounter.ship.inCombat = true
		end if
		minionUI.show playerShip.minions
		playerUI.showCombat
		
	else if newState == self.STATE_COMBAT_OVER then
		playerUI.showContinueJump
		
	else if newState == self.STATE_TRAVEL then
		playerUI.show
		minionUI.show
		// Note that if we're entering travel from combat, then this
		// is *resuming* a trip, not starting a new one.
		if self.state != self.STATE_COMBAT and self.state != self.STATE_COMBAT_OVER then
			self.travelProgress = 0
			encounters.planEncounters self.station, self.nextStation
		end if
	
	end if
	self.state = newState
	self.timeInState = 0
end function

Starfarer.exitState = function(toNextState)
	if self.state == self.STATE_AT_STATION then
		stationUI.hide
		
	else if self.state == self.STATE_NAVMAP then
		starmap.hide
	
	else if self.state == self.STATE_COMBAT then
		playerUI.hideCombat
		self.combatEncounter = null
		for sys in playerShip.systems
			if sys isa systems.Weapons then sys.curCharge = 0
		end for
		
	else if self.state == self.STATE_COMBAT_OVER then
		playerUI.hideCombat
		
	else if self.state == self.STATE_TRAVEL then
		playerUI.hideTravel
	
	end if
end function

Starfarer.updateTravel = function(dt)
	// update progress: 0-1 departing old station, and 1-2 arriving new station.
	self.travelProgress = self.travelProgress + dt/2
	if self.travelProgress > 2 then
		// arrived
		self.nextStation = null
		self.enterState self.STATE_AT_STATION
	else if self.travelProgress > 1 then
		// approaching destination
		if self.station != self.nextStation then
			self.station = self.nextStation
			self.fuel = max(self.fuel - 1, 0)
		end if
		playerUI.showTravel self.nextStation, 2-self.travelProgress, true
	else
		// leaving old station
		playerUI.showTravel self.station, self.travelProgress, false
		if self.travelProgress > 0.83 then
			effects.Warp.speed = 3
			effects.Warp.run
		end if
	end if
	effects.Warp.update dt
	encounters.update dt
end function

Starfarer.beginCombat = function(encounter)
	self.combatEncounter = encounter
	encounter.ship.distributePower
	self.enterState Starfarer.STATE_COMBAT
end function

Starfarer.fleeCombat = function
	if self.combatEncounter.handleFlee then
		self.enterState Starfarer.STATE_TRAVEL
	end if
end function

Starfarer.continueJump = function()
	self.enterState Starfarer.STATE_TRAVEL
end function

Starfarer.destroyShip = function(ship)
	text.clear
	if ship.isPlayer then
		shipDisplay.update
		// ToDo: something better than this!
		import "textUtil"
		dlog = textUtil.Dialog.make("Game Over", "Your ship has been destroyed.")
		dlog.show
		text.row = 0
		exit
	else if ship == self.combatEncounter.ship then
		// ToDo: nice exploding-ship effect on the enemy ship.
		self.combatEncounter.destroyShip
		self.enterState self.STATE_COMBAT_OVER
	end if		
end function

Starfarer.selectedMinion = []

// Handle a mouse click on the player's ship at the given screen position
Starfarer.handlePlayerShipClick = function(pos)
	mapPos = self.renderer.screenToMapPosition(pos)
	
	if playerUI.selectedControl isa systems.DoorPowerControl then
		// while door control is selected: toggle doors
		if playerUI.selectedControl.handleShipClick(playerShip, pos, mapPos) then
			return
		end if
	end if
	
	// If we click a minion, toggle its selection status.
	minion = playerShip.minionAt(mapPos.col, mapPos.row)
	if minion != null then
		if self.selectedMinion.contains(minion) then
			self.selectedMinion.removeVal minion
		else
			if key.pressed("left shift") then
				self.selectedMinion.push minion
			else
				self.selectedMinion = [minion]
			end if
		end if
		minionUI.updateSelection
		self.renderer.updateSelectionReticles
		return
	end if
	
	// If we click anywhere else, and don't have a selected minion, ignore it.
	if not self.selectedMinion then
		// ToDo: should we auto-select the closest idle minion?
		return
	end if
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
			minion.goTo mapPos
		end for
	end if
end function

// Handle a mouse click on the enemy ship at the given screen position
Starfarer.handleEnemyShipClick = function(pos)
	enemy = self.combatEncounter.ship
	mapPos = enemy.renderer.screenToMapPosition(pos)
	if mapPos == null then return
	
	// For now, the only thing a click on an enemy ship can do
	// is change the target for weapon 0.
	if not enemy.targetSpots then
		enemy.targetSpots = [mapPos]
	else
		enemy.targetSpots[0] = mapPos
	end if
	enemy.renderer.renderTargets
end function

// Handle a mouse click at the given screen position
Starfarer.handlePrimaryClick = function(pos)
	if self.combatEncounter == null or self.combatEncounter.ship == null or pos.x < 480 then
		self.handlePlayerShipClick pos
	else
		self.handleEnemyShipClick pos
	end if	
end function

Starfarer.handleSecondaryClick = function(pos)
	// Let's try not to use right-click for anything but debugging.
	// If we can help it.  I want to run on mobile someday!
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
		if deltaTime > 0.1 then deltaTime = 0.1 // (cap, in case of blocking dialog)
		self.timeInState = self.timeInState + deltaTime
		
		self.processInput
		shipDisplay.update deltaTime
		playerShip.update deltaTime
		if self.combatEncounter and self.combatEncounter.ship then
			self.combatEncounter.ship.update deltaTime
		end if
		uiWidgets.update deltaTime
		playerUI.update deltaTime
		minionUI.update deltaTime

		if self.state == self.STATE_NAVMAP then
			starmap.update deltaTime
		else if self.state == self.STATE_TRAVEL then
			self.updateTravel deltaTime
		end if
		if self.state == self.STATE_COMBAT then
			self.combatEncounter.updateCombat deltaTime
		end if
		yield
	end while
end function

game = new Starfarer
game.init
game.run
