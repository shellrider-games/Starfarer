// This file defines the base class for any encounter.  The base class
// provides common utility functions that most encounters will need, like
// drawing a dialog describing what's happening, giving the user response
// choices, etc.

import "miscUtil"
ensureImport "uiWidgets"
ensureImport "randomNames"
ensureImport "enemyAI"
ensureImport "dialogs"

Encounter = {}
Encounter.ship = null  // ShipModel we have encountered, if any

// Consider presenting this encounter.  Subclasses will usually want to
// override this to apply a different probability, or to present only when
// certain game conditions are met.  Return null if you don't want to
// present; otherwise, return self.consideration (a little map that
// wraps up this encounter with other data that may be needed).
Encounter.consider = function(station, arriving)
	if rnd < 0.2 then return null
	return self.consideration(station, arriving)
end function

// This function creates the little map that returns this encounter for
// consideration on a particular journey.  Subclasses will not usually
// need to override this.
Encounter.consideration = function(station, arriving, priority=1, distance=null)
	data = {}
	data.encounter = self
	data.priority = priority
	if distance == null then distance = 0.2 + 0.6 * rnd
	data.distance = distance
	data.station = station
	data.arriving = arriving
	return data
end function

// This method is called when the encounter should be presented.
// The data given is the same object returned from consider().
// Transit-encounter subclasses will usually override this.
Encounter.present = function(data)

end function

// Use this method to add any NPCs related to this encounter to
// the given station.  Subclasses will often override this.
Encounter.addNPCsToCantina = function(station)

end function

// This method is called when the player clicks on an NPC in the cantina.
// NPC-encounter subclasses will usually override this.
Encounter.presentNPC = function(npc)

end function

// Helper method that subclasses can using in present():
// Show a dialog box with a short paragraph of text, and zero or more
// options (not yet supported).
//
// Parameters:
//	dataOrStation: data object passed from consider() to present(),
//			OR a station object in the case of a cantina encounter
//	text: main descriptive text to show
//	choices: optional set of options the player can choose
//  dialogOpts: DialogOptions for the display
// Returns: index of the option chosen, or null if none
Encounter.showDialog = function(dataOrStation, text, choices=null, dialogOpts=null)
	if dataOrStation isa stationModel.Station then
		whereText = dataOrStation.name + " Cantina"
	else if dataOrStation != null then
		whereText = round(dataOrStation.distance * 100000) + 
		   " km from " + dataOrStation.station.name
	else
		whereText = ""
	end if
	
	return dialogs.showGeneric(whereText, text, choices, dialogOpts)
end function

CombatEncounter = new Encounter
CombatEncounter.ship = null
CombatEncounter.renderer = null

CombatEncounter.updateCombat = function(dt = 0.1)
	enemyAI.update self, dt
end function

CombatEncounter.destroyShip = function
	self.showDialog null, "The enemy ship has been destroyed."
	if self.renderer != null then
		self.renderer.stop
		self.renderer = null
	end if
	playerShip.inCombat = false
end function

// The player is trying to flee.  Return true if successful,
// or false to cancel and keep them in combat.
CombatEncounter.handleFlee = function
	if self.renderer then self.renderer.stop
	self.renderer = null
	return true
end function
