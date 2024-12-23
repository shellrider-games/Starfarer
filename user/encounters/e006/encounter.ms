// Delivery mission: take a data stick to another station.

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
npc.portrait = pics.portrait.human.female.any

encounter = new encounterBase.Encounter
encounter.started = false
encounter.done = false
encounter.starsystem = null

encounter.consider = function(station, arriving)
	// This encounter happens only at cantinas, not during transit.
	return null
end function

encounter.addNPCsToCantina = function(station)
	if self.done then return
	if not self.started and rnd < 0.5 then
		station.cantina.push npc
	end if
	if self.started and game.station == self.starsystem then
		dialogue = "You made the trip to " + self.starsystem.name + 
		" as " + npc.name + " requested. You find the woman she described on the station. " + 
		"She seems nervous when you approach her but after exchanging the " +
		"datastick she relaxes a bit. She thanks you and wires you 500 credits."
		self.showDialog game.station, dialogue
		game.money += 500
		self.done = true
	end if
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.presentNPC = function(npc)
	while self.starsystem == null or self.starsystem == game.station
		self.starsystem = game.stations.any
	end while
	dialogue = "Hey, you look like someone that can relay a datastick to a friend " +
	"of mine in the " + self.starsystem.name + " system.  " +
	"I need to get some data there without any so-called authorities snooping " +
	"around.  You know what I mean.  There are 500 credits in it for you..."
	description = npc.name + ": " + dialogue
	choice  = self.showDialog(npc.station, description, ["Accept", "Decline"])
	game.station.cantina.removeVal npc
	if choice == 1 then return		// declined
	self.started = true
end function


if locals == globals then
	enc = new encounter
	station = new stationModel.Station
	enc.presentNPC station, npc
end if
