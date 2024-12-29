// This module implements the "Maintenance Bay" screen, in which youu
// can buy, sell, upgrade, and rearrange your ship systems.

import "miscUtil"
ensureImport "setup"
ensureImport "shipModel"

left = 12
right = 960 - left
width = right - left
bottom = 60
top = 640 - 60
height = top - bottom

snapSound = new Sound
snapSound.init 0.025, [8, 1], [1, 0.8, 0], Sound.noiseWave

SystemSprite = new Sprite
SystemSprite.Instances = []
SystemSprite.Make = function(system, x, y)
	globals.wtf = system
	if x == null then 
		x = (system.col * CELLSIZE) + mapZeroZero.x + system.image.width/2
	end if
	if y == null then
		y = (system.row * CELLSIZE) + mapZeroZero.y + system.image.height/2
	end if
	noob = new SystemSprite
	noob.system = system
	noob.image = system.image
	noob.localBounds = new Bounds
	noob.localBounds.width = noob.image.width
	noob.localBounds.height = noob.image.height
	noob.x = x
	noob.y = y
	disp.uiSprites.sprites.push noob
	SystemSprite.Instances.push noob
	return noob
end function

SystemSprite.fitsAt = function(col, row)
	for r in range(row, row + self.system.height - 1)
		for c in range(col, col + self.system.width - 1)
			if not (0 <= r < ship.rows and 0 <= c < ship.columns) then return false
			if ship.map[c][r] == null then return false
		end for
	end for
	return true
end function

SystemSprite.snapToPosition = function
	col = (self.x - mapZeroZero.x - self.image.width/2) / CELLSIZE
	row = (self.y - mapZeroZero.y - self.image.height/2) / CELLSIZE
	icol = round(col)
	irow = round(row)
	if abs(col - icol) > 0.2 or abs(row - irow) > 0.2 then return false
	if self.fitsAt(icol, irow) then
		self.x = round(col) * CELLSIZE + mapZeroZero.x + self.image.width/2
		self.y = round(row) * CELLSIZE + mapZeroZero.y + self.image.height/2
		return true
	end if
	return false
end function

SystemSprite.handleClick = function
	offsetX = self.x - mouse.x
	offsetY = self.y - mouse.y
	self.scale = 1.2
	wasSnapped = true
	while mouse.button
		self.x = mouse.x + offsetX
		self.y = mouse.y + offsetY
		if self.snapToPosition then
			if not wasSnapped then
				snapSound.play
				wasSnapped = true
			end if
		else
			wasSnapped = false
		end if
		yield
	end while
	self.scale = 1
end function

SystemSprite.HandleClick = function
	for spr in SystemSprite.Instances
		if spr.contains(mouse) then return spr.handleClick
	end for
	return false
end function

// We have our own drawShip function here, rather than using
// shipRenderer, because our drawing needs are slightly different.
// Requires mapZeroZero and shipImage (as well as ship) to all be
// set at the global or module level.
drawShip = function
	gfx.drawImage shipImage, 
		mapZeroZero.x - ship.offset[0] * CELLSIZE,
		mapZeroZero.y - ship.offset[1] * CELLSIZE

	// draw floor cells
	for col in ship.columnRange
		x = (col * CELLSIZE) + mapZeroZero.x
		for row in ship.rowRange
			y = (row * CELLSIZE) + mapZeroZero.y
			cell = ship.map[col][row]
			if cell != null then
				cellcolor = "#EEEEEE"
				gfx.fillRect x+1, y+1, CELLSIZE-2, CELLSIZE-2, cellcolor
				gfx.drawRect x, y, CELLSIZE, CELLSIZE, color.white
			end if
		end for
	end for
		
	// draw walls
	for col in ship.columnRange
		x = (col * CELLSIZE) + mapZeroZero.x
		for row in ship.rowRange
			y = (row * CELLSIZE) + mapZeroZero.y
			cell = ship.map[col][row]
			if cell == null then continue
			drawWall cell.walls[SOUTH], x, y, x+CELLSIZE, y
			drawWall cell.walls[WEST], x, y, x, y+CELLSIZE
			drawWall cell.walls[NORTH], x, y+CELLSIZE-1, x+CELLSIZE, y+CELLSIZE-1
			drawWall cell.walls[EAST], x+CELLSIZE-1, y, x+CELLSIZE-1, y+CELLSIZE
		end for
	end for	
end function

drawWall = function(wallOrDoor, x1, y1, x2, y2, c="#6666AA")
	if wallOrDoor == null then return
	if wallOrDoor isa shipModel.Wall then
		gfx.line x1, y1, x2, y2, c, 2
	else
		lerp = @mathUtil.lerp
		gfx.line x1, y1, lerp(x1, x2, 0.4), lerp(y1, y2, 0.4), color.red, 2
		gfx.line lerp(x1, x2, 0.6), lerp(y1, y2, 0.6), x2, y2, color.red, 2
	end if
end function

setup = function
	disp.uiSprites.clear
	
	// draw background and title
	gfx.fillRect left, bottom, width, height, "#444466"
	for x in range(left, right, 104)
		gfx.line x, bottom, x, top, "#666688"
	end for
	for y in range(bottom, top, 104)
		gfx.line left, y, right, y, "#666688"
	end for
	gfx.drawRect left, bottom, width, height, "#AAAAFF"
	
	outer.font = fonts.Arial14
	outer.boldFont = fonts.ArialBlack14
	
	boldFont.printCentered "Maintenance Bay", left+width/2, top-20
	
	// prepare ship map position, and draw the ship
	outer.ship = playerShip
	outer.shipImage = file.loadImage(file.child(ship.directory, "map.png"))
	
	outer.mapZeroZero = {
		"x": 400 - shipImage.width/2 + ship.offset[0] * CELLSIZE,
	    "y": bottom + height/2 - shipImage.height/2 + ship.offset[1] * CELLSIZE }

	drawShip
	
	// place ship systems
	for system in ship.systems
		if system.image == null then
			// invisible systems... what to do?
		else
			SystemSprite.Make system
		end if
	end for
	
end function

mainLoop = function
	while true
		yield
		if mouse.button then
			SystemSprite.HandleClick
		end if
		if key.pressed("escape") then break
	end while
	key.clear
end function

if locals == globals then
	playerShip = shipModel.newShipOfDesign("Robin")
	playerShip.isPlayer = true
	setup
	mainLoop
end if