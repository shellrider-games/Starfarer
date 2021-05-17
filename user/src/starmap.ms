// This module is responsible for drawing and handling user interaction
// with the star (system) map.  This is how you get from place to place
// as you travel around the galaxy.

import "listUtil"
import "mathUtil"
if not globals.hasIndex("setup") then import "setup"
if not globals.hasIndex("stationModel") then import "stationModel"
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("qa") then import "qa"

// constants defining the area for the star map in the display
CENTER = 10000	// (center in both X and Y)
WIDTH = 900		// standard width, when zoomed all the way out
HEIGHT = 600	// same for height

// current zoom factor and scroll (larger numbers mean zooming in more)
zoom = 1

// star images: a 2D array corresponding to stars in our starSheet,
// indexed by column (left-right) and row (bottom-top).  Row 0 is
// all red stars; row 1 is yellow stars; row 2 is white and blue stars.
// The first 4 columns are normal or dwarf stars; the last 4 are giants.
starImages = null


//----------------------------------------------------------------------
// init: initialize this module, loading all stars, etc.
//----------------------------------------------------------------------
init = function()
	// load star images
	sheet = file.loadImage("/usr/pics/stars/starSheet.png")
	qa.assert sheet != null
	outer.starImages = list.init2d(8,3)
	for col in range(0,7)
		for row in range(0,2)
			img = sheet.getImage(col*32, row*32, 32, 32)
			starImages[col][row] = img
		end for
	end for
//
//	create stars
//	for i in range(99)
//		spr = new Sprite
//		spr.mapX = mathUtil.randRange(-WIDTH/2, WIDTH/2)
//		spr.mapY = mathUtil.randRange(-HEIGHT/2, HEIGHT/2)
//		imgNum = mathUtil.randRange(0, starImages.len)
//		if imgNum < starImages.len/2 then
//			spr.mapScale = mathUtil.randRange(0.125, 0.25)
//			small stars can be any color
//			colorNum = floor(mathUtil.randRange(0, 4))
//		else
//			spr.mapScale = mathUtil.randRange(0.25, 0.5)
//			big stars can only be blue or red
//			small stars can be any color
//			colorNum = floor(mathUtil.randRange(0, 2))
//		end if
//		spr.image = starImages[imgNum]
//		if colorNum == 0 then spr.tint = "#AAAAFF"
//		if colorNum == 1 then spr.tint = "#FF8888"
//		if colorNum == 2 then spr.tint = "#FFFF88"
//		starSprites.push spr
//	end for
end function

//----------------------------------------------------------------------
// draw: present the map on the screen
//----------------------------------------------------------------------
draw = function(stationList)
	// setup
	uiWidgets.clearAll
	gfx.fillRect 0, 40, 960, 560, color.black
	
	// draw stars (stations)
	f = fonts.Arial14
	f.setColor color.white
	for station in stationList
		r = 16 * station.starSize
		gfx.drawImage starImages[station.starTypeCol][station.starTypeRow],
				station.x-r, station.y-r, r*2, r*2
		f.printCentered station.name, station.x, station.y - 20
	end for
	
	// warp (jump) button
	outer.jumpBtn = new uiWidgets.Button
	jumpBtn.init 900, 610, 60, 30, "JUMP"
	jumpBtn.backColor = color.black
	jumpBtn.start
end function

hide = function()
	uiWidgets.clearAll
	gfx.clear color.clear
end function

update = function(dt = 0.1)
	// ToDo: watch for clicking on a valid station.
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	outer.stations = stationModel.manyRandomStations(30)
	draw stations

	while not key.pressed("escape")
		update 0.1
		yield
	end while
	key.clear
	
end function

init
if locals == globals then
	demo
end if
