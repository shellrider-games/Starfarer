// This module implements user interface widgets: dialog boxes, tabs,
// buttons, labels, that sort of thing.
//
// These all draw in the disp.uiPixel layer, except when they need something
// a little more spritey, in which case they may esu disp.uiSprites.

if not globals.hasIndex("disp") then import "setup"
if not globals.hasIndex("qa") then import "qa"

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
Panel.image = null		// may be an Image or an Image9Slice

Panel.init = function(left, bottom, width, height, name, image)
	super.init left, bottom, width, height, name
	self.image = image
	
	// Get the color of a pixel at the center of the image; this is handy
	// so that things drawing on top of this panel can know what to use
	// for a background color.
	if image isa Image9Slice then src = image.image else src = image
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
Label.ALIGNLEFT = 0
Label.ALIGNCENTER = 1
Label.ALIGNRIGHT = 2
Label.alignment = Label.ALIGNLEFT

Label.init = function(left, bottom, width, height, text="", align=Label.ALIGNLEFT)
	super.init left, bottom, width, height, text
	self.text = text
	self.alignment = align
end function

Label.draw = function()
	w = self.font.width(self.text)
	y = self.bounds.y - 5
	self.font.setColor self.color
	if self.alignment == Label.ALIGNRIGHT then
		self.font.print self.text, self.right - w, y
	else if self.alignment == Label.ALIGNCENTER then
		self.font.print self.text, self.bounds.x - w/2, y
	else
		self.font.print self.text, self.left, y
	end if
end function

Label.setText = function(s)
	if s == self.text then return
	self.text = s
	self.redraw
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
Button.caption = "Button"
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
	y = self.bounds.y - 3
	if self.state == Button.PRESSED then
		self.downImg.draw self.left, self.bottom, self.width, self.height
		y = y - 2
	else
		self.upImg.draw self.left, self.bottom, self.width, self.height
	end if
	f = fonts[self.font]
	f.setColor color.black
	f.printCentered self.caption, self.bounds.x, y
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
				self.action
				self.state = Button.NORMAL
				self.redraw
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

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	
	panel = new Panel
	panel.init 400, 300, 300, 200, "panel", load9SliceImage("panel")
	panel.draw

	btn = new Button
	btn.init 500, 400, 100, 24, "Click Me"
	btn.backColor = panel.mainColor
	btn.start
	
	lab1 = new Label
	lab1.init 800, 500, 100, 30, "Centered", Label.ALIGNCENTER
	lab1.draw
	
	lab2 = new Label
	lab2.init 800, 530, 100, 20, "Left"
	lab2.draw
	
	lab3 = new Label
	lab3.init 800, 480, 100, 20, "Right", Label.ALIGNRIGHT
	lab3.draw
	
	clock = new Label
	clock.init 900, 620, 60, 20, "Clock", Label.ALIGNRIGHT
	clock.color = color.aqua; clock.backColor = color.black
	clock.text = "0:00"
	clock.start
	clock.update = function(dt)
		t = round(time)
		self.setText floor(t/60) + ":" + ("00" + (t%60))[-2:]
	end function
	
	while not key.pressed("escape")
		update 1/60
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
