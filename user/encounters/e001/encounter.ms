// Our very first encounter!

if not globals.hasIndex("Encounter") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
	import "encounterBase"
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
	probability = 0.20		// 20% chance of this encounter
	if rnd > probability then return null
	return self.consideration(station, arriving, 0)
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
encounter.present = function(data)
	value = floor(rnd * 10) + 5
	description = "You have encountered an anomaly.  It hangs in front of your " +
	  "ship like a particularly empty region of space.  " +
	  "Analyzing it with your ship sensors yields data worth " +
	  value + " credits."
	
	descriptionBox = new uiWidgets.Label
	descriptionBox.init 480-150, 0, 300, 20, "descriptionBox"
	descriptionBox.text = description
	descriptionBox.font = fonts.Arial14
	descriptionBox.color = "#222222"
	descriptionBox.wrap
	
	outer.panel = new uiWidgets.Panel
	h = descriptionBox.height + 100
	panel.init 480-180, 320 - h/2, 360, h, "panel"
	panel.draw
	
	descriptionBox.bounds.y = panel.bounds.y + descriptionBox.height/2 - 16
	descriptionBox.draw
	
	whereLabel = new uiWidgets.Label
	whereLabel.init panel.right-204, panel.top-20, 200, 20
	whereLabel.color = "#8080FF"
	whereLabel.alignment = uiWidgets.ALIGNRIGHT
	whereLabel.text = round(data.distance * 100000) + " km from " + data.station.name
	whereLabel.draw

	okButton = new uiWidgets.Button
	okButton.init 480-40, panel.bottom + 20, 80, 24, "OK"
	okButton.backColor = panel.mainColor
	okButton.start
	okButton.action = function()
		outer.done = true
	end function

	done = false
	while not done
		uiWidgets.update 1/60
		yield
	end while

	crewStatistics.money = crewStatistics.money + value
	panel.erase
end function


if locals == globals then
	crewStatistics = {"money": 0}
	enc = new encounter
	enc.present enc.consideration({"name":"Demo"}, true)
end if
