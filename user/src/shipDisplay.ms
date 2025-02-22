// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

import "miscUtil"
ensureImport "mathUtil"
ensureImport "setup"
ensureImport "listUtil"
ensureImport "qa"
ensureImport "spriteUtil"
ensureImport "spriteControllers"
ensureImport "door"
ensureImport "item"
ensureImport "constants"
ensureImport "pics"

BROKEN_CELL_IMAGE = pics.get("brokenCell")
SHIELD_GLOW_IMAGE = pics.get("shieldGlow")

init = function()
	// clear the sprite display, and load the ship background
	disp.shipSprites.clear
end function

// global list of current renderers (usually no more than 2)
renderers = []

// Renderer: a class that exists to render a ship onto the display.  We may
// have multiple ships on screen at some point; each will get its own Renderer.
Renderer = {}
Renderer.ship = null		// the shipModel we are rendering
Renderer.x = 240			// horizontal center of the ship on screen
Renderer.y = 320			// vertical center of the ship on screen
Renderer.sprites = null		// sprites owned by this particular renderer
Renderer.shields = null		// sprite representing the energy shield barrier (if any)
Renderer.shieldSystem = null	// systems.System producing the shields

// renderShip: load the given ship model onto the display.
Renderer.renderShip = function(ship)
	// Keep track of this renderer for future reference.
	renderers.push self

	// Store our ship model.
	self.ship = ship
	
	// load the ship map, and calculate our graphics offset
	shipImage = file.loadImage(file.child(ship.directory, "map.png"))
	self.shipSprite = self.addSprite(shipImage, self.x, self.y)
	self.mapZeroZero = {
		"x": self.x - shipImage.width/2 + ship.offset[0] * CELLSIZE,
	    "y": self.y - shipImage.height/2 + ship.offset[1] * CELLSIZE }

	// load ship systems
	self.renderShipSystems
	
	// load the doors and any items (ship contents)
	for row in ship.rowRange
		for col in ship.columnRange
			self.renderDoors ship.map[col][row]
			self.renderContents ship.map[col][row]
		end for
	end for
	
	// load the minions
	for m in ship.minions
		self.renderMinion m
	end for
	
	// if this is NOT the player ship, then show any target locations
	if ship != playerShip then self.renderTargets

end function

// addSprite: Helper method to create and add a sprite from an image.
// Also keeps it in our own sprite list so we can clean up in close().
Renderer.addSprite = function(image, x, y, baseClass)
	if baseClass == null then baseClass = Sprite
	if image isa string then image = file.loadImage(image)
	qa.assert image != null, "invalid image in shipDisplay.addSprite"
	sp = {}
	sp.__isa = baseClass
	sp.image = image
	sp.x = x
	sp.y = y
	if baseClass == Sprite then
		// Make sure every sprite has an "update" function,
		// even if it does nothing.
		sp.update = function(dt); end function
	end if
	disp.shipSprites.sprites.push sp
	if self.sprites == null then self.sprites = []
	self.sprites.push sp
	return sp
end function

Renderer.renderMinion = function(minion)
	pos = self.mapToScreenPosition(minion)
	minion.x = pos.x; minion.y = pos.y
	minion.reticle.x = pos.x; minion.reticle.y = pos.y;
	disp.shipSprites.sprites.removeVal minion
	disp.shipSprites.sprites.removeVal minion.reticle
	disp.shipSprites.sprites.push minion
	disp.shipSprites.sprites.push minion.reticle
	self.sprites.push minion
	self.sprites.push minion.reticle
end function

