// This is a test encounter exactly like e005, except that the NPC
// only shows up half the time.

if not globals.hasIndex("Encounter") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
	import "randomNames"
	import "item"
	import "listUtil"
	import "stationModel"
end if

npc = new stationModel.CantinaNPC
npc.name = randomNames.human

encounter = new encounterBase.Encounter

encounter.consider = function(station, arriving)
	// This encounter happens only at cantinas, not during transit.
	return null
end function

encounter.addNPCsToCantina = function(station)
	if rnd < 0.5 then station.cantina.push npc
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.presentNPC = function(npc)
	responses = [
		"Leave me alone.",
		"Don't bother me.",
		"Beat it, pal.",
		"Can't a guy drink in peace?"]
	
	description = npc.name + ": " + responses.any
	self.showDialog npc.station, description
end function


if locals == globals then
	enc = new encounter
	station = new stationModel.Station
	enc.presentNPC station, npc
end if
