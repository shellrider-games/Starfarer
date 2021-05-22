// This file defines the base class for any encounter.  The base class
// provides common utility functions that most encounters will need, like
// drawing a dialog describing what's happening, giving the user response
// choices, etc.

if not globals.hasIndex("uiWidgets") then import "uiWidgets"

Encounter = {}

// Consider presenting this encounter.  Subclasses will usually want to
// override this to apply a different probability, or to present only when
// certain game conditions are met.  Return null if you don't want to
// present; otherwise, return self.consideration (a little map that
// wraps up this encounter with other data that may be needed).
Encounter.consider = function(station, arriving)
	if rnd < 0.2 then return null
	return self.consideration(station, arriving)
end function

// This function creates the little map that returns this encounter for
// consideration on a particular journey.  Subclasses will not usually
// need to override this.
Encounter.consideration = function(station, arriving, priority=1, distance=null)
	data = {}
	data.encounter = self
	data.priority = priority
	if distance == null then distance = 0.2 + 0.6 * rnd
	data.distance = distance
	data.station = station
	data.arriving = arriving
	return data
end function

// This method is called when the encounter should be presented.
// The data given is the same object returned from consider().
// Subclasses will usually override this.
Encounter.present = function(data)

end function

// Helper method that subclasses can using in present():
// Show a dialog box with a short paragraph of text, and zero or more
// options (not yet supported).
//
// Parameters:
//	data: data object passed from consider() to present()
//	text: main descriptive text to show
//	options: optional set of options the player can choose
// Returns: index of the option chosen, or null if none
Encounter.showDialog = function(data, text, options=[])
	
	textBox = new uiWidgets.Label
	textBox.init 480-150, 0, 300, 20, "textBox"
	textBox.text = text
	textBox.font = fonts.Arial14
	textBox.color = "#222222"
	textBox.wrap
	
	responseButtons = []
	if options then
		for i in options.indexes
			opt = options[i]
			label = new uiWidgets.Label
			label.init 0, 0, 220, fonts.Arial14.lineHeight, "response " + i
			label.text = opt
			label.font = fonts.Arial14
			label.color = "#222222"
			label.wrap
		
			btn = new uiWidgets.Button
			btn.init 0, 0, label.width + 20, label.height + 10, "response " + i
			btn.caption = label
			btn.choiceNum = i
			btn.action = function()
				outer.responseIndex = self.choiceNum
				outer.done = true
			end function
			responseButtons.push btn
		end for
	end if
		
	panel = new uiWidgets.Panel
	h = textBox.height + 60 + 40 * (responseButtons.len == 0)
	for btn in responseButtons
		h = h + btn.height + 10
	end for
	panel.init 480-180, 320 - h/2, 360, h, "panel"
	panel.draw
	
	y = panel.top - 22
	textBox.bounds.y = y - textBox.height/2
	textBox.draw
	y = y - textBox.height - 20
	
	for btn in responseButtons
		btn.bounds.x = panel.bounds.x
		btn.bounds.y = y - btn.height/2
		btn.backColor = panel.mainColor
		btn.start
		y = y - btn.height - 10
	end for
	
	whereLabel = new uiWidgets.Label
	whereLabel.init panel.right-204, panel.top-18, 200, 18
	whereLabel.color = "#CCCCFF"
	whereLabel.alignment = uiWidgets.ALIGNRIGHT
	whereLabel.text = round(data.distance * 100000) + " km from " + data.station.name
	whereLabel.draw

	okButton = null
	if not responseButtons then
		okButton = new uiWidgets.Button
		okButton.init 480-40, panel.bottom + 20, 80, 24, "OK"
		okButton.backColor = panel.mainColor
		okButton.start
		okButton.action = function()
			outer.done = true
		end function
	end if

	done = false
	responseIndex = null
	while not done
		uiWidgets.update 1/60
		yield
	end while

	if okButton then okButton.stop
	for btn in responseButtons; btn.stop; end for
	panel.erase
	return responseIndex
end function
