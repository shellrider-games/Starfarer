// This module defines the System base class and various subclasses,
// which represent things that can be installed on a ship.  Systems
// generally consume power and provide some benefit to the ship/crew.

// Note that systems with a width or height of 0 are not visible on
// the ship map, but may still be part of the ship.  These invisible
// systems are inherent to the ship itself.

import "miscUtil"
ensureImport "uiWidgets"

//----------------------------------------------------------------------
// System base class
//----------------------------------------------------------------------

System = {}
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
	// Subclasses should override this.
	// For debugging:
	// print character.name + " is using " + self.name + " for " + dt + " seconds."
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

//----------------------------------------------------------------------
// Med Bay: heals crew standing over the system (while powered).
//----------------------------------------------------------------------
MedBay = new System
MedBay.name = "medbay"
MedBay.width = 2
MedBay.height = 2
MedBay.image = file.loadImage("/usr/pics/systems/medbay.png")
MedBay.icon = file.loadImage("/usr/pics/systemIcons/medbay.png")

MedBay.make = function(col, row)
	noob = new MedBay
	noob.col = col; noob.row = row
	return noob
end function

MedBay.use = function(character, dt = 0.1)
	// regenerates the health of the user at a rate that
	// depends on our current power
	regenPerSec = self.curPower
	character.health = miscUtil.min(character.health + regenPerSec * dt,
	   character.maxHealth)
end function

//----------------------------------------------------------------------
// O2: generates oxygen (life support) while powered.
//----------------------------------------------------------------------
O2 = new System
O2.name = "O2"
O2.width = 2
O2.height = 1
O2.image = file.loadImage("/usr/pics/systems/O2.png")
O2.icon = file.loadImage("/usr/pics/systemIcons/O2.png")

O2.make = function(col, row)
	noob = new O2
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Sensors: allows the player to see what's happening, by power level:
//		1 bar: see in your own ship, even where there is no crew.
//		2 bars: see inside opponent ship
//		3 bars: also see opponent's weapon charge status
//----------------------------------------------------------------------
Sensors = new System
Sensors.name = "O2"
Sensors.width = 2
Sensors.height = 1
Sensors.image = file.loadImage("/usr/pics/systems/sensors.png")
Sensors.icon = file.loadImage("/usr/pics/systemIcons/sensors.png")

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
Engines.name = "Engines"
Engines.width = 2
Engines.height = 2
Engines.image = file.loadImage("/usr/pics/systems/engines.png")
Engines.icon = file.loadImage("/usr/pics/systemIcons/engines.png")

Engines.make = function(col, row)
	noob = new Engines
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Reactor: provides power for the ship.
//----------------------------------------------------------------------
Reactor = new System
Reactor.name = "Reactor"
Reactor.maxPower = 12
Reactor.width = 2
Reactor.height = 2
Reactor.image = file.loadImage("/usr/pics/systems/reactor.png")
Reactor.icon = file.loadImage("/usr/pics/systemIcons/reactor.png")

Reactor.make = function(col, row)
	noob = new Reactor
	noob.col = col; noob.row = row
	return noob
end function

//----------------------------------------------------------------------
// Weapons: provides power and control for all installed weapons.
//----------------------------------------------------------------------
Weapons = new System
Weapons.name = "Weapons"
Weapons.powerControlClass = uiWidgets.ChargedPowerControl
Weapons.maxPower = 6
Weapons.width = 2
Weapons.height = 2
Weapons.image = file.loadImage("/usr/pics/systems/weapons.png")
Weapons.icon = file.loadImage("/usr/pics/systemIcons/weapons.png")
Weapons.curCharge = 0		// current amount of charge
Weapons.maxCharge = 30		// charge level at which we fire
Weapons.shots = []

Weapons.make = function(col, row)
	noob = new Weapons
	noob.col = col; noob.row = row
	return noob
end function

Weapons.update = function(ship, dt = 0.1)
	for shot in self.shots
		if shot.expired == true then
			self.shots.removeVal shot
		end if
		shot.update dt
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
	self.shots.push(Shot.init(targetShip))
	self.curCharge = 0
end function

Shot = {}
Shot.target = null
Shot.traveltime = 2
Shot.timeTravelled = 0
Shot.expired = false

Shot.init = function(target, traveltime = 2)
	noob = new Shot
	noob.target = target
	noob.traveltime = traveltime
	return noob
end function

Shot.update = function(dt = 0.1)
	self.timeTravelled = self.timeTravelled + dt
	if self.timeTravelled >= self.traveltime and self.expired != true then
		self.target.hp = self.target.hp -1
		print "boom, swish, lazersound"
		self.expired = true
		if self.target.hp < 0 then game.destroyShip target
	end if
end function