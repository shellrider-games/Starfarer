// This module defines the System base class and various subclasses,
// which represent things that can be installed on a ship.  Systems
// generally consume power and provide some benefit to the ship/crew.

// Note that systems with a width or height of 0 are not visible on
// the ship map, but may still be part of the ship.  These invisible
// systems are inherent to the ship itself.

import "mathUtil"
import "miscUtil"
ensureImport "uiWidgets"
ensureImport "sounds"
ensureImport "playerUI"

//----------------------------------------------------------------------
// System base class
//----------------------------------------------------------------------

System = {}
System._name = "System"
System.name = "GENERIC"
System.col = 0
System.row = 0
System.width = 1
System.height = 1
System.image = null
System.maxPower = 3
System.curPower = 3
System.setPoint = 3	
System.repairLevel = 3	// how many bars are fully repaired
System.disabled = 0		// how many bars (top-down) are disabled
System.powerControlClass = uiWidgets.PowerControl
System.powerControl = null
System.needsDisplay = false	// set to true to trigger a redraw of the system display
System.needsRedistribute = false	// set to true to trigger a redistribution of power
System.canUpgrade = false	// return true if this system can be upgraded

System.make = function(col, row, width=1, height=1, name="GENERIC")
	noob = new System
	noob.col = col; noob.row = row
	noob.width = width; noob.height = height
	noob.name = name
	return noob
end function

System.makeInvisible = function(name="invisible", maxPower=3)
	noob = new System
	noob.width = 0; noob.height = 0
	noob.name = name
	noob.maxPower = maxPower
	noob.repairLevel = maxPower
	noob.curPower = maxPower
	noob.setPoint = maxPower
	noob.icon = file.loadImage("/usr/pics/systemIcons/" + name + ".png")
	return noob
end function

// A minion is using (working on/at) this system.
System.use = function(character, dt = 0.1)
	// Subclasses should usually override this.
	// But at minimum, when a character uses a system, they repair it.
	// (So subclasses that DO override this should call super.use.)
	if self.repairLevel < self.maxPower then
		prevLevel = self.repairLevel
		self.repairLevel = min(self.repairLevel + dt/3, self.maxPower)
		self.needsDisplay = true
		self.needsRedistribute = floor(self.repairLevel) != floor(prevLevel)
	end if
end function

System.maxPossiblePower = function()
	// Compute the power that should be supplied to this system,
	// if we have plenty of power available.
	result = min(self.setPoint, floor(self.repairLevel))
	result = min(result, self.maxPower - self.disabled)
	return result
end function

// Update method called by the ship whenever it updates.
// Subclasses may update this to charge up or otherwise
// do whatever they need to do on each frame.
System.update = function(ship, dt = 0.1)
end function

System.containsColRow = function(col, row)
	return col >= self.col and col < self.col + self.width and
		   row >= self.row and row < self.row + self.height
end function

System.takeDamage = function(damagePoints)
	if self.repairLevel <= 0 then return
	self.repairLevel = floor(self.repairLevel - damagePoints)
	if self.repairLevel < 0 then self.repairLevel = 0
	self.needsDisplay = true
	//print self.name + " takes " + damagePoints + " damage; repair level now " + self.repairLevel
end function

System.upgradeCost = function()
	// Subclasses can override, but otherwise, we'll just base
	// the cost to upgrade on how high the power level already is.
	return 250 + 100 * self.maxPower
end function

System.upgrade = function()
	// For most systems, an upgrade just increases maxPower.
	// Subclasses may override this as needed.
	self.maxPower = self.maxPower + 1
	self.repairLevel = self.repairLevel + 1
	self.needsDisplay = true
end function

//----------------------------------------------------------------------
// Med Bay: heals crew standing over the system (while powered).
//----------------------------------------------------------------------
MedBay = new System
MedBay._name = "MedBay"
MedBay.name = "Med Bay"
MedBay.maxPower = 1
MedBay.width = 2
MedBay.height = 2
MedBay.image = file.loadImage("/usr/pics/systems/medbay.png")
MedBay.icon = file.loadImage("/usr/pics/systemIcons/medbay.png")
MedBay.canUpgrade = function(); return self.maxPower < 3; end function

MedBay.make = function(col, row)
	noob = new MedBay
	noob.col = col; noob.row = row
	return noob
end function

