// This module implements user interface widgets: dialog boxes, tabs,
// buttons, labels, that sort of thing.
//
// These all draw in the disp.uiPixel layer, except when they need something
// a little more spritey, in which case they may esu disp.uiSprites.

import "miscUtil"
ensureImport "setup"
ensureImport "qa"
ensureImport "stringUtil"
ensureImport "listUtil"
ensureImport "pics"

//----------------------------------------------------------------------
// Constants
//----------------------------------------------------------------------

ALIGNLEFT = 0
ALIGNCENTER = 1
ALIGNRIGHT = 2

//----------------------------------------------------------------------
// General utility methods
//----------------------------------------------------------------------

loadImage = @pics.get

load9SliceImage = function(name, left=12, bottom=12, right=12, top=12)
	img = loadImage(name)
	return Image9Slice.make(img, left, bottom, right, top)
end function

// clearAll: clear all widgets (and the entire uiPixel display).
clearAll = function
	if _allWidgets then
		for i in range(_allWidgets.len-1, 0)
			_allWidgets[i].stop
		end for
	end if
	disp.uiPixel.clear color.clear
	outer._allWidgets = []
end function

// redrawAll: redraw all widgets
redrawAll = function
	for widget in _allWidgets
		widget.redraw
	end for
end function

//----------------------------------------------------------------------
// Image9Slice class: an image wrapper with margins that are not stretched,
// and a middle that is stretched when drawn to any size.
//----------------------------------------------------------------------

Image9Slice = {}
Image9Slice.image = null		// (an Image instance)
Image9Slice.leftMargin = 0
Image9Slice.bottomMargin = 0
Image9Slice.rightMargin = 0
Image9Slice.topMargin = 0

Image9Slice.make = function(image, left=12, bottom=12, right=12, top=12)
	noob = new Image9Slice
	noob.image = image
	noob.leftMargin = left
	noob.bottomMargin = bottom
	noob.rightMargin = right
	noob.topMargin = top
	return noob
end function

Image9Slice.draw = function(left, bottom, width, height, tint="#FFFFFF")
	midH = height - self.bottomMargin - self.topMargin
	srcH = self.image.height - self.bottomMargin - self.topMargin
	nearTop = bottom + height - self.topMargin
	srcNearTop = self.image.height - self.topMargin
	midW = width - self.leftMargin - self.rightMargin
	srcW = self.image.width - self.leftMargin - self.rightMargin
	nearRight = left + width - self.rightMargin
	srcNearRight = self.image.width - self.rightMargin
	
	// left side (bottom, middle, top)
	disp.uiPixel.drawImage self.image, 
		left, bottom, self.leftMargin, self.bottomMargin,
		0, 0, self.leftMargin, self.bottomMargin, tint
	disp.uiPixel.drawImage self.image, 
		left, bottom + self.bottomMargin, self.leftMargin, midH,
		0, self.bottomMargin, self.leftMargin, srcH, tint
	disp.uiPixel.drawImage self.image, 
		left, nearTop, self.leftMargin, self.topMargin,
		0, srcNearTop, self.leftMargin, self.topMargin, tint
	
	// center section (bottom, middle, top)
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, bottom, midW, self.bottomMargin,
		self.leftMargin, 0, srcW, self.bottomMargin, tint
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, bottom + self.bottomMargin, midW, midH,
		self.leftMargin, self.bottomMargin, srcW, srcH, tint
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, nearTop, midW, self.topMargin,
		self.leftMargin, srcNearTop, srcW, self.topMargin, tint
	
	// right section (bottom, middle, top)
	disp.uiPixel.drawImage self.image, 
		nearRight, bottom, self.rightMargin, self.bottomMargin,
		srcNearRight, 0, self.rightMargin, self.bottomMargin, tint
	disp.uiPixel.drawImage self.image, 
		nearRight, bottom + self.bottomMargin, self.rightMargin, midH,
		srcNearRight, self.bottomMargin, self.rightMargin, srcH, tint
	disp.uiPixel.drawImage self.image, 
		nearRight, nearTop, self.rightMargin, self.topMargin,
		srcNearRight, srcNearTop, self.rightMargin, self.topMargin, tint
