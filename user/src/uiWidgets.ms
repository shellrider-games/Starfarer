// This module implements user interface widgets: dialog boxes, tabs,
// buttons, labels, that sort of thing.
//
// These all draw in the disp.uiPixel layer, except when they need something
// a little more spritey, in which case they may esu disp.uiSprites.

if not globals.hasIndex("disp") then import "setup"
if not globals.hasIndex("qa") then import "qa"
import "stringUtil"
import "listUtil"

//----------------------------------------------------------------------
// Constants
//----------------------------------------------------------------------

ALIGNLEFT = 0
ALIGNCENTER = 1
ALIGNRIGHT = 2

//----------------------------------------------------------------------
// General utility methods
//----------------------------------------------------------------------

loadImage = function(name)
	path = "/usr/pics/" + name + ".png"
	img = file.loadImage(path)
	if img == null then qa.abort("Image not found: " + path)
	return img
end function

load9SliceImage = function(name, left=12, bottom=12, right=12, top=12)
	img = loadImage(name)
	return Image9Slice.make(img, left, bottom, right, top)
end function

// clearAll: clear all widgets (and the entire uiPixel display).
clearAll = function()
	disp.uiPixel.clear color.clear
	outer._allWidgets = []
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

Image9Slice.draw = function(left, bottom, width, height)
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
		0, 0, self.leftMargin, self.bottomMargin
	disp.uiPixel.drawImage self.image, 
		left, bottom + self.bottomMargin, self.leftMargin, midH,
		0, self.bottomMargin, self.leftMargin, srcH
	disp.uiPixel.drawImage self.image, 
		left, nearTop, self.leftMargin, self.topMargin,
		0, srcNearTop, self.leftMargin, self.topMargin
	
	// center section (bottom, middle, top)
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, bottom, midW, self.bottomMargin,
		self.leftMargin, 0, srcW, self.bottomMargin
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, bottom + self.bottomMargin, midW, midH,
		self.leftMargin, self.bottomMargin, srcW, srcH
	disp.uiPixel.drawImage self.image, 
		left + self.leftMargin, nearTop, midW, self.topMargin,
		self.leftMargin, srcNearTop, srcW, self.topMargin
	
	// right section (bottom, middle, top)
	disp.uiPixel.drawImage self.image, 
		nearRight, bottom, self.rightMargin, self.bottomMargin,
		srcNearRight, 0, self.rightMargin, self.bottomMargin
	disp.uiPixel.drawImage self.image, 
		nearRight, bottom + self.bottomMargin, self.rightMargin, midH,
		srcNearRight, self.bottomMargin, self.rightMargin, srcH
	disp.uiPixel.drawImage self.image, 
		nearRight, nearTop, self.rightMargin, self.topMargin,
		srcNearRight, srcNearTop, self.rightMargin, self.topMargin	
end function

//----------------------------------------------------------------------
// Widget base class: represents a axis-aligned rectangular area of the
// screen that knows how to draw itself and respond to events.
//----------------------------------------------------------------------
Widget = {}
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

Widget.start = function()
	if _allWidgets.indexOf(self) == null then _allWidgets.push self
	self.draw
end function

Widget.stop = function()
	_allWidgets.removeVal self
	self.erase
end function

Widget.update = function(dt = 0.1)
	// (overridden in most subclasses)
end function

Widget.left = function()
	return self.bounds.x - self.bounds.width/2
end function

Widget.right = function()
	return self.bounds.x + self.bounds.width/2
end function

Widget.bottom = function()
	return self.bounds.y - self.bounds.height/2
end function

Widget.top = function()
	return self.bounds.y + self.bounds.height/2
end function

Widget.width = function()
	return self.bounds.width
end function

Widget.height = function()
	return self.bounds.height
end function

Widget.contains = function(x,y)
	return self.bounds.contains(x,y)
end function

Widget.draw = function()
	disp.uiPixel.fillRect self.left, self.bottom, self.width, self.height, color.fuchsia
end function

Widget.erase = function()
	disp.uiPixel.fillRect self.left, self.bottom, self.width, self.height, self.backColor
end function

Widget.redraw = function()
	self.erase
	self.draw
end function

//----------------------------------------------------------------------
// Panel: a widget that draws an Image or Image9Slice.
//----------------------------------------------------------------------
Panel = new Widget
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

Panel.draw = function()
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
Label.text = "Label"
Label.color = color.gray
Label.font = fonts.ArialBlack14
Label.alignment = ALIGNLEFT
Label.leading = 2  // (extra space between lines, in multiline label)

Label.init = function(left, bottom, width, height, text="", align=ALIGNLEFT)
	super.init left, bottom, width, height, text
	self.text = text
	self.alignment = align
end function

Label.wrap = function(wrapWidth=null)
	// Split our text into lines.
	if wrapWidth == null then wrapWidth = self.bounds.width
	self.lines = []
	s = self.text
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
	// Then increase height if needed
	h = self.lines.len * (self.font.lineHeight + self.leading)
	if h > self.bounds.height then self.bounds.height = h
end function

