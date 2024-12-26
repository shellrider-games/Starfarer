// The police pull you over to search your cargo for contraband.

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
	probability = 0.1		// probability (on 0-1 scale) of this encounter
	if rnd > probability then return null
	
	self.illegalTypes = ["guns", "narcotics"]
	
	return self.consideration(station, arriving)
end function

// Take any illegal items from the player's cargo.
// Return how many crates were taken.
encounter.takeCargo = function
	cratesTaken = 0
	for col in playerShip.columnRange
		for row in playerShip.rowRange
			cell = playerShip.map[col][row]
			if cell == null or cell.contents == null then continue
			if self.illegalTypes.contains(cell.contents.name) then
				crate = playerShip.removeCellContents(cell)
				if crate then cratesTaken += 1
			end if
		end for
	end for
	return cratesTaken
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	// Prepare the enemy ship (with weapons!)
	self.ship = shipModel.newShipOfDesign("Robin")
	self.ship.name = "Police"
	self.ship.addSystem systems.Weapons.make(2,0)
	self.ship.hp = 3	// a bit easy, but let's not take forever on a random encounter!

	// add some crew
	pirates = ["female00", "female03", "female07", "female14", "male05", "male09"]
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
	text = "Police hail you and demand to inspect your cargo."
	choices = ["Yield", "Flee", "Bribe", "Fight!"]
	if game.money < 10 then choices.removeVal "Bribe"
	opts = new DialogOptions
	opts.portrait = pics.get("policeBadge")
	opts.buttonsPerRow = choices.len
	choice = self.showDialog(data, text, choices, opts)

	if choices[choice] == "Yield" then
		taken = self.takeCargo
		if taken > 0 then
			fine = taken * 1000
			self.showDialog data,
			   "The police confiscate " + taken + " crate" + "s" * (taken != 1) +
			   " of contraband, and fine you " + fine + " credits for " +
			   "transport of illegal goods.", [], opts
			game.money -= fine		// ToDo: animate this
		else
			self.showDialog data,
			   "The police find nothing illegal in your holds, " +
			   "and apologize for the inconvenience.", [], opts
		end if
		self.removeOtherShip
	else if choices[choice] == "Flee" then
		failMsg = "You try to flee, but the police catch you!"
		if not self.handleFlee(data, failMsg) then game.beginCombat self
	else if choices[choice] == "Bribe" then
		// ToDo: some nifty UI to let the user choose how much
		// they want to offer, for a certain % chance of success.
		// For now, we'll just hard-code it:
		offer = max(0, max(1000, game.money))
		chanceOfSuccess = 100 * (offer / 2000)
		if rnd * 100 < chanceOfSuccess then
			self.showDialog data,
			   "The police accept your credit transfer and quietly move away."
			game.money -= offer
			self.removeOtherShip
		else
			self.showDialog data,
			   "The police seem offended by your offer of " + offer + 
			   " credits, and power up their weapons!"
			game.beginCombat self
		end if
	else
		game.beginCombat self
	end if
end function

if locals == globals then
	enc = new encounter
	station = new stationModel.Station
	enc.present enc.consideration({"name":"Demo"}, true)
end if