Renderer.placeDoor = function(door, cell, direction)
	pos = self.mapToScreenPosition(cell)
	door.x = pos.x + CELLSIZE/2 * ((direction == EAST) - (direction == WEST))
	door.y = pos.y + CELLSIZE/2 * ((direction == NORTH) - (direction == SOUTH))
	door.rotation = 90 * (direction == NORTH or direction == SOUTH)
	
	// Accommodate for door image width/heights. 
	//TODO: Get door image width/height and use those instead of these magic numbers.
	if direction == NORTH or direction == SOUTH then 
		door.x = door.x + 0.5
		door.y = door.y + 1
	else
		door.x = door.x + 1.3
		door.y = door.y + 0.5
	end if

	if disp.shipSprites.sprites.indexOf(door) == null then
		disp.shipSprites.sprites.push door
		self.sprites.push door
	end if
end function

// renderDoors: load the doors of the given cell to our display.
Renderer.renderDoors = function(cell)
	if cell == null then return
	for dir in range(0,3)
		if cell.walls[dir] isa Door then
			self.placeDoor cell.walls[dir], cell, dir
		end if
	end for
end function

// renderContents: render the contents of the given cell to our display.
// That generally means creating or placing sprites for items.
Renderer.renderContents = function(cell)
	if cell == null or cell.contents == null then return
	item = cell.contents
	disp.shipSprites.sprites.removeVal item
	pos = self.mapToScreenPosition(cell)
	item.x = pos.x; item.y = pos.y
	disp.shipSprites.sprites.push item
	self.sprites.push item
end function

// removeCellContents: remove the sprite for the item in the given
// cell, and also clear it from the cell.  Return the item.
Renderer.removeCellContents = function(cell)
	if cell == null or cell.contents == null then return null
	item = cell.contents
	disp.shipSprites.sprites.removeVal item
	cell.contents = null
	return item
end function

TargetSprite = new Sprite
TargetSprite.update = function(dt); end function
TargetSprite.srcImage = pics.get("reticles")
TargetSprite.scale = 0.75
TargetSprite.tint = color.red
TargetSprite.images = []
for i in range(0,3)
	TargetSprite.images.push TargetSprite.srcImage.getImage(i*40,0,40,40)
end for

// renderTargets: add the little targeting reticle icons indicating where
// on this ship is being targeted by the other ship's weapons.
Renderer.renderTargets = function()
	// start by removing any previous target sprites
	count = 0
	for i in range(self.sprites.len-1, 0)
		if self.sprites[i] isa TargetSprite then
			disp.shipSprites.sprites.removeVal self.sprites[i]
			self.sprites.remove i
			count = count + 1
		end if
	end for
	// and then add target sprites for our targets
	for i in self.ship.targetSpots.indexes
		pos = self.mapToScreenPosition(self.ship.targetSpots[i])
		self.addSprite TargetSprite.images[i], pos.x, pos.y, TargetSprite
	end for
end function

Renderer.screenToMapPosition = function(point)
	if point isa map then
		x = point.x
		y = point.y
	else
		x = point[0]
		y = point[1]
	end if	
	mapStartPoint = self.mapZeroZero
	return {"col": floor((x - mapStartPoint.x)/CELLSIZE), 
	        "row": floor((y - mapStartPoint.y)/CELLSIZE)}
end function

Renderer.mapToScreenPosition = function(point)
	if point isa map then
		x = point.col
		y = point.row
	else
		x = point[0]
		y = point[1]
	end if
	mapStartPoint = self.mapZeroZero
	return {"x": mapStartPoint.x + x*CELLSIZE + CELLSIZE/2, 
	        "y": mapStartPoint.y + y*CELLSIZE + CELLSIZE/2}
end function

Renderer.putItem = function(item, mapPos)
	targetCell = self.ship.getCell(mapPos.col, mapPos.row)
	if targetCell == null then return	// out of bounds
	if targetCell.contents != null then return;	// already occupied
	for col in self.ship.columnRange
		for row in self.ship.rowRange
			cell = self.ship.getCell(col,row)
			if cell != null and cell.contents == item then 
				cell.contents = null
			end if
		end for
	end for
	targetCell.contents = item
	self.renderContents targetCell
end function

Renderer.breakCell = function(mapPos)
	targetCell = self.ship.getCell(mapPos.col, mapPos.row)
	if targetCell == null then return	// out of bounds
	if targetCell.broken then return	// already broken
	targetCell.damage
	self.renderBroken mapPos
