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

Widget.init = function(left, bottom, width, height, name="")
	self.bounds = new Bounds
	self.bounds.x = left + width/2
	self.bounds.y = bottom + height/2
	self.bounds.width = width
	self.bounds.height = height
	self.name = name
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
	disp.uiPixel.fillRect self.left, self.bottom, self.width, self.height, color.clear
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

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	
	w = new Widget
	w.init 800, 500, 100, 30
	w.draw

	btn = new Button
	btn.init 500, 400, 100, 24, "Button"
	btn.draw
	wait 1
	btn.erase; btn.state = Button.PRESSED; btn.draw
	wait 1
	btn.erase; btn.state = Button.NORMAL; btn.draw
	
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