MedBay.use = function(character, dt = 0.1)
	// regenerates the health of the user at a rate that
	// depends on our current power
	super.use character, dt
	regenPerSec = self.curPower
	character.health = miscUtil.min(character.health + regenPerSec * dt,
	   character.maxHealth)
end function

//----------------------------------------------------------------------
// O2: generates oxygen (life support) while powered.
//----------------------------------------------------------------------
O2 = new System
O2._name = "O2"
O2.name = "O2"
O2.maxPower = 1
O2.width = 2
O2.height = 1
O2.image = file.loadImage("/usr/pics/systems/O2.png")
O2.icon = file.loadImage("/usr/pics/systemIcons/O2.png")
O2.canUpgrade = function(); return self.maxPower < 3; end function

O2.make = function(col, row)
	noob = new O2
	noob.col = col; noob.row = row
	return noob
end function

// Return how much air (per second per cell) this system is currently generating.
O2.airPerSec = function()
	return self.curPower * 2
end function
	

//----------------------------------------------------------------------
// Sensors: allows the player to see what's happening, by power level:
//		1 bar: see in your own ship, even where there is no crew.
//		2 bars: see inside opponent ship
//		3 bars: also see opponent's weapon charge status
//----------------------------------------------------------------------
Sensors = new System
Sensors._name = "Sensors"
Sensors.name = "Sensors"
Sensors.width = 2
Sensors.height = 1
Sensors.image = file.loadImage("/usr/pics/systems/sensors.png")
Sensors.icon = file.loadImage("/usr/pics/systemIcons/sensors.png")
Sensors.canUpgrade = function(); return self.maxPower < 3; end function

Sensors.make = function(col, row)
	noob = new Sensors
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Controls: allows the player to see what's happening, by power level:
//		1 bar: see in your own ship, even where there is no crew.
//		2 bars: see inside opponent ship
//		3 bars: also see opponent's weapon charge status
//----------------------------------------------------------------------
Controls = new System
Controls._name = "Controls"
Controls.name = "Controls"
Controls.width = 2
Controls.height = 1
Controls.maxPower = 2
Controls.image = file.loadImage("/usr/pics/systems/controls.png")
Controls.icon = file.loadImage("/usr/pics/systemIcons/controls.png")

Controls.make = function(col, row)
	noob = new Controls
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Engines: make the ship go.
//----------------------------------------------------------------------
Engines = new System
Engines._name = "Engines"
Engines.name = "Engines"
Engines.width = 2
Engines.height = 2
Engines.image = file.loadImage("/usr/pics/systems/engines.png")
Engines.icon = file.loadImage("/usr/pics/systemIcons/engines.png")
Engines.canUpgrade = function(); return self.maxPower < 3; end function

Engines.make = function(col, row)
	noob = new Engines
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Reactor: provides power for the ship.
//----------------------------------------------------------------------
Reactor = new System
Reactor._name = "Reactor"
Reactor.name = "Reactor"
Reactor.maxPower = 8
Reactor.width = 2
Reactor.height = 2
Reactor.image = file.loadImage("/usr/pics/systems/reactor.png")
Reactor.icon = file.loadImage("/usr/pics/systemIcons/reactor.png")
Reactor.canUpgrade = true

Reactor.make = function(col, row, maxPower=null)
	noob = new Reactor
	noob.col = col; noob.row = row
	if maxPower then noob.maxPower = maxPower
	return noob
end function

//----------------------------------------------------------------------
// Doors: make doors auto-close, and keep intruders from opening them.
// (This system appears in the ship UI, but not in the ship layout.)
//----------------------------------------------------------------------
Doors = new System
Doors._name = "Doors"
Doors.name = "Doors"
Doors.width = 0
Doors.height = 0
Doors.maxPower = 1
Doors.setPoint = 1
Doors.icon = file.loadImage("/usr/pics/systemIcons/doors.png")
Doors.canUpgrade = function(); return self.maxPower < 3; end function

Doors.make = function()
	return new Doors
end function


DoorPowerControl = new uiWidgets.PowerControl
DoorPowerControl.widgets = []