end function

Renderer.removeBroken = function(mapPos)
	for sprite in self.sprites
		if sprite.image == BROKEN_CELL_IMAGE and sprite.col == mapPos.col and sprite.row == mapPos.row then
			disp.shipSprites.sprites.remove(disp.shipSprites.sprites.indexOf(sprite))
			self.sprites.remove(self.sprites.indexOf(sprite))
		end if
	end for
end function

Renderer.renderBroken = function(mapPos)
	pos = self.mapToScreenPosition(mapPos)
	brokenSprite = new Sprite
	brokenSprite.image = BROKEN_CELL_IMAGE
	brokenSprite.col = mapPos.col
	brokenSprite.row = mapPos.row
	brokenSprite.x = pos.x
	brokenSprite.y = pos.y
	brokenSprite.rotation = mathUtil.randRange(0, 360)
	brokenSprite.update = function(dt = 0.1); end function

	// insert the break into the sprite lists right after the ship itself
	disp.shipSprites.sprites.insertAfter self.shipSprite, brokenSprite
	self.sprites.insertAfter self.shipSprite, brokenSprite
end function

Renderer.renderShipSystems = function()
	for system in self.ship.systems
		if system.width and system.height then
			// create a representation of the system on the ship map
			width = CELLSIZE * system.width
			height = CELLSIZE * system.height
			xy = self.mapToScreenPosition(system)
			sp = self.addSprite(system.image, xy.x + width/2 - CELLSIZE/2, 
				xy.y + height/2 - CELLSIZE/2)
			sp.scale = width / system.image.width
			
			if system isa systems.Shields then
				// create the sprite that represents the shield barrier itself
				self.shields = self.addSprite(SHIELD_GLOW_IMAGE, self.x, self.y)
				self.shields.scale = [self.ship.columns/6, self.ship.rows/6]
				// and remember the system so we can efficiently update later
				self.shieldSystem = system
				self.updateShields
			end if
		end if
	end for
end function

Renderer.updateShields = function()
	if self.shieldSystem == null then return
	layers = floor(self.shieldSystem.curLayers)
	if layers == 0 then
		newTint = color.clear
	else if layers == 1 then
		newTint = "#FFCCCC"
	else if layers == 2 then
		newTint = "#FFFFCC"
	else
		newTint = "#CCFFFF"
	end if
	if newTint != self.shields.tint then
		self.shields.tint = newTint
		if layers > 0 then sounds.shieldUp.playAt self.x
	end if
end function

Renderer.renderAirValues = function()
	if self.ship.airChanged then
		disp.shipOverlays.fillRect self.mapZeroZero.x, self.mapZeroZero.y, self.ship.columns*CELLSIZE, self.ship.rows*CELLSIZE, color.clear
		for col in range(0, self.ship.columns-1)
			for row in range(0, self.ship.rows-1)
				cell = self.ship.getCell(col, row)
				if cell != null then
					disp.shipOverlays.fillRect self.mapZeroZero.x + col*CELLSIZE, self.mapZeroZero.y + row*CELLSIZE, CELLSIZE, CELLSIZE, color.rgba(255, 0, 0, (1-cell.air/100)*128)
				end if
			end for
		end for
		self.ship.airChanged = false
	end if
end function

Renderer.updateSelectionReticles = function()
	for minion in self.ship.minions
		if game.selectedMinion.contains(minion) then
			minion.reticle.tint = color.lime
		else
			minion.reticle.tint = color.clear
		end if
	end for
end function

Renderer.stop = function()
	// Tear down everything we set up for this renderer.
	for sp in self.sprites
		disp.shipSprites.sprites.removeVal sp
	end for
	self.sprites = null
	self.shields = null
	self.shieldSystem = null
	self.ship = null
	renderers.removeVal self
end function

