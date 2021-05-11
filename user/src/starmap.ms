// This module is responsible for drawing and handling user interaction
// with the star (system) map.  This is how you get from place to place
// as you travel around the galaxy.

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
import "mathUtil"
if not globals.hasIndex("qa") then import "qa"

// constants defining the area for the star map on the screen
LEFT = 0
RIGHT = 960
BOTTOM = 60
TOP = 580
WIDTH = RIGHT - LEFT
HEIGHT = TOP - BOTTOM

// star images: the first half are normal stars, and the latter half are giants.
starImages = []

//----------------------------------------------------------------------
// init: initialize this module, loading all stars, etc.
//----------------------------------------------------------------------
init = function()
	for i in range(1, 4)
		name = "star_white0" + i + ".png"
		img = file.loadImage("/usr/pics/stars/" + name)
		qa.assert img != null, "Unable to load star image " + name
		starImages.push img
	end for
	for i in range(1, 4)
		name = "star_white_giant0" + i + ".png"
		img = file.loadImage("/usr/pics/stars/" + name)
		qa.assert img != null, "Unable to load star image " + name
		starImages.push img
	end for
end function

//----------------------------------------------------------------------
// draw: present the map on the screen
//----------------------------------------------------------------------
draw = function()
	gfx.fillRect LEFT, BOTTOM, WIDTH, HEIGHT, color.black
	gfx.drawRect LEFT, BOTTOM, WIDTH, HEIGHT, color.yellow

	for i in range(99)
		x = mathUtil.randRange(LEFT+30, RIGHT-30)
		y = mathUtil.randRange(BOTTOM+30, TOP-30)
		imgNum = mathUtil.randRange(0, starImages.len)
		if imgNum < starImages.len/2 then
			scale = mathUtil.randRange(0.125, 0.25)
		else
			scale = mathUtil.randRange(0.25, 0.5)
		end if
		img = starImages[imgNum]
		size = img.width * scale
		gfx.drawImage starImages[imgNum],
			x - size/2, y - size/2, size, size,
			0, 0, img.width, img.height
	end for
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	text.clear

	draw

	while not key.pressed("escape")
		yield
	end while
	key.clear
	
end function

init
if locals == globals then
	demo
end if
