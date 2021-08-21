// This script controls the enemy ship in combat.  It's responsible
// for targeting the weapons, directing the enemy crew, and deciding
// when to flee or surrender.

import "miscUtil"
ensureImport "listUtil"

// internal data:
encounter = null
ship = null
nextTargetTime = 0

// updateTargeting: internal function used to select where on the
// player ship we want to aim our weapons
updateTargeting = function()
	// for now, we'll just pick a new random target every now and then
	if time < nextTargetTime then return
	outer.nextTargetTime = time + 3 + rnd*3
	col = playerShip.columnRange.any
	row = playerShip.rowRange.any
	playerShip.targetSpots = [ [col,row] ]
	print "Enemy ship is now targeting " + col + "," + row
end function

// update: main function invoked from CombatEncounter on each frame.
update = function(encounter, dt)
	outer.encounter = encounter
	outer.ship = encounter.ship
	updateTargeting
end function