// Update just this one ship renderer.  Here we check for cargo bought/sold, etc.
Renderer.update = function(dt = 0.1)
	// check for new incoming types that need to be loaded onto the ship
	if self.ship.incomingTypes then
		// We have some incoming type -- looks like the player has bought
		// something.  Look for an empty CARGO_IN cell to place it in.
		cell = self.ship.getAnyFreeCargoInCell
		if cell != null then
			itemType = new self.ship.incomingTypes.pull
			cell.placeItem itemType
			game.money -= game.station.getCommodityBuyPrice(itemType)
			self.renderContents cell
			cell.contents.fadeIn
		end if
	end if

	// check for outgoing types that are now satisfied
	for cell in self.ship.getCargoOutCells
		if cell.contents == null or cell.contents.lerper then continue
		item = cell.contents
		itemType = item.__isa
		idx = self.ship.outgoingTypes.indexOf(itemType)
		if idx != null then
			game.money += game.station.getCommoditySellPrice(itemType)
			self.ship.outgoingTypes.remove idx
			cell.contents = null
			item.fadeOut 16, 0
		end if
	end for
	
	self.updateShields
	self.renderAirValues
end function

// Update the whole ship display (and all sprites on it).
update = function(dt = 0.1)
	// update all renderers
	for rend in renderers
		rend.update dt
	end for
	
	// update all sprites in the shipSprites layer on the screen
	for s in disp.shipSprites.sprites
		s.update dt
	end for
end function

// demo: test/demonstrate this module on its own.
demo = function()	
	ensureImport "systems"
	ensureImport "shipModel"
	globals.shipModel = shipModel
	globals.shipDisplay = {}
	shipDisplay.Renderer = Renderer
	shipDisplay.renderers = renderers
	currentDirectory = pwd
	cd "/usr/ships/robin"
	import "shipData"
	cd currentDirectory
	ship = shipData.ship
	globals.playerShip = ship
	rend = new Renderer
	rend.renderShip ship

	ensureImport "character"
	crewmember = new character.Character
	crewmember.setScreenPos rend.mapToScreenPosition([4,6])
	crewmember.boardShip ship
	disp.shipSprites.sprites.push crewmember

	pt = {}
	pt.col = 0
	pt.row = 0
	rend.breakCell pt

	while not key.pressed("escape")
		if mouse.button then
			text.clear
			print ship.getCell(rend.screenToMapPosition(mouse).col,rend.screenToMapPosition(mouse).row)
			wait 0.25
		end if
		if mouse.button(1) then
			crate = new item.FoodItem
			rend.putItem crate, rend.screenToMapPosition(mouse)
		end if
		crewmember.update
		update
		ship.update
		yield
	end while
	key.clear
end function

runUnitTests = function()
	testRenderer = new Renderer
	testRenderer.mapZeroZero = {"x":testRenderer.x,"y":testRenderer.y}
	qa.assertEqual testRenderer.mapZeroZero, {"x": 240, "y": 320}
	qa.assertEqual testRenderer.screenToMapPosition([240,320]), {"col":0,"row":0}
	qa.assertEqual testRenderer.screenToMapPosition([240-globals.CELLSIZE,320]), {"col":-1,"row":0}
	qa.assertEqual testRenderer.screenToMapPosition([240-globals.CELLSIZE,320-globals.CELLSIZE]), {"col":-1,"row":-1}
	qa.assertEqual testRenderer.screenToMapPosition([240+globals.CELLSIZE,320+globals.CELLSIZE]), {"col":1,"row":1}

	qa.assertEqual testRenderer.mapToScreenPosition([0,0]), {"x":250,"y":330}
	qa.assertEqual testRenderer.mapToScreenPosition([0,1]), {"x":250,"y":330+globals.CELLSIZE}
	qa.assertEqual testRenderer.mapToScreenPosition([-1,0]), {"x":250-globals.CELLSIZE,"y":330}

	print "shipDisplay unit tests complete"
end function

init

if locals == globals then
	runUnitTests
	demo
end if