end function

//----------------------------------------------------------------------
// Widget base class: represents a axis-aligned rectangular area of the
// screen that knows how to draw itself and respond to events.
//----------------------------------------------------------------------
Widget = {}
Widget._name = "Widget"
Widget.bounds = null	// should be a Bounds instance with rotation == 0
Widget.name = ""		// name for debugging/logging purposes
Widget.visible = true
Widget.backColor = color.clear

_allWidgets = []

Widget.init = function(left, bottom, width, height, name="")
	self.bounds = new Bounds
	self.bounds.x = left + width/2
	self.bounds.y = bottom + height/2
	self.bounds.width = width
	self.bounds.height = height
	self.name = name
end function

Widget.start = function
	if _allWidgets.indexOf(self) == null then _allWidgets.push self
//	print "started " + self.name + " with index " + _allWidgets.indexOf(self)
	self.draw
end function

Widget.stop = function
	_allWidgets.removeVal self
	self.erase
end function

Widget.update = function(dt = 0.1)
	// (overridden in most subclasses)
end function

Widget.left = function
	return self.bounds.x - self.bounds.width/2
end function

Widget.right = function
	return self.bounds.x + self.bounds.width/2
end function

Widget.bottom = function
	return self.bounds.y - self.bounds.height/2
end function

Widget.setBottom = function(newBottom)
	diff = newBottom - self.bottom
	self.bounds.height += diff
	self.bounds.y += diff/2
end function

Widget.top = function
	return self.bounds.y + self.bounds.height/2
end function

Widget.width = function
	return self.bounds.width
end function

Widget.height = function
	return self.bounds.height
end function

Widget.contains = function(x,y)
	return self.bounds.contains(x,y)
end function

Widget.draw = function
	disp.uiPixel.fillRect self.left, self.bottom, self.width, self.height, color.fuchsia
end function

Widget.erase = function
	disp.uiPixel.fillRect self.left, self.bottom, self.width, self.height, self.backColor
end function

Widget.redraw = function
	self.erase
	self.draw
end function

//----------------------------------------------------------------------
// Panel: a widget that draws an Image or Image9Slice.
//----------------------------------------------------------------------
Panel = new Widget
Panel._name = "Panel"
Panel.image = load9SliceImage("panel")		// may be an Image or an Image9Slice

Panel.init = function(left, bottom, width, height, name, image)
	super.init left, bottom, width, height, name
	if image != null then self.image = image
	
	// Get the color of a pixel at the center of the image; this is handy
	// so that things drawing on top of this panel can know what to use
	// for a background color.
	if self.image isa Image9Slice then src = self.image.image else src = self.image
	self.mainColor = src.pixel(src.width/2, src.height/2)
end function

Panel.draw = function
	if self.image isa Image then
		disp.uiPixel.drawImage self.image, self.left, self.bottom, self.width, self.height
	else if self.image isa Image9Slice then
		self.image.draw self.left, self.bottom, self.width, self.height
	end if
end function

//----------------------------------------------------------------------
// Label: a bit of text that knows its bounds and can be easily updated.
// (Note: if you're not going to update it, you could just print directly
// to the disp.uiPixel display.  Use a Label when you want an easy way to
// change the text displayed.)
//----------------------------------------------------------------------
Label = new Widget
Label._name = "Label"
Label.text = "Label"
Label.color = color.gray
Label.font = fonts.ArialBlack14
Label.alignment = ALIGNLEFT
Label.leading = 2  // (extra space between lines, in multiline label)

Label.init = function(left, bottom, width, height, text="", align=0)
	super.init left, bottom, width, height, text
	self.text = text
	self.alignment = align
end function

Label.wrap = function(wrapWidth=null)
	// Split our text into lines.
	if wrapWidth == null then wrapWidth = self.bounds.width
	self.lines = []
	for hardline in self.text.split(char(13))
		s = hardline
		while s
			cutPos = self.font.lenToFit(s, wrapWidth)
			if cutPos >= s.len then
				self.lines.push s
				break
			end if
			while cutPos > 1 and not stringUtil.whitespace.contains(s[cutPos-1])
				cutPos = cutPos - 1
			end while
			self.lines.push s[:cutPos]
			s = s[cutPos:].trim
		end while
	end for
	// Then increase height if needed
	h = self.lines.len * (self.font.lineHeight + self.leading)
	if h > self.bounds.height then self.bounds.height = h
