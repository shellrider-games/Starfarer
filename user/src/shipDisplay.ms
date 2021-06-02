// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
if not globals.hasIndex("qa") then import "qa"
import "spriteUtil"
import "spriteControllers"
if not globals.hasIndex("Door") then import "door"
if not globals.hasIndex("Item") then import "item"
if not globals.hasIndex("constants") then import "constants"
if not globals.hasIndex("crewStatistics") then import "crewStatistics"

// addSprite: Helper method to create and add a sprite from an image
addSprite = function(image, x, y, baseClass)
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
		baseClass.update = function(dt); end function
	end if
	disp.shipSprites.sprites.push sp
	return sp
end function

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

// renderShip: load the given ship model onto the display.
Renderer.renderShip = function(ship)
	// store our ship model
	self.ship = ship
	
	// load the ship map, and calculate our graphics offset
	playerShipImage = file.loadImage(file.child(ship.directory, "map.png"))
	addSprite playerShipImage, self.x, self.y
	self.mapZeroZero = {
		"x": self.x - playerShipImage.width/2 + ship.offset[0] * CELLSIZE,
	    "y": self.y - playerShipImage.height/2 + ship.offset[1] * CELLSIZE }
	
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

	self.renderShipSystems
end function

Renderer.renderMinion = function(minion)
	pos = self.mapToScreenPosition(minion)
	minion.x = pos.x; minion.y = pos.y
	disp.shipSprites.sprites.removeVal minion
	disp.shipSprites.sprites.push minion
end function

Renderer.placeDoor = function(door, cell, direction)
	pos = self.mapToScreenPosition(cell)
	door.x = pos.x + CELLSIZE/2 * ((direction == EAST) - (direction == WEST))
	door.y = pos.y + CELLSIZE/2 * ((direction == NORTH) - (direction == SOUTH))
	door.rotation = 90 * (direction == NORTH or direction == SOUTH)
	if disp.shipSprites.sprites.indexOf(door) == null then
		disp.shipSprites.sprites.push door
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
		disp.uiPixel.color = color.rgba(0,0,255,127)
		disp.uiPixel.fillRect self.mapZeroZero.x + system.col*CELLSIZE, self.mapZeroZero.y + system.row*CELLSIZE, system.width*CELLSIZE, system.height*CELLSIZE
	end for
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
			crewStatistics.money = crewStatistics.money - crewStatistics.currentStation.getCommodityBuyPrice(itemType.name)
			self.renderContents cell
			cell.contents.fadeIn
		end if
	end if

	// check for outgoing types that are now satisfied
	for cell in self.ship.getCargoOutCells
		if cell.contents == null or cell.contents.lerper then continue
		item = cell.contents
		if self.ship.outgoingTypes.indexOf(item.__isa) != null then
			crewStatistics.money = crewStatistics.money + crewStatistics.currentStation.getCommoditySellPrice(item.name)
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

