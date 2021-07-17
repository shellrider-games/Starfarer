// An alien fungus gives you a chance to turn food into medicine.

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
	// this encounter only applies if we have food
	if not playerShip.findItemOfType(item.FoodItem) then return null

	probability = 0.10		// chance of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving, 0)
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	oldItem = playerShip.findItemOfType(item.FoodItem)
	if not oldItem then return  // oops, no food

	value = floor(rnd * 10) + 5
	description = "You encounter a passing ship.  Chatting with the crew, " +
	  "you learn they have an alien fungus which can turn a crate of food " +
	  "into medicine 80% of the time.  But when it fails, the food is ruined." +
	  "  They offer to let you try it."

	choice = self.showDialog(data, description, ["Give it a try.", "Politely decline."])
	if choice == 1 then return		// declined to try

	oldItem = playerShip.findItemOfType(item.FoodItem)
	cell = playerShip.getCell(oldItem.col, oldItem.row)
	cell.contents = null
	disp.shipSprites.sprites.removeVal oldItem
	
	success = (rnd < 0.80)
	if success then
		description = "You apply the sample to a crate of food, and wait." +
		  "  Within minutes it the food is covered with the medicinal fungus." +
		  "  It worked!"
		if globals.hasIndex("playerShip") then
			newItem = new item.MedsItem
			cell.placeItem newItem
			game.renderer.renderContents cell
		end if
	else
		description = "You apply the sample to a crate of food, and wait." +
		  "  Within minutes the food turns black and begins to smell foul." +
		  "  It seems luck was not with you today."
	end if
	self.showDialog data, description
end function


if locals == globals then
	Starfarer = {"money": 0}
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