end function

Label.resetHeight = function
	self.bounds.height = self.lines.len * (self.font.lineHeight + self.leading)
end function

Label.draw = function
	if self.hasIndex("lines") then data = self.lines else data = [self.text]
	y = self.bounds.y + 1 - self.font.sizeInner/2 + (data.len/2 - 1) * (self.font.lineHeight + self.leading)
	for line in data
		if self.alignment == ALIGNRIGHT then
			w = self.font.width(line)
			self.font.print line, self.right - w, y, 1, self.color
		else if self.alignment == ALIGNCENTER then
			w = self.font.width(line)
			self.font.print line, self.bounds.x - w/2, y, 1, self.color
		else
			self.font.print line, self.left, y, 1, self.color
		end if
		y = y - self.font.lineHeight - self.leading
	end for
	//for debugging, draw the frame: gfx.drawPoly self.bounds.corners, color.fuchsia
end function

Label.setText = function(s)
	if s == self.text then return
	self.text = s
	self.redraw
end function

Label.setColor = function(c)
	if c == self.color then return
	self.color = c
	self.redraw
end function

//----------------------------------------------------------------------
// Bar: a simple bar that has a value between 0 and 1 and is filled that much.
// Or, give it a value between -1 and 0, and it will fill from the right.
//----------------------------------------------------------------------

Bar = new Widget
Bar.name = "_Bar"
Bar.color = color.gray
Bar.backColor = color.clear
Bar.value = 0.5

Bar.draw = function
	left = self.bounds.x - self.bounds.width/2 + 1
	bottom = self.bounds.y - self.bounds.height/2 + 1
	width = self.bounds.width - 2
	height = self.bounds.height - 2
	right = left + width
	
	// border
	disp.uiPixel.drawRect left, bottom, width, height, self.color, 2

	// inset border
	disp.uiPixel.drawRect left+2, bottom+2, width-4, height-4, self.backColor, 2
	
	// fill
	if self.value >= 0 then
		divx = left+3 + round((width-6) * self.value)
		disp.uiPixel.fillRect left+3, bottom+3, divx - (left+3), height-6, self.color
		disp.uiPixel.fillRect divx, bottom+3, right-3 - divx, height-6, self.backColor
	else
		divx = right-3 + round((width-6) * self.value)
		disp.uiPixel.fillRect left+3, bottom+3, divx - (left+3), height-6, self.backColor
		disp.uiPixel.fillRect divx, bottom+3, right-2 - divx, height-6, self.color
	end if
end function

// Because the Bar completely overdraws its own space, redraw does not need
// to erase first.  So it can be just an alias for draw.
Bar.redraw = @Bar.draw

Bar.setValue = function(value)
	qa.assert value >= -1 and value <= 1
	if value == self.value then return
	self.value = value
	self.redraw
end function

//----------------------------------------------------------------------
// ThinBar: A bar but drawn to take up less space
//----------------------------------------------------------------------
ThinBar = new Bar
ThinBar.secondaryColor = "#333333"

ThinBar.draw = function
	left = self.bounds.x - self.bounds.width/2
	bottom = self.bounds.y - self.bounds.height/2
	width = self.bounds.width
	height = self.bounds.height
	right = left + width

	disp.uiPixel.fillRect left, bottom, width, height, color.clear

	if self.value >= 0 then
		divx = left + round(width * self.value)
		disp.uiPixel.fillRect left, bottom, divx - left, height, self.color
		disp.uiPixel.fillRect divx, bottom, right - divx, height, self.secondaryColor
	else
		divx = right + round(width * self.value)
		disp.uiPixel.fillRect left, bottom, divx - left, height, self.secondaryColor
		disp.uiPixel.fillRect divx, bottom, right - divx, height, self.color
	end if
end function

ThinBar.redraw = @ThinBar.draw

