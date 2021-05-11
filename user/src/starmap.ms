// This module is responsible for drawing and handling user interaction
// with the star (system) map.  This is how you get from place to place
// as you travel around the galaxy.

// The starmap is actually drawn in the ship sprites layer, but scrolled
// over by 10000 pixels.  Yeah, it's a sneaky trick.

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
import "mathUtil"
if not globals.hasIndex("qa") then import "qa"

// constants defining the area for the star map in the display
CENTER = 10000	// (center in both X and Y)
WIDTH = 900		// standard width, when zoomed all the way out
HEIGHT = 600	// same for height

// current zoom factor and scroll (larger numbers mean zooming in more)
zoom = 1

// star images: the first half are normal stars, and the latter half are giants.
starImages = []

// star sprites
starSprites = []

//----------------------------------------------------------------------
// init: initialize this module, loading all stars, etc.
//----------------------------------------------------------------------
init = function()
	// load star images
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

	// create stars
	for i in range(99)
		spr = new Sprite
		spr.mapX = mathUtil.randRange(-WIDTH/2, WIDTH/2)
		spr.mapY = mathUtil.randRange(-HEIGHT/2, HEIGHT/2)
		imgNum = mathUtil.randRange(0, starImages.len)
		if imgNum < starImages.len/2 then
			spr.mapScale = mathUtil.randRange(0.125, 0.25)
			// small stars can be any color
			colorNum = floor(mathUtil.randRange(0, 4))
		else
			spr.mapScale = mathUtil.randRange(0.25, 0.5)
			// big stars can only be blue or red
			// small stars can be any color
			colorNum = floor(mathUtil.randRange(0, 2))
		end if
		spr.image = starImages[imgNum]
		if colorNum == 0 then spr.tint = "#AAAAFF"
		if colorNum == 1 then spr.tint = "#FF8888"
		if colorNum == 2 then spr.tint = "#FFFF88"
		starSprites.push spr
	end for
end function

//----------------------------------------------------------------------
// draw: present the map on the screen
//----------------------------------------------------------------------
draw = function()
	updateForZoom
	disp.shipSprites.scrollX = CENTER - WIDTH/2
	disp.shipSprites.scrollY = CENTER - HEIGHT/2
	for spr in starSprites
		disp.shipSprites.sprites.push spr
	end for
end function

updateForZoom = function()
	for spr in starSprites
		spr.x = CENTER + spr.mapX * zoom
		spr.y = CENTER + spr.mapY * zoom
		spr.scale = spr.mapScale * zoom
	end for
end function

//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	//text.clear

	draw

	while not key.pressed("escape")
		scrollInp = key.axis("Mouse ScrollWheel")
		if scrollInp != 0 then
			outer.zoom = mathUtil.clamp(outer.zoom + scrollInp, 0.1, 10)
			updateForZoom
		end if
		if mouse.button then
			// drag the map around
			startPos = {} + mouse
			startScroll = {"x":disp.shipSprites.scrollX, "y":disp.shipSprites.scrollY}
			while mouse.button
				dx = mouse.x - startPos.x
				dy = mouse.y - startPos.y
				disp.shipSprites.scrollX = startScroll.x - dx
				disp.shipSprites.scrollY = startScroll.y - dy
				yield
			end while
		end if
		yield
	end while
	key.clear
	
end function

init
if locals == globals then
	demo
end if
