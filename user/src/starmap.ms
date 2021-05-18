// This module is responsible for drawing and handling user interaction
// with the star (system) map.  This is how you get from place to place
// as you travel around the galaxy.

import "listUtil"
import "mathUtil"
if not globals.hasIndex("setup") then import "setup"
if not globals.hasIndex("stationModel") then import "stationModel"
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("effects") then import "effects"

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

// jump callback: set this to a function(station) to be invoked
// when the player indicates they want to jump to a given station.
jumpCallback = null

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
	
	// prepare star selection sprite
	outer.selectionSprite = new Sprite
	selectionSprite.image = file.loadImage("/usr/pics/starCursor.png")
	
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
draw = function(stationList, curStation=null, jumpLimit=200)
	// setup
	uiWidgets.clearAll
	gfx.fillRect 0, 40, 960, 560, color.black
	outer.stations = stationList
	outer.curStation = curStation
	outer.jumpLimit = jumpLimit
	
	// draw lines from the current station to all reachable stations
	if curStation != null then
		for station in stationList
			if station == curStation then continue
			dist = mathUtil.distance(station, curStation)
			if dist < jumpLimit then
				gfx.line station.x, station.y, curStation.x, curStation.y, 
				  "#666666", 3
			end if
		end for
	end if
	
	// draw stars (stations)
	f = fonts.Arial14
	f.setColor color.white
	for station in stationList
		r = 16 * station.starSize
		gfx.drawImage starImages[station.starTypeCol][station.starTypeRow],
				station.x-r, station.y-r, r*2, r*2
		f.printCentered station.name, station.x, station.y - 20
	end for
	
	// selection sprite
	disp.uiSprites.sprites.push selectionSprite
	
	// cancel (back) button
	outer.backBtn = new uiWidgets.Button
	backBtn.init 900, 610, 60, 30, "BACK"
	backBtn.backColor = color.black
	backBtn.start
end function

hide = function()
	uiWidgets.clearAll
	disp.uiSprites.sprites.removeVal selectionSprite
	gfx.clear color.clear
end function

update = function(dt = 0.1)
	// Find the station the mouse is over
	closest = stationModel.closestStation(mouse, stations)
	if closest != null and mathUtil.distance(closest, mouse) > 32 then closest = null
	
	// Update the selection cursor
	canJump = false
	if closest == null then
		selectionSprite.tint = color.clear
	else
		jumpDist = mathUtil.distance(closest, curStation)
		selectionSprite.x = closest.x
		selectionSprite.y = closest.y
		if closest == curStation then
			selectionSprite.tint = color.blue
			canJump = true
		else if jumpDist < jumpLimit then
			selectionSprite.tint = "#00CC00"
			canJump = true
		else
			selectionSprite.tint = "#880000"
		end if
	end if
	
	// if mouse goes down, track until up, then handle accordingly
	if mouse.button then
		if not canJump then
			while mouse.button; yield; end while
		else
			normalColor = selectionSprite.tint
			while mouse.button
				if mathUtil.distance(closest, mouse) > 32 then
					selectionSprite.tint = normalColor
				else
					selectionSprite.tint = color.lerp(normalColor, color.gray, 0.5)
				end if
				yield
			end while
			if selectionSprite.tint != normalColor then
				// Jump!
				if @jumpCallback != null then 
					jumpCallback(closest)
				end if
			end if
		end if
	end if
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	outer.stations = stationModel.manyRandomStations(30)
	draw stations, stations[0]

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