DoorPowerControl.onIconTap = function()
	if playerUI.selectControl(self) then
		// set up our selected UI
		button = new uiWidgets.Button
		button.init 700, 0, 64, 56, "OPEN" + char(13) +"ALL"
		button.action = function()
			for door in playerShip.allDoors
				if not door.isOpen and door.power > 0 then door.open
			end for
		end function
		button.start
		self.widgets.push button
		
		button = new uiWidgets.Button
		button.init 780, 0, 64, 56, "CLOSE" + char(13) + "ALL"
		button.action = function()
			for door in playerShip.allDoors
				if door.isOpen and door.power > 0 then door.close
			end for
		end function
		button.start
		self.widgets.push button
		
		note = new uiWidgets.Label
		note.init 550, 0, 120, 56, "Click doors to open/close"
		note.font = fonts["ArialBlack14"]
		note.wrap
		note.alignment = uiWidgets.ALIGNCENTER
		note.color = color.silver
		note.start
		self.widgets.push note
	else
		playerUI.selectControl null
	end if
end function

// handleShipClick is called by Starfarer when the player clicks on
// the ship map, while the door power control is selected.  Return
// true if we have handled the click, false otherwise.
DoorPowerControl.handleShipClick = function(ship, screenPos, mapPos)
	// start by finding out which direction was clicked
	cellCenter = ship.renderer.mapToScreenPosition(mapPos)
	diffx = screenPos.x - cellCenter.x
	diffy = screenPos.y - cellCenter.y
	if abs(diffx) > abs(diffy) then
		if diffx < 0 then direction = WEST else direction = EAST
	else
		if diffy < 0 then direction = SOUTH else direction = NORTH
	end if
	// then, toggle the door there (if there is one, and it has power
	// or there is a minion right there)
	cell = ship.getCell(mapPos.col, mapPos.row)
	if cell == null then return false
	wallOrDoor = cell.walls[direction]
	if not (wallOrDoor isa Door) then return false
	nextcol = mapPos.col + constants.dx(direction)
	nextrow = mapPos.row + constants.dy(direction)
	if wallOrDoor.power > 0 or 
		  ship.minionAt(mapPos.col, mapPos.row) or
		  ship.minionAt(nextcol, nextrow) then
		wallOrDoor.toggle
	end if
	return true
end function

DoorPowerControl.close = function()
	for widget in self.widgets
		widget.stop
	end for
	self.widgets = []
end function

Doors.powerControlClass = DoorPowerControl

//----------------------------------------------------------------------
// Shields: provides energy shields that block normal weapons fire.
// NOTE: costs 2 power per layer of shields (max 6 power for 3 layers).
//----------------------------------------------------------------------
Shields = new System
Shields._name = "Shields"
Shields.name = "Shields"
Shields.maxPower = 2
Shields.width = 2
Shields.height = 2
Shields.image = file.loadImage("/usr/pics/systems/shields.png")
Shields.icon = file.loadImage("/usr/pics/systemIcons/shields.png")
Shields.curLayers = 0	// current number of active shield layers (plus fractional charge)
Shields.canUpgrade = function(); return self.maxPower < 6; end function

Shields.make = function(col, row)
	noob = new Shields
	noob.col = col; noob.row = row
	return noob
end function

Shields.update = function(ship, dt = 0.1)
	maxLayers = floor(self.curPower / 2)
	self.curLayers = self.curLayers + dt / 3
	if self.curLayers > maxLayers then self.curLayers = maxLayers
end function


//----------------------------------------------------------------------
// Weapons: provides power and control for all installed weapons.
//----------------------------------------------------------------------
Weapons = new System
Weapons._name = "Weapons"
Weapons.name = "Weapons"
Weapons.powerControlClass = uiWidgets.ChargedPowerControl
Weapons.maxPower = 4
Weapons.width = 2
Weapons.height = 2
Weapons.image = file.loadImage("/usr/pics/systems/weapons.png")
Weapons.icon = file.loadImage("/usr/pics/systemIcons/weapons.png")
Weapons.curCharge = 0		// current amount of charge
Weapons.maxCharge = 30		// charge level at which we fire
Weapons.shots = []
Weapons.canUpgrade = function(); return self.maxPower < 8; end function

Weapons.make = function(col, row)
	noob = new Weapons
	noob.col = col; noob.row = row
	return noob
end function