//----------------------------------------------------------------------
// HorizontalSlider: A bar but drawn to take up less space
//----------------------------------------------------------------------
HorizontalSlider = new Widget
HorizontalSlider._name = "HorizontalSlider"
HorizontalSlider.bar = new ThinBar
HorizontalSlider.trackingPress = false

HorizontalSlider.init = function(left, bottom, width, height, name="")
	self.bar.init left, bottom+2, width, height-4
	super.init left, bottom, width, height, name
end function

HorizontalSlider.draw = function
	left = self.bounds.x - self.bounds.width/2
	bottom = self.bounds.y - self.bounds.height/2
	width = self.bounds.width
	height = self.bounds.height
	disp.uiPixel.fillRect left-4, bottom, width+8, height, color.clear
	self.bar.draw

	disp.uiPixel.fillRect left+width*self.bar.value-4, bottom, 8, height, "#AAAAAA"

end function

HorizontalSlider.update = function(dt = 0.1)
	left = self.bounds.x - self.bounds.width/2
	width = self.bounds.width

	if not self.trackingPress then
		if mouseDown and self.contains(mouse) then
			self.bar.setValue min(max(0,(mouse.x - left)/width),1)
			self.trackingPress = true
			self.redraw
		end if
	else
		if not mousePressed then
			self.trackingPress = false
		else
			self.bar.setValue min(max(0,(mouse.x - left)/width),1)
			self.redraw
		end if
	end if
end function

HorizontalSlider.redraw = @HorizontalSlider.draw

//----------------------------------------------------------------------
// PowerControl: Vertical slider and energy bars for Starfarer Energy
// System.  This is a rather complex control with several parts: a
// slider that lets the user set the desired power level, and then a 
// series of bars that show the actual power level and system status
// (i.e. damage, temporarily disabled, etc.).  Subclasses will add
// additional functionality (weapon charge/control, etc.).
//----------------------------------------------------------------------

PowerControl = new Widget
PowerControl._name = "PowerControl"
PowerControl.system = null		// systems.System that we represent
PowerControl.width = 48			// width of this control in the layout
PowerControl.barHeight = 10		// height of individual bar
PowerControl.barGap = 2			// gap between bars
PowerControl.powerColor = "#00FF00"
PowerControl.disabledColor = color.aqua
PowerControl.onChange = null	// function called when set point changed

// onIconTap: invoked when user taps the icon.
// Default just toggles the set point between 0 and full.
// May be overridden for other functions.
PowerControl.onIconTap = function
	if self.system.setPoint > self.system.maxPower/2 then
		self.system.setPoint = 0
	else
		self.system.setPoint = self.system.maxPower
	end if
	self.onChange
	self.redraw	
end function


// Internal properties -- only subclasses should mess with these:
PowerControl.leftMargin = 4		// gap on left before power bars

PowerControl.stop = function
	super.stop
	if self.system then
		self.system.powerControl = null
		self.system = null
	end if
end function

PowerControl.initSystem = function(system)
	self.system = system
	system.powerControl = self
	self.name = system.name + " PC"
	qtyBars = system.maxPower
	bottom = self.bottom
	self.bounds.width = self.width
	self.bounds.height = self.barHeight * qtyBars + self.barGap * (qtyBars-1) + 60
	self.bounds.y = bottom + self.bounds.height/2
end function

// PowerControl.drawBar: draw just one bar of the control.
//		barNum: which bar to draw, from 0 (bottom) to qtyBars-1
//		repairLevel: repair of just this bar, from 0 (broken) to 1 (fine)
//		powered: if true, fill in green showing this bar powered
//		disabled: if true, this bar is disabled by ion attack etc.
PowerControl.drawBar = function(barNum, repairLevel, powered, disabled)
	// ensure our parameters make sense
	qa.assert not (powered and disabled), "bar " + barNum + " both powered and disabled"
	qa.assert not (powered and repairLevel<1), "bar " + barNum + " both powered and broken"

	// calculate bar coordinates on screen
	left = self.left + self.leftMargin
	bottom = self.bottom + 40 + (self.barHeight + self.barGap) * barNum
	width = 28
	height = self.barHeight
	
	// draw fill
	if repairLevel < 1 then
		// draw "X" indicating broken bar
		disp.uiPixel.fillRect left+1, bottom+1, width-2, height-2, color.black
		disp.uiPixel.line left+1, bottom+1, left+width-1, bottom+height-1, color.red
		disp.uiPixel.line left+1, bottom+height-1, left+width-1, bottom+1, color.red
		// and fill with yellow to indicate repaired amount
		if repairLevel > 0 then
			disp.uiPixel.fillRect left+1, bottom+1, (width-2)*repairLevel, height-2, color.yellow
		end if
	else
		if powered then fillColor = self.powerColor else fillColor = color.black
		disp.uiPixel.fillRect left+1, bottom+1, width-2, height-2, fillColor
	end if
	
	// draw frame
	if disabled then frameColor = self.disabledColor else frameColor = self.powerColor
	disp.uiPixel.drawRect left, bottom, width, height, frameColor
