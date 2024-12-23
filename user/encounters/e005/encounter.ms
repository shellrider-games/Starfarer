// A shady NPC appears to be following you everywhere you go, showing
// up in every cantina.  How does he DO that?

// (NOTE: This is a good test of the systems, but not a very interesting
// game element.  We'll need to make this guy do something more engaging,
// or else remove this encounter.)

if not globals.hasIndex("encounterBase") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
	import "randomNames"
	import "item"
	import "listUtil"
	import "stationModel"
	import "pics"
end if

npc = new stationModel.CantinaNPC
npc.name = randomNames.human
npc.portrait = pics.portrait.human.male[2]

encounter = new encounterBase.Encounter

encounter.consider = function(station, arriving)
	// This encounter happens only at cantinas, not during transit.
	return null
end function

encounter.addNPCsToCantina = function(station)
	// our NPC is always present, at every station!
	station.cantina.push npc
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
	npc.station = new stationModel.Station
	enc.presentNPC npc
end if
