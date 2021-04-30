// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
import "qa"
import "spriteControllers"

// Door (sprite subclass)
Door = new spriteControllers.Animated
Door.tint = color.aqua

Door.make = function(x, y, addToDisplay=true)
	noob = new Door
	noob.x = x; noob.y = y
	
	// clone the animations, so they don't share state with the base class
	noob.openAnim = Door.openAnim.clone
	noob.closeAnim = Door.closeAnim.clone

	noob.close
	if addToDisplay then disp.shipSprites.sprites.push noob
	
	return noob
end function

Door.open = function()
	self.play self.openAnim
end function

Door.close = function()
	self.play self.closeAnim
end function

// Item (sprite subclass)
Item = new Sprite
Item.image = file.loadImage("/usr/pics/crate.png")
Item.update = function(dt); end function

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
	
	// prepare the Door sprite subclass
	doorSheet = file.loadImage("/usr/pics/doors.png")
	frames = []
	for i in range(0,3)
		frames.push doorSheet.getImage(i*4, 0, 4, doorSheet.height)
	end for
	Door.openAnim = spriteControllers.newAnimation(frames)
	Door.openAnim.loop = false
	frames = [] + frames
	frames.reverse
	Door.closeAnim = spriteControllers.newAnimation(frames)
	Door.closeAnim.loop = false
	Door.play Door.closeAnim
	Door.update
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
end function

Renderer.addDoor = function(doorModel, cell, direction)
	d = new Door
	pos = self.mapToScreenPosition(cell)
	d.x = pos.x + CELLSIZE/2 * ((direction == EAST) - (direction == WEST))
	d.y = pos.y + CELLSIZE/2 * ((direction == NORTH) - (direction == SOUTH))
	d.rotation = 90 * (direction == NORTH or direction == SOUTH)
	if doorModel.isOpen then d.play Door.openAnim else d.play Door.closeAnim
	d.update 1
	disp.shipSprites.sprites.push d
end function

// renderDoors: render the doors of the given cell to our display as Door sprites.
// Note that each cell is only responsible for rendering the doors above and to
// the right, except for row 0 and column 0, which must also handle doors below
// and to the left respectively.
Renderer.renderDoors = function(cell)
	if cell == null then return
	for dir in range(0,3)
		if cell.walls[dir] isa shipModel.Door then self.addDoor cell.walls[dir], cell, dir
	end for
end function

// renderContents: render the contents of the given cell to our display.
// That generally means creating or placing sprites for items.
Renderer.renderContents = function(cell)
	if cell == null or cell.contents == null then return
	if cell.contents.sprite == null then
		cell.contents.sprite = new Item
	else
		disp.shipSprites.sprites.remove cell.contents.sprite
	end if
	pos = self.mapToScreenPosition(cell)
	cell.contents.sprite.x = pos.x
	cell.contents.sprite.y = pos.y
	disp.shipSprites.sprites.push cell.contents.sprite
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

Renderer.putItem = function(ship, item, point)
	targetCell = ship.getCell(point)
	if targetCell == null then return	// out of bounds
	if targetCell.contents != null then return;	// already occupied
	for col in ship.columnRange
		for row in ship.rowRange
			cell = ship.getCell([col,row])
			if cell != null and cell.contents == item then 
				cell.contents = null
			end if
		end for
	end for
	targetCell.contents = item
	self.renderContents targetCell
end function

update = function(dt = 0.1)
	for s in disp.shipSprites.sprites
		s.update dt
	end for
	for m in globals.playerShip.minions
		m.update(dt)
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

	import "character"
	globals.character = character
	crewmember = new character.Character
	crewmember.setPosition(rend.mapToScreenPosition([4,6]))
	disp.shipSprites.sprites.push crewmember
	while not key.pressed("escape")
		if mouse.button then
			text.clear
			print ship.getCell(rend.screenToMapPosition(mouse))
			wait 0.25
		end if
		if mouse.button(1) then
			crate = new shipModel.Item
			rend.putItem ship, crate, rend.screenToMapPosition(mouse)
		end if
		crewmember.update
		update
		yield
	end while
	key.clear
end function

init

if locals == globals then demo