end function	

PowerControl.draw = function
	// draw icon
	sys = self.system
	if sys.icon != null then
		if sys.curPower < 1 then frameColor = color.silver else frameColor = self.powerColor
		disp.uiPixel.drawImage sys.icon, self.left + self.leftMargin - 4, self.bottom,
		  -1, -1, 0, 0, -1, -1, frameColor
	end if
	
	// draw bars
	qtyBars = sys.maxPower
	remainingRepair = sys.repairLevel
	for barNum in range(0, qtyBars-1)
		isDisabled = (barNum >= qtyBars - sys.disabled)
		isPowered = (barNum < sys.curPower)
		self.drawBar barNum, min(remainingRepair, 1), isPowered, isDisabled
		remainingRepair = max(remainingRepair - 1, 0)
	end for
	
	// draw set slider
	y = self.bottom + 40 + (self.barHeight + self.barGap) * sys.setPoint - self.barGap/2
	x = self.left + self.leftMargin + 28
	disp.uiPixel.fillPoly [[x,y], [x+8, y+8], [x+8, y-8]], color.silver
end function

PowerControl.update = function(dt = 0.1)
	if mouseDown and self.contains(mouse) then
		if mouse.y < self.bottom + 36 then
			self.onIconTap
			while mouse.button; end while
			return
		end if
		sys = self.system
		while mouse.button
			hitLevel = round((mouse.y - self.bottom - 40) / (self.barHeight + self.barGap))
			if hitLevel < 0 then hitLevel = 0
			if hitLevel > sys.maxPower then hitLevel = sys.maxPower
			if hitLevel != sys.setPoint then
				sys.setPoint = hitLevel
				self.onChange
				self.redraw
			end if
			yield
		end while
	else if self.system.needsDisplay then
		self.redraw
		self.system.needsDisplay = false
	end if
end function

//----------------------------------------------------------------------
// ChargedPowerControl: a specialized PowerControl that also has a
// vertical bar showing current charge level.
//----------------------------------------------------------------------
ChargedPowerControl = new PowerControl

ChargedPowerControl.width = PowerControl.width + 10
ChargedPowerControl.leftMargin = PowerControl.leftMargin + 10

ChargedPowerControl.draw = function
	super.draw
	bottomY = self.bottom + 40
	topY = self.top - 20
	disp.uiPixel.drawRect self.left+2, bottomY, 6, topY-bottomY, self.powerColor
	bottomY = bottomY + 1
	topY = topY - 1
	sys = self.system
	if sys.curCharge < sys.maxCharge then
		fillY = bottomY + round((topY-bottomY) * sys.curCharge/sys.maxCharge)
		disp.uiPixel.fillRect self.left+3, fillY+1, 4, topY-fillY-1, color.black
		disp.uiPixel.fillRect self.left+3, bottomY, 4, fillY-bottomY+1, color.yellow
	else
		disp.uiPixel.fillRect self.left+3, bottomY, 4, topY-bottomY, self.powerColor
	end if
end function

//----------------------------------------------------------------------
// ValuedBar: Combines a Bar with a label showing current/max.
//----------------------------------------------------------------------

ValuedBar = new Widget
ValuedBar._name = "ValuedBar"
ValuedBar.bar = new Bar
ValuedBar.label = new Label
ValuedBar.maxValue = 10
ValuedBar.value = 10
ValuedBar.roundDigits = 0

