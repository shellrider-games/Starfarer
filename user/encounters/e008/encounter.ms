//Galactic nomads offer you some random cargo in exchange for some of your fuel

if not globals.hasIndex("encounterBase") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
	import "randomNames"
	import "item"
end if

encounter = new encounterBase.Encounter

encounter.consider = function(station, arriving)
	// this encounter only applies if we have more than 3 fuel
	if not game.fuel > 3 then return null
	probability = 0.05		// chance of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving, 0)
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	description = "A convoy of galactic nomads hail you, offering some of " +
	  "their unique cargo in exchange for some fuel. " +
	  "They need 1 unit of fuel and offer you a box of cargo in exchange " 

	choice = self.showDialog(data, description, ["Trade.", "Decline."])
	if choice == 1 then return	// declined

	itemClasses = [item.FoodItem, item.GunsItem, item.MedsItem, item.WaterItem]
    newItem = new itemClasses.any

	if globals.hasIndex("playerShip") then
		game.fuel -= 1
		playerShip.addCargo newItem
	end if

	description = "The nomads thank you for your. Some of their crew " +
	  "haul a crate of " + newItem.name + " over to your ship."
	
	  self.showDialog data, description
end function


if locals == globals then
	Starfarer = {"money": 0}
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
