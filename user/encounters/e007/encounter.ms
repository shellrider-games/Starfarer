// Our very first ship encounter!

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
	import "shipModel"
	import "shipDisplay"
end if

encounter = new encounterBase.CombatEncounter

encounter.consider = function(station, arriving)
	probability = 0.90		// probability (on 0-1 scale) of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving)
end function

// Pirates take the player's cargo.  Return true if this is sufficient,
// or false if we couldn't find any decent cargo.
encounter.takeCargo = function
	cratesTaken = 0
	for col in playerShip.columnRange
		for row in playerShip.rowRange
			cell = playerShip.map[col][row]
			if cell == null then continue			
			crate = playerShip.removeCellContents(cell)
			if crate then cratesTaken += 1
		end for
	end for
	return cratesTaken > 0
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	// Prepare the enemy ship (with weapons!)
	self.ship = shipModel.newShipOfDesign("Robin")
	self.ship.name = "Pirates"
	self.ship.addSystem systems.Weapons.make(2,0)
	self.ship.hp = 3	// a bit easy, but let's not take forever on a random encounter!

	// add some crew
	pirates = ["female09", "female10", "female11", "male13", "male14", "male15"]
	pirates.shuffle
	minion = new character.Character
	minion.name = "Pirate1"
	minion.portrait = pics.get("portraits/human_" + pirates.pop)
	minion.setMapPos [0, 6]
	minion.boardShip self.ship
	
	minion = new character.Character
	minion.name = "Pirate2"
	minion.portrait = pics.get("portraits/human_" + pirates.pop)
	minion.setMapPos [3, 3]
	minion.boardShip self.ship

	// make a renderer for the ship
	self.renderer = new shipDisplay.Renderer
	self.renderer.x = 720
	self.renderer.renderShip self.ship
	
	// show the dialog
	text = "Heave to and prepare to be boarded!  Yer cargo, or yer life!"
	choices = ["Surrender", "Flee", "Fight!"]
	opts = new DialogOptions
	opts.portrait = minion.portrait
	opts.onScreen = true
	opts.buttonsPerRow = 3
	choice = self.showDialog(data, text, choices, opts)

	if choices[choice] == "Surrender" then
		if self.takeCargo then
			self.showDialog data,
			   "The pirates take all your cargo, but leave your ship intact."
			self.removeOtherShip
		else
			self.showDialog data,
			   "When they realize you have no cargo, the pirates power up their weapons!"
			game.beginCombat self
		end if
	else if choices[choice] == "Flee" then
		failMsg = "You try to flee, but the pirates catch you!"
		if not self.handleFlee(data, failMsg) then game.beginCombat self
	else
		game.beginCombat self
	end if
end function

if locals == globals then
	enc = new encounter
	station = new stationModel.Station
	enc.present enc.consideration({"name":"Demo"}, true)
end if