ValuedBar.updateBar = function
	self.bar.setValue self.value/self.maxValue
end function

ValuedBar.updateLabel = function
	text = round(self.value, self.roundDigits) + "/" + round(self.maxValue, self.roundDigits)
	self.label.setText text
end function

ValuedBar.draw = function
	self.updateBar
	self.updateLabel
	self.bar.redraw
	self.label.redraw
end function

ValuedBar.initBarAndLabel = function
	fontDistance = 20
	self.bar = new Bar
	self.bar.init self.left, self.bottom+fontDistance, self.width, self.height-fontDistance
	self.label = new Label
	self.label.init self.left, self.bottom, self.width, fontDistance
end function

ValuedBar.init = function(left, bottom, width, height, maxValue = 10, currentValue = null)
	self.maxValue = maxValue
	if currentValue == null then
		self.value = maxValue
	else 
		self.value = currentValue
	end if
	super.init left, bottom, width, height
	self.initBarAndLabel
end function

ValuedBar.setValue = function(value, maxValue=null)
	if maxValue == null then maxValue = self.maxValue
	if value == self.value and maxValue == self.maxValue then return // (no change)
	qa.assert value >= 0 and value <= self.maxValue
	self.value = value
	self.maxValue = maxValue
	self.updateBar
	self.updateLabel
end function

ValuedBar.setColor = function(color)
	self.bar.color = color
	self.label.color = color
end function

//----------------------------------------------------------------------
// Button: represents a push button.
//----------------------------------------------------------------------
Button = new Widget
Button._name = "Button"
Button.upImg = load9SliceImage("uiButton")
Button.downImg = load9SliceImage("uiButtonDown")
Button.NORMAL = 0
Button.PRESSED = 1
Button.state = Button.NORMAL
Button.enabled = true
Button.caption = "Button"		// may be a string, or a Label
Button.font = "Arial14"
Button.trackingPress = false	// true when tracking a mouse click

Button.init = function(left, bottom, width, height, caption="")
	super.init left, bottom, width, height, caption
	if caption isa string and caption.contains(char(13)) then
		// support multi-line button captions via a Label
		label = new Label
		label.init left, bottom, width, height, caption
		label.wrap
		label.alignment = ALIGNCENTER
		label.font = fonts[self.font]
		label.color = color.black
		self.caption = label
	else
		self.caption = caption
	end if
end function

Button.setEnabled = function(nowEnabled)
	self.enabled = nowEnabled
	self.draw
end function

