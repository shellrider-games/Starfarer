import "miscUtil"
ensureImport "uiWidgets"

globals.DialogOptions = {}
DialogOptions.buttonsPerRow = 1
DialogOptions.captionAlign = uiWidgets.ALIGNCENTER
DialogOptions.portrait = null
DialogOptions.onScreen = false	// if true, draw portrait with screen effect


// Helper method that subclasses can using in present():
// Show a dialog box with a short paragraph of text, and zero or more
// choices (not yet supported).
//
// Parameters:
//	whereText: string drawn to indicate the context
//	text: main descriptive text to show
//	choices: optional set of choices (button captions) to show
// Returns: index of the option chosen, or null if none
showGeneric = function(whereText, text, choices=null, options=null)
	capturedBackground = gfx.getImage

	if choices == null then choices = []
	if options == null then options = DialogOptions
	
	fullWidth = 360
	gap = 10
	margin = 20
	textWidth = fullWidth - margin*2
	textLeft = 480-textWidth/2
	if options.portrait then
		textLeft += 72
		textWidth -= 72
	end if
	
	textBox = new uiWidgets.Label
	textBox.init textLeft, 0, textWidth, 20, "textBox"
	textBox.text = text
	textBox.font = fonts.Arial14
	textBox.color = "#222222"
	textBox.wrap
	if textBox.lines.len > 4 then
		textBox2 = new uiWidgets.Label
		textBox2.init 480 - fullWidth/2 + margin, 0, fullWidth - margin*2, 20, "textBox2"
		textBox2.text = textBox.lines[4:].join
		textBox2.font = fonts.Arial14
		textBox2.color = "#222222"
		textBox2.wrap
		textBox.lines = textBox.lines[:4]
		textBox.resetHeight
	else
		textBox2 = null
	end if

	responseButtons = []
	totalButtonHeight = 0
	if choices then
		btnWidth = (fullWidth - margin*2 - gap*(options.buttonsPerRow-1)) /
		   options.buttonsPerRow
		maxHeightThisRow = 0
		for i in choices.indexes
			opt = choices[i]
			label = new uiWidgets.Label
			label.init 0, 0, btnWidth-20, fonts.Arial14.lineHeight, "response " + i
			label.text = opt
			label.font = fonts.Arial14
			label.color = "#222222"
			label.alignment = options.captionAlign
			label.wrap
		
			btn = new uiWidgets.Button
			btn.init 0, 0, btnWidth, label.height + 10, "response " + i
			maxHeightThisRow = max(maxHeightThisRow, btn.height)
			if i % options.buttonsPerRow == 0 then
				totalButtonHeight += maxHeightThisRow + 10
				maxHeightThisRow = 0
			end if
			btn.caption = label
			btn.choiceNum = i
			btn.action = function
				outer.responseIndex = self.choiceNum
				outer.done = true
			end function
			responseButtons.push btn
		end for
	else
		btnWidth = 80
		btn = new uiWidgets.Button
		btn.init 0, 0, 80, 24, "OK"
		btn.action = function; outer.done = true; end function
		responseButtons.push btn
		totalButtonHeight += btn.height + 10
	end if
	
	textAreaHeight = textBox.height
	if textBox2 then textAreaHeight += textBox2.height
	if options.portrait then textAreaHeight = max(textAreaHeight, 64)
		
	panel = new uiWidgets.Panel
	h = textAreaHeight + totalButtonHeight + 48
	panel.init 480-fullWidth/2, 320 - h/2, fullWidth, h, "panel"
	panel.draw
	
	y = panel.top - 22
	
	textBox.bounds.y = y - textBox.height/2
	textBox.draw
	if textBox2 then
		textBox2.bounds.y = y  - textBox.height - textBox2.height/2
		textBox2.draw
	end if
	
	x = panel.left + margin
	y = panel.top - 22 - textAreaHeight - 20
	maxHeightThisLine = 0
	for btn in responseButtons
		if options.buttonsPerRow == 1 then
			btn.bounds.x = panel.bounds.x  // (center the button in the panel)
		else
			btn.bounds.x = x + btn.width/2
		end if
		btn.bounds.y = y - btn.height/2
		maxHeightThisLine = max(maxHeightThisLine, btn.height)
		btn.backColor = panel.mainColor
		btn.start
		x += btnWidth + gap
		if x + btnWidth > panel.right then
			y -= maxHeightThisLine + 10
			x = panel.left + margin
			maxHeightThisLine = 0
		end if
	end for
	
	whereLabel = new uiWidgets.Label
	whereLabel.init panel.right-204, panel.top-18, 200, 18
	whereLabel.color = "#CCCCFF"
	whereLabel.alignment = uiWidgets.ALIGNRIGHT
	whereLabel.text = whereText
	whereLabel.draw

	if options.portrait then
		gfx.drawImage options.portrait, 
		   panel.left + margin, panel.top - margin - 64, 64, 64
		if options.onScreen then
			gfx.drawImage pics.get("screenEffect"), 
			  panel.left + margin, panel.top - margin - 64, 64, 64
		end if
	end if

	done = false
	responseIndex = null
	while not done
		uiWidgets.update 1/60
		yield
	end while

	for btn in responseButtons; btn.stop; end for
	panel.erase
	gfx.drawImage capturedBackground
	return responseIndex
end function


demo = function
	clear
	import "setup"
	ensureImport "pics"
	
	text = "This is a demo of the showGeneric method.  It displays " +
	  "some text, followed by zero or more choices (buttons) for " +
	  "the player to choose from.  It supports a portrait too, " +
	  "and if the text is long enough, it'll wrap neatly around " +
	  "that."

	choices = ["Neat!", "Not terrible, but not great", "Ugh.", "Actually good."]
	opts = new DialogOptions
	opts.buttonsPerRow = 2
	opts.portrait = pics.portrait.human.male[12]
	opts.onScreen = true
	choiceIndex = showGeneric("dialogs.ms", text, choices, opts)
	
	showGeneric "dialogs.ms", "You chose: " + choices[choiceIndex]
	
	
end function

if locals == globals then demo
