// An alien fungus gives you a chance to turn food into medicine.

if not globals.hasIndex("Encounter") then
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

	probability = 0.10		// chance of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving, 0)
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	value = floor(rnd * 10) + 5
	description = "You find debris of an unknown spaceship floating around." +
     "You can search the debris for valuables but there is a risk of it damaging your ship if you stay too long."

	choice = self.showDialog(data, description, ["Search the debris.", "Ignore it"])
	if choice == 1 then return		// declined to try


	
	success = (rnd < 0.80)
	if success then
		description = "You search the ship and find some weapons."
		if globals.hasIndex("playerShip") then
			cell = playerShip.getAnyFreeCellPreferCargoInCell
            newItem = new item.GunsItem
			cell.placeItem newItem
			game.renderer.renderContents cell
		end if
	else
		description = "Your search yields no results."
	end if
    description = description + " Unfortunately your ship got hit and your hull damaged in the process."
    crewStatistics.hull = crewStatistics.hull - 2
	self.showDialog data, description
end function


if locals == globals then
	crewStatistics = {"money": 0}
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
