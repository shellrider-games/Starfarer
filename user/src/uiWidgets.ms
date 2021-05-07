// This module implements user interface widgets: dialog boxes, tabs,
// buttons, labels, that sort of thing.
//
// These all draw in the disp.uiPixel layer, except when they need something
// a little more spritey, in which case they may esu disp.uiSprites.

if not globals.hasIndex("disp") then import "setup"
if not globals.hasIndex("qa") then import "qa"

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


//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	
	w = new Widget
	w.init 800, 500, 100, 30
	w.draw

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
