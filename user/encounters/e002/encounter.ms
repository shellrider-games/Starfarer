// Our second test encounter.
// Gain a crewman!  And lose him if you ever go back.

if not globals.hasIndex("Encounter") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
	import "randomNames"
end if


encounter = new encounterBase.Encounter
encounter.newChar = null	// new crewman you find
encounter.origin = null		// station that crewman is from
encounter.done = false		// when true, never show this one again

// Consider whether we want to present this encounter while traveling
// to (if arriving=true) or from (arriving=false) the given station.
// If it's not a good time to present this encounter, return null.
// If it is, return a map containing the following data:
//		priority: 0 (unimportant), 1 (normal), 2 (crucial)
//		distance: how far (0-1) from the station this encounter should happen
// You can also add any other data you will want at presentation time.
// The host app will then decide whether to actually present this
// encounter.
encounter.consider = function(station, arriving)
	if self.done then return null
	if self.newChar == null then
		// We can gain a crewman only on the departing leg
		if arriving then return null
		// and even there, only with low probability
		probability = 0.1
		if rnd > probability then return null
	
		return self.consideration(station, arriving, 0)
	else
		// Once we have a crewman, we can lose him only
		// when returning to the same station.
		// (ToDo: this really should be on the departing leg but
		// only when the final destination is self.origin.
		// But we don't have the data to tell that.  Hmm.)
		if arriving and station == self.origin then
			return self.consideration(station, arriving, 2)
		end if
	end if
	
end function

encounter.present = function(data)
	if self.newChar then
		self.presentLoss data
	else
		self.presentGain data
	end if
end function
	
encounter.presentGain = function(data)
	charName = randomNames.human
	description = "As you are exiting the system, your sensors pick up a tiny " +
	  "one-person pod.  Investigating, you find a half-starved man named " +
	  charName + ".  ""Take me with you!"" he pleads.  ""I can't go back there!"""
	self.showDialog data, description

	newbie = new character.Character
	newbie.name = charName
	newbie.maxHealth = 6 + ceil(6*rnd)
	newbie.health = newbie.maxHealth
	newbie.setMapPos [0, 2]
	newbie.boardShip playerShip
	game.renderer.renderMinion newbie
	self.newChar = newbie
	self.origin = data.station
end function

encounter.presentLoss = function(data)
	description = "Seeing where you are headed, " + self.newChar.name +
	  " bursts into a panic.  ""NO!!!"" he shouts. ""I can't go back there!""" +
	  "  Before you can stop him, he throws himself into an escape pod " + 
	  "and ejects himself into space.  The pod's beacon is apparently " +
	  "disabled, and it is quickly swallowed up by the void."
	self.showDialog data, description

	self.newChar.leaveShip
	disp.shipSprites.sprites.removeVal self.newChar
	self.done = true
end function

if locals == globals then
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
