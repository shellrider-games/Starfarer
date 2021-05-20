// Our very first encounter!

if not globals.hasIndex("uiWidgets") then
	if env.importPaths.indexOf("/usr/src") == null then
		env.importPaths.push "/usr/src"
	end if
	import "uiWidgets"
end if

// Consider whether we want to present this encounter while traveling
// to (if arriving=true) or from (arriving=false) the given station.
// If it's not a good time to present this encounter, return null.
// If it is, return a map containing the following data:
//		priority: 0 (unimportant), 1 (normal), 2 (crucial)
//		distance: how far (0-1) from the station this encounter should happen
// You can also add any other data you will want at presentation time.
// The host app will then decide whether to actually present this
// encounter.
consider = function(station, arriving)
	probability = 0.20		// 20% chance of this encounter
	if rnd > probability then return null
	data = {}
	data.priority = 0
	data.distance = 0.2 + 0.6 * rnd
	data.station = station
	data.arriving = arriving
	return data
end function

// If the host app decides to present this encounter, then it will call
// this present method, with the data returned from consider():
present = function(data)
	value = floor(rnd * 10) + 5
	description = "You have encountered an anomaly.  It hangs in front of your " +
	  "ship like a particularly empty region of space.  " +
	  "Analyzing it with your ship sensors yields data worth " +
	  value + " credits."
	
	descriptionBox = new uiWidgets.Label
	descriptionBox.init 480-150, 0, 300, 20, "descriptionBox"
	descriptionBox.text = description
	descriptionBox.font = fonts.Arial14
	descriptionBox.wrap
	
	outer.panel = new uiWidgets.Panel
	h = descriptionBox.height + 100
	panel.init 480-180, 320 - h/2, 360, h, "panel"
	panel.draw
	
	descriptionBox.bounds.y = panel.bounds.y + descriptionBox.height/2 - 16
	descriptionBox.draw
	
	whereLabel = new uiWidgets.Label
	whereLabel.init panel.right-204, panel.top-20, 200, 20
	whereLabel.color = "#CCCCFF"
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
	present
end if