// Random crewmen for hire that appear in most cantinas.

if not globals.hasIndex("encounterBase") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
	import "randomNames"
	import "item"
	import "stationModel"
	import "importUtil"
end if

ensureImport "listUtil"
ensureImport "mathUtil"

encounter = new encounterBase.Encounter

encounter.consider = function(station, arriving)
	// This encounter happens only at cantinas, not during transit.
	return null
end function

encounter.addNPCsToCantina = function(station)
	qty = floor(rnd * 3)  // 0, 1, or 2 NPCs per station
	for i in range(0, qty-1, 1)
		npc = new stationModel.CantinaNPC
		npc.fee = round(mathUtil.randRange(500, 1500))
		npc.baseName = randomNames.human
		npc.name = npc.baseName + " (AFH, $" + npc.fee + ")"
		station.cantina.push npc
	end for
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.presentNPC = function(npc)	
	description = npc.baseName + " (Available For Hire):" + char(13) +
		char(13) + "Looking for help?  I'll join your crew for " +
		npc.fee + " credits."
	opts = new DialogOptions
	opts.portrait = npc.portrait
	opts.buttonsPerRow = 2
	if game.money < npc.fee then
		self.showDialog npc.station, description, ["(Insufficient funds)"], opts
		return
	end if
	choices = ["You're hired!", "Never mind."]
	choice = self.showDialog(npc.station, description, choices, opts)
	if choice == 1 then return
	
	game.money -= npc.fee
	newbie = new character.Character
	newbie.name = npc.baseName
	newbie.maxHealth = 6 + ceil(6*rnd)
	newbie.health = newbie.maxHealth
	newbie.setMapPos [0, 2]
	newbie.boardShip playerShip
	game.renderer.renderMinion newbie
	minionUI.addMinion newbie
	npc.station.cantina.removeVal npc
end function