Weapons.update = function(ship, dt = 0.1)
	for shot in self.shots
		if shot.expired == true then
			self.shots.removeVal shot
		else
			shot.update dt
		end if
	end for
	if not ship.inCombat then
		newCharge = 0
	else
		newCharge = min(self.curCharge + self.curPower * dt, self.maxCharge)
	end if
	if newCharge == self.curCharge then return
	self.curCharge = newCharge
	if self.curCharge >= self.maxCharge and ship.inCombat then
		self.fire ship		// for now: auto-fire!
	end if
	if self.powerControl != null then self.powerControl.redraw
end function

// Fire this weapon.  The parameter is the ship that
// contains this weapon system; it will need to find
// the target ship from the current encounter.
Weapons.fire = function(owningShip)
	targetShip = null
	if owningShip != playerShip then
		targetShip = playerShip
	else if game.combatEncounter then
		targetShip = game.combatEncounter.ship
	end if
	if not targetShip then
		print self.name + " (on " + owningShip.name + ") fires into space."
		return
	end if
	self.shots.push Shot.init(targetShip)
	qa.assert self.shots[-1] != null
	self.curCharge = 0
end function

Shot = new Sprite
Shot.image = file.loadImage("/usr/pics/blueShot.png")
Shot.target = null
Shot.travelTime = 2
Shot.timeTravelled = 0
Shot.hit = false
Shot.expired = false
Shot.startPos = {"x": 240, "y":420}
Shot.targetPos = {"x": 960-240, "y":320}
Shot.fireSound = sounds.laserFire
Shot.hitSound = sounds.laserHit
Shot.burstImage = file.loadImage("/sys/pics/Burst.png")

// Initialize a new shot.
//	target: the shipModel representing the ship we are firing at
//	travelTime: how long (in seconds) the shot should take to get there
Shot.init = function(target, travelTime = 2)
	noob = new Shot
	noob.target = target
	noob.travelTime = travelTime
	targetPos = target.targetSpots[0]
	qa.assert targetPos != null
	// dodge: apply a chance for the target to miss, a little or a lot,
	// based on the control system power
	controlSys = target.findSystemOfType(Controls)
	if controlSys != null and controlSys.curPower > 0 then
		targetPos[0] = targetPos[0] + round(mathUtil.randRange(-1, 1))
		targetPos[1] = targetPos[1] + round(mathUtil.randRange(-1, 1))
		if controlSys.curPower > 1 and rnd < 0.05 then
			targetPos[0] = targetPos[0] + 10 * round(mathUtil.randRange(-1, 1))
			targetPos[1] = targetPos[1] + 10 * round(mathUtil.randRange(-1, 1))
		end if
	end if
	noob.targetMapPos = targetPos

	noob.targetPos = target.renderer.mapToScreenPosition(noob.targetMapPos)
	if target == playerShip then
		noob.startPos = {"x": 960-240, "y":420}
	else
		noob.startPos = {"x": 240, "y":420}
	end if
	noob.x = noob.startPos.x
	noob.y = noob.startPos.y
	disp.shipSprites.sprites.push noob
	noob.fireSound.playAt noob.x
	return noob
end function

Shot.update = function(dt = 0.1)
	if self.expired then return
	self.timeTravelled = self.timeTravelled + dt
	if self.hit then
		t = self.timeTravelled - self.travelTime
		if t > 0.5 then
			self.expired = true
			disp.shipSprites.sprites.removeVal self
		else
			self.scale = 0.1 + t/3
		end if
		return
	end if
	halfTravelTime = self.travelTime / 2
	if self.timeTravelled < halfTravelTime then
		// move up, off the top of the screen
		t = self.timeTravelled / halfTravelTime
		self.x = self.startPos.x
		self.y = mathUtil.lerp(self.startPos.y, self.startPos.y + 500, t)
		self.rotation = 90
	else
		// move down from the top of the screen to the target
		t = (self.timeTravelled - halfTravelTime) / halfTravelTime
		self.x = self.targetPos.x
		self.y = mathUtil.lerp(self.targetPos.y + 500, self.targetPos.y, t)
		self.rotation = -90
	end if
		
	if self.timeTravelled >= self.travelTime then
		if not self.target.takeDamage(self, self.targetMapPos) then
			self.expired = true
			disp.shipSprites.sprites.removeVal self
			return
		end if
		self.hitSound.playAt self.x
		self.hit = true
		self.image = self.burstImage
		self.tint = color.yellow
		self.scale = 0.25
		if self.target.hp <= 0 then game.destroyShip self.target
	end if
end function