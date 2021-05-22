// Our second test encounter.
// Gain a crewman!

if not globals.hasIndex("Encounter") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
end if


encounter = new encounterBase.Encounter

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
	// this encounter only happens on the departing leg
	if arriving then return null
	// and even there, only with low probability
	probability = 0.10
	if rnd > probability then return null
	
	return self.consideration(station, arriving, 0)
end function

encounter.present = function(data)
	description = "As you are exiting the system, your sensors pick up a tiny " +
	  "one-person pod.  Investigating, you find a half-starved man inside, who " +
	  "begs you to join your crew.  ""Take me with you!"" he pleads.  ""I can't " +
	  "go back there!"""
	self.showDialog data, description

	newbie = new character.Character
	newbie.setMapPos [0, 2]
	newbie.boardShip playerShip
	game.renderer.renderMinion newbie
end function


if locals == globals then
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
