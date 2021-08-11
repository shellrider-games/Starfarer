// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

import "miscUtil"
ensureImport "setup"
ensureImport "listUtil"
ensureImport "qa"
ensureImport "spriteUtil"
ensureImport "spriteControllers"
ensureImport "door"
ensureImport "item"
ensureImport "constants"


init = function()
	// clear the sprite display, and load the ship background
	disp.shipSprites.clear
end function

// Renderer: a class that exists to render a ship onto the display.  We may
// have multiple ships on screen at some point; each will get its own Renderer.
Renderer = {}
Renderer.ship = null		// the shipModel we are rendering
Renderer.x = 240			// horizontal center of the ship on screen
Renderer.y = 320			// vertical center of the ship on screen
Renderer.sprites = null		// sprites owned by this particular renderer

// renderShip: load the given ship model onto the display.
Renderer.renderShip = function(ship)
	// Store our ship model; and also a reference the other way, so
	// that entities (like characters) that need to get from the model
	// to the renderer can do so.  Note that this creates a circular
	// reference, so be sure to clean it up when closing.
	self.ship = ship
	ship.renderer = self
	
	// load the ship map, and calculate our graphics offset
	shipImage = file.loadImage(file.child(ship.directory, "map.png"))
	self.addSprite shipImage, self.x, self.y
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
	disp.shipSprites.sprites.removeVal minion
	disp.shipSprites.sprites.push minion
	self.sprites.push minion
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

TargetSprite = new Sprite
TargetSprite.update = function(dt); end function
TargetSprite.srcImage = file.loadImage("/usr/pics/reticles.png")
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
		end if
	end for
end function

Renderer.stop = function()
	// Tear down everything we set up for this renderer.
	for sp in self.sprites
		disp.shipSprites.sprites.removeVal sp
	end for
	self.sprites = null
	if self.ship != null then self.ship.renderer = null
	self.ship = null
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
			game.money = game.money - game.station.getCommodityBuyPrice(itemType.name)
			self.renderContents cell
			cell.contents.fadeIn
		end if
	end if

	// check for outgoing types that are now satisfied
	for cell in self.ship.getCargoOutCells
		if cell.contents == null or cell.contents.lerper then continue
		item = cell.contents
		if self.ship.outgoingTypes.indexOf(item.__isa) != null then
			game.money = game.money + game.station.getCommoditySellPrice(item.name)
			cell.contents = null
			item.fadeOut 16, 0
		end if
	end for
end function

// Update the whole ship display (and all sprites on it).
update = function(dt = 0.1)
	// update all sprites in the shipSprites layer on the screen
	for s in disp.shipSprites.sprites
		s.update dt
	end for
end function

// demo: test/demonstrate this module on its own.
demo = function()	
	import "shipModel"
	globals.shipModel = shipModel
	currentDirectory = pwd
	cd "/usr/ships/freighter"
	import "shipData"
	cd currentDirectory
	ship = shipData.ship
	rend = new Renderer
	rend.renderShip ship

	globals.playerShip = ship

	import "character"
	globals.character = character
	crewmember = new character.Character
	crewmember.setScreenPos rend.mapToScreenPosition([4,6])
	disp.shipSprites.sprites.push crewmember
	while not key.pressed("escape")
		if mouse.button then
			text.clear
			print ship.getCell(rend.screenToMapPosition(mouse).col,rend.screenToMapPosition(mouse).row)
			wait 0.25
		end if
		if mouse.button(1) then
			crate = new shipModel.Item
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
	
	clear
end function

init

if locals == globals then demo

