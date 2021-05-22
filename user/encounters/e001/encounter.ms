// Our very first encounter!

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
	probability = 0.20		// 20% chance of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving, 0)
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	value = floor(rnd * 10) + 5
	description = "You have encountered an anomaly.  It hangs in front of your " +
	  "ship like a particularly empty region of space.  " +
	  "Analyzing it with your ship sensors yields data worth " +
	  value + " credits."

	self.showDialog data, description
	crewStatistics.money = crewStatistics.money + value
end function


if locals == globals then
	crewStatistics = {"money": 0}
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
