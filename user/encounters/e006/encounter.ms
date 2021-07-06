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
	import "quest"
end if

npc = new stationModel.CantinaNPC
npc.name = randomNames.human

encounter = new encounterBase.Encounter

encounter.consider = function(station, arriving)
	// This encounter happens only at cantinas, not during transit.
	return null
end function

encounter.addNPCsToCantina = function(station)
	for quest in game.quests
		if quest.id == "datastick_delivery" then return //guards us from offering this quest twice
	end for
	if rnd < 0.5 then station.cantina.push npc
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.presentNPC = function(npc)
	starsystem = null
	while starsystem == null or starsystem == Starfarer.currentStation
	starsystem = game.stations.any
	end while
	dialogue = "Hey, you look like someone that can relay a datastick to a friend of mine in the " + starsystem.name +" system." +
	" I need to get some data there without any so called authorities snooping around. Ya get what I mean?" +
	" There are 500 credits in it for you..."
	description = npc.name + ": " + dialogue
	choice  = self.showDialog(npc.station, description, ["Accept", "Decline"])
	game.currentStation.cantina.removeVal npc
	if choice == 1 then return		//declined

	messageDeliveryQuest = new quest.Quest
	messageDeliveryQuest.id = "datastick_delivery"
	messageDeliveryQuest.done = false
	messageDeliveryQuest.checkConditions = function()
		if game.currentStation.name == starsystem.name and self.done == false then
			self.done = true
			game.money = game.money + 500
		end if
	end function
	game.quests.push messageDeliveryQuest

end function


if locals == globals then
	enc = new encounter
	station = new stationModel.Station
	enc.presentNPC station, npc
end if
