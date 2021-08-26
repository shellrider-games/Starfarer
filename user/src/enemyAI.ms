// This script controls the enemy ship in combat.  It's responsible
// for targeting the weapons, directing the enemy crew, and deciding
// when to flee or surrender.

import "miscUtil"
ensureImport "listUtil"
ensureImport "systems"

// internal data:
encounter = null
ship = null
nextTargetTime = 0
nextPowerTime = 0

// updateTargeting: internal function used to select where on the
// player ship we want to aim our weapons
updateTargeting = function()
	// for now, we'll just pick a new random target every now and then
	if time < nextTargetTime then return
	outer.nextTargetTime = time + 3 + rnd*3
	for i in range(3)
		col = playerShip.columnRange.any
		row = playerShip.rowRange.any
		system = playerShip.systemAt(col, row)
		if system != null then
			playerShip.targetSpots = [ [col,row] ]
			break
		end if
	end for
end function

// updatePower: adjust power allocations to best keep fighting
updatePower = function()
	if time < nextPowerTime then return
	outer.nextPowerTime = time + 1 + 0.5 * rnd
	
	// for now: just power down everything except reactor, O2, and weapons
	for sys in ship.systems
		if sys isa systems.Reactor or sys isa systems.O2 or sys isa systems.Weapons then
			sys.setPoint = sys.maxPower
		else
			sys.setPoint = 0
		end if
	end for
	
	ship.distributePower
end function

// update: main function invoked from CombatEncounter on each frame.
update = function(encounter, dt)
	outer.encounter = encounter
	outer.ship = encounter.ship
	updateTargeting
	updatePower
end function