// action function, invoked upon click (buttons should override this)
Button.action = function			
	print "Button """ + self.name + """ clicked!"
end function

Button.draw = function
	y = self.bounds.y + 1
	if self.state == Button.PRESSED then
		self.downImg.draw self.left, self.bottom, self.width, self.height
		y = y - 2
	else
		if self.enabled then tint = color.white else tint = color.silver
		self.upImg.draw self.left, self.bottom, self.width, self.height, tint
	end if
	if self.caption isa string then
		f = fonts[self.font]
		f.printCentered self.caption, self.bounds.x, y - f.lineHeight * 0.2, 1, 
			color.black * self.enabled + color.gray * (not self.enabled)
	else if self.caption isa Widget then
		self.caption.bounds.x = self.bounds.x
		self.caption.bounds.y = y
		self.caption.draw
	end if
end function

Button.update = function(dt = 0.1)
	if not self.trackingPress then
		// When not tracking a press, the only thing we need to worry
		// about is a mouse-down on this button.
		if mouseDown and self.contains(mouse) and self.enabled then
			// Start tracking!
			self.state = Button.PRESSED
			self.trackingPress = true
			self.redraw
		end if
	else
		// While tracking a press, update based on where the mouse is,
		// until the mouse is released.
		if not mousePressed then
			// Release!
			if self.state == Button.PRESSED then
				self.state = Button.NORMAL
				self.redraw
				self.action
			end if
			self.trackingPress = false
		else
			// show down when mouse in bounds, up when out of bounds
			if self.contains(mouse) then s = Button.PRESSED else s = Button.NORMAL
			if s != self.state then
				self.state = s
				self.redraw
			end if
		end if
	end if
end function

//----------------------------------------------------------------------
// TabButton: Like a button but once pressed stays down
//----------------------------------------------------------------------
TabButton = new Button

TabButton.update = function(dt = 0.1)
	if self.state == Button.NORMAL and mouseDown and self.contains(mouse) then
		self.action
		self.state = Button.PRESSED
		self.redraw
	end if
end function

TabButton.action = function
	print "TabButton: " + self.name + " clicked. State was: " + self.state
end function

//----------------------------------------------------------------------
// LineEdit: Represents a line tall input field
//----------------------------------------------------------------------

LineEdit = new Widget
LineEdit._name = "LineEdit"
LineEdit.font = fonts.ArialBlack14
LineEdit.text = ""
LineEdit.backColor = color.clear
LineEdit.activeBackColor = color.clear
LineEdit.color = color.gray
LineEdit.active = false
LineEdit.pointer = 0
LineEdit.maxTextLength = 0
LineEdit.label = new Label


LineEdit.init = function(left, bottom, width, align=0)
	super.init left, bottom, width, 22
	self.label.init(left+2, bottom+2, width-2, 20, self.text, align)
	self.label.font = self.font
	self.maxTextLength = floor((width-2)/self.font.width("m"))-1
end function

LineEdit.draw = function
	tempColor = disp.uiPixel.color
	if self.active then
		disp.uiPixel.color = self.activeBackColor
	else
		disp.uiPixel.color = self.backColor
	end if
	disp.uiPixel.fillRect self.bounds.x-self.bounds.width/2, self.bounds.y-self.bounds.height/2, self.bounds.width, self.bounds.height
	disp.uiPixel.color = self.color
	disp.uiPixel.fillRect self.bounds.x-self.bounds.width/2, self.bounds.y-self.bounds.height/2, self.bounds.width, 2
	self.label.setText self.text
	self.label.redraw
	disp.uiPixel.color = self.color
	if self.active then
		disp.uiPixel.line self.bounds.x-self.bounds.width/2+self.font.width(self.text[0:self.text.len-self.pointer])+2, self.bounds.y-self.bounds.height/2+4, self.bounds.x-self.bounds.width/2+self.font.width(self.text[0:self.text.len-self.pointer])+2,  self.bounds.y+self.bounds.height/2-4
	end if
	disp.uiPixel.color = tempColor
end function

LineEdit.update = function(dt = 0.1)
	if mouseDown then
		previousActiveState = self.active
		if self.contains(mouse) then
			self.pointer = 0
			self.active = true
		else
			self.active = false
		end if
		if previousActiveState != self.active then 
			key.clear
			self.redraw
		end if
	end if
	if self.active then
		while key.available
			tempKey = key.get
			if tempKey == char(17) and self.pointer < self.text.len then //char(17) = left arrow
				self.pointer = self.pointer + 1
			else if tempKey == char(18) and self.pointer > 0 then //char(18) = right arrow
				self.pointer = self.pointer - 1
			else if tempKey == char(10) then //char(10) = enter
				self.active = false
			else if tempKey == char(8) then //char(8) = backspace
				self.text = self.text[0:self.text.len-1-self.pointer] + self.text[self.text.len-self.pointer:self.text.len]
			else if tempKey >= " " and tempKey < char(127) and self.text.len <= self.maxTextLength then
				self.text = self.text.insert(self.text.len - self.pointer, tempKey)
				self.label.text = self.text
			end if
			self.redraw
		end while
	end if
end function

//----------------------------------------------------------------------
// Main update function: must be called periodically for proper function.
//----------------------------------------------------------------------

mouseWasPressed = false	// whether mouse was pressed on *previous* update

update = function(dt = 0.1)
	// update our handy dandy mouse-state variables: currently pressed, or just up/down
	outer.mousePressed = mouse.button
	outer.mouseDown = mousePressed and not mouseWasPressed
	outer.mouseUp = mouseWasPressed and not mousePressed
	
	for w in _allWidgets
		w.update dt
	end for

	outer.mouseWasPressed = mousePressed
end function

reset = function
	for w in _allWidgets
		w.erase
	end for
	outer._allWidgets = []
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function
	import "systems"
	
	disp.text.clear; disp.text.row = 0
	disp.uiPixel.clear
	disp.uiSprites.clear
	//text.clear; text.row = 0
	
	panel = new Panel
	panel.init 400, 300, 300, 200, "panel"
	panel.draw

	btn = new Button
	btn.init 500, 400, 100, 24, "Click Me"
	btn.backColor = panel.mainColor
	btn.start
	
	lab1 = new Label
	lab1.init 800, 500, 100, 30, "Centered", ALIGNCENTER
	lab1.draw
	
	lab2 = new Label
	lab2.init 800, 530, 100, 20, "Left"
	lab2.draw
	
	lab3 = new Label
	lab3.init 800, 480, 100, 20, "Right", ALIGNRIGHT
	lab3.draw
	
	outer.multiline = new Label
	multiline.init panel.left+4, panel.bottom, panel.width-8, 100,
		"Here is a rather long text, so long in fact that it needs to wrap over " +
		"several lines.  This will turn out to be a very useful thing to do."
	multiline.wrap
	multiline.draw
	
	clock = new Label
	clock.init 900, 620, 60, 20, "Clock", ALIGNRIGHT
	clock.color = color.aqua; clock.backColor = color.black
	clock.text = "0:00"
	clock.start
	clock.update = function(dt)
		t = round(time)
		self.setText floor(t/60) + ":" + ("00" + (t%60))[-2:]
	end function
	
	lineInput = new LineEdit
	lineInput.init 80, 400, 60, 20
	lineInput.start

	bar = new Bar
	bar.init 80, 600, 160, 20
	bar.value = -0.5
	bar.draw

	thinBar = new ThinBar
	thinBar.init 180, 200, 50, 4
	thinBar.value = 0.5
	thinBar.color = color.lime
	thinBar.draw

	valuedBar = new ValuedBar
	valuedBar.init 80, 300, 160, 40
	valuedBar.value = 5
	valuedBar.draw

	horizontalSlider = new HorizontalSlider
	horizontalSlider.init 180, 180, 50, 8
	horizontalSlider.draw
	horizontalSlider.start
	
	fakeSystem = systems.System.makeInvisible()
	fakeSystem.icon = pics.get("systemIcons/reactor")
	energyBar = new PowerControl
	energyBar.init 80, 0, 40, 0
	energyBar.initSystem fakeSystem
	fakeSystem.repairLevel = 2.3
	fakeSystem.curPower = fakeSystem.maxPossiblePower
	energyBar.draw
	energyBar.start

	tabButtons = []

	tabButton1 = new TabButton
	tabButton1.init 400, 500, 98, 24, "Tab Button 1"
	tabButton1.draw
	tabButton1.start

	tabButtons.push tabButton1

	tabButton2 = new TabButton
	tabButton2.init 500, 500, 98, 24, "Tab Button 2"
	tabButton2.draw
	tabButton2.start

	tabButtons.push tabButton2

	tabButton3 = new TabButton
	tabButton3.init 600, 500, 98, 24, "Tab Button 3"
	tabButton3.draw
	tabButton3.start

	tabButtons.push tabButton3

	tabButton1.action = function
		for button in tabButtons
			if button != self then button.state = Button.NORMAL
			button.redraw
		end for
	end function
	tabButton2.action = function
		for button in tabButtons
			if button != self then button.state = Button.NORMAL
			button.redraw
		end for
	end function
	tabButton3.action = function
		for button in tabButtons
			if button != self then button.state = Button.NORMAL
			button.redraw
		end for
	end function

	while not key.pressed("escape")
		update 1/60
		bar.setValue ((bar.value+1.0015)%2) - 1
		thinBar.setValue ((thinBar.value+1.0015)%2) - 1
		yield
	end while
	key.clear
	
end function

runUnitTests = function
	w = new Widget
	w.init 100, 50, 60, 30
	qa.assertEqual w.left, 100
	qa.assertEqual w.bottom, 50
	qa.assertEqual w.right, 160
	qa.assertEqual w.top, 80
	qa.assert w.contains(110, 70)
	qa.assert not w.contains(90, 70)
	qa.assert not w.contains(110, 100)
end function

if locals == globals then
	uiWidgets = locals
	runUnitTests
	demo
end if