Label.draw = function()
	self.font.setColor self.color
	if self.hasIndex("lines") then data = self.lines else data = [self.text]
	y = self.bounds.y + 1 - self.font.sizeInner/2 + (data.len/2 - 1) * (self.font.lineHeight + self.leading)
	for line in data
		if self.alignment == ALIGNRIGHT then
			w = self.font.width(line)
			self.font.print line, self.right - w, y
		else if self.alignment == ALIGNCENTER then
			w = self.font.width(line)
			self.font.print line, self.bounds.x - w/2, y
		else
			self.font.print line, self.left, y
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


//----------------------------------------------------------------------
// Bar: a simple bar that has a value between 0 and 1 and is filled that much.
// Or, give it a value between -1 and 0, and it will fill from the right.
//----------------------------------------------------------------------

Bar = new Widget
Bar.color = color.gray
Bar.value = 0.5

Bar.draw = function()
	left = self.bounds.x - self.bounds.width/2 + 1
	bottom = self.bounds.y - self.bounds.height/2 + 1
	width = self.bounds.width - 2
	height = self.bounds.height - 2
	right = left + width
	
	// border
	disp.uiPixel.drawRect left, bottom, width, height, self.color, 2

	// inset border
	disp.uiPixel.drawRect left+2, bottom+2, width-4, height-4, color.clear, 2
	
	// fill
	if self.value >= 0 then
		divx = left+3 + round((width-6) * self.value)
		disp.uiPixel.fillRect left+3, bottom+3, divx - (left+3), height-6, self.color
		disp.uiPixel.fillRect divx, bottom+3, right-3 - divx, height-6, color.clear
	else
		divx = right-3 + round((width-6) * self.value)
		disp.uiPixel.fillRect left+3, bottom+3, divx - (left+3), height-6, color.clear
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
// ValuedBar: Combines a Bar with a label showing current/max.
//----------------------------------------------------------------------

ValuedBar = new Widget
ValuedBar.bar = new Bar
ValuedBar.label = new Label
ValuedBar.maxValue = 10
ValuedBar.value = 10

ValuedBar.updateBar = function()
	self.bar.setValue self.value/self.maxValue
end function

ValuedBar.updateLabel = function()
	text = ""+self.value+"/"+self.maxValue
	self.label.setText text
end function

ValuedBar.draw = function()
	self.updateBar
	self.updateLabel
	self.bar.redraw
	self.label.redraw
end function

ValuedBar.initBarAndLabel = function()
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



//----------------------------------------------------------------------
// Button: represents a push button.
//----------------------------------------------------------------------
Button = new Widget
Button.upImg = load9SliceImage("uiButton")
Button.downImg = load9SliceImage("uiButtonDown")
Button.NORMAL = 0
Button.PRESSED = 1
Button.state = Button.NORMAL
Button.caption = "Button"		// may be a string, or a Label
Button.font = "Arial14"
Button.trackingPress = false	// true when tracking a mouse click

Button.init = function(left, bottom, width, height, caption="")
	super.init left, bottom, width, height, caption
	self.caption = caption
end function

// action function, invoked upon click (buttons should override this)
Button.action = function()			
	print "Button """ + self.name + """ clicked!"
end function

Button.draw = function()
	y = self.bounds.y + 1
	if self.state == Button.PRESSED then
		self.downImg.draw self.left, self.bottom, self.width, self.height
		y = y - 2
	else
		self.upImg.draw self.left, self.bottom, self.width, self.height
	end if
	if self.caption isa string then
		f = fonts[self.font]
		f.setColor color.black
		f.printCentered self.caption, self.bounds.x, y - f.lineHeight * 0.2
	else
		self.caption.bounds.x = self.bounds.x
		self.caption.bounds.y = y
		self.caption.draw
	end if
end function

Button.update = function(dt = 0.1)
	if not self.trackingPress then
		// When not tracking a press, the only thing we need to worry
		// about is a mouse-down on this button.
		if mouseDown and self.contains(mouse) then
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
// LineEdit: Represents a line tall input field
//----------------------------------------------------------------------

LineEdit = new Widget
LineEdit.font = fonts.ArialBlack14
LineEdit.text = ""
LineEdit.backColor = color.clear
LineEdit.activeBackColor = color.clear
LineEdit.color = color.gray
LineEdit.active = false
LineEdit.pointer = 0
LineEdit.maxTextLength = 0
LineEdit.label = new Label


LineEdit.init = function(left, bottom, width, align=ALIGNLEFT)
	super.init left, bottom, width, 22
	self.label.init(left+2, bottom+2, width-2, 20, self.text, align)
	self.label.font = self.font
	self.maxTextLength = floor((width-2)/self.font.width("m"))-1
end function

LineEdit.draw = function()
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

reset = function()
	for w in _allWidgets
		w.erase
	end for
	outer._allWidgets = []
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	
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

	valuedBar = new ValuedBar
	valuedBar.init 80, 400, 160, 40
	valuedBar.value = 5
	valuedBar.draw
	
	while not key.pressed("escape")
		update 1/60
		bar.setValue ((bar.value+1.0015)%2) - 1
		valuedBar.value = valuedBar.value % 11
		yield
	end while
	key.clear
	
end function

runUnitTests = function()
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
