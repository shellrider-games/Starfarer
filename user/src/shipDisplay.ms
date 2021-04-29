// This module is responsible for the display of the player's ship (as well
// as any other ship currently on the screen).  That includes the ship
// floorplan, and any sprites moving about in it (representing  crew,  crates,
// invaders, fires, etc.).

if not globals.hasIndex("setup") then import "setup"
import "listUtil"
import "qa"
import "spriteControllers"

//CONSTANTS
PLAYER_SHIP_RENDER_X = 240
PLAYER_SHIP_RENDER_Y = 320

//current ship image
playerShipImage = null

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

// renderShip: load the given ship model onto the display.
renderShip = function(ship)
	// load the ship map
	outer.playerShipImage = file.loadImage(file.child(ship.directory, "map.png"))
	addSprite playerShipImage, PLAYER_SHIP_RENDER_X, PLAYER_SHIP_RENDER_Y
	
	// load the doors and any items (ship contents)
	for row in ship.rowRange
		for col in ship.columnRange
			renderDoors ship.map[col][row]
			renderContents ship.map[col][row]
		end for
	end for
end function

addDoor = function(doorModel, cell, direction)
	d = new Door
	pos = mapPositionToScreenPosition(cell)
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
renderDoors = function(cell)
	if cell == null then return
	for dir in range(0,3)
		if cell.walls[dir] isa shipModel.Door then addDoor cell.walls[dir], cell, dir
	end for
end function

// renderCell: render the contents of the given cell to our display.
// That generally means creating or placing sprites for items.
renderContents = function(cell)
	if cell == null or cell.contents == null then return
	if cell.contents.sprite == null then
		cell.contents.sprite = new Item
	else
		disp.shipSprites.sprites.remove cell.contents.sprite
	end if
	pos = mapPositionToScreenPosition(cell)
	cell.contents.sprite.x = pos.x
	cell.contents.sprite.y = pos.y
	disp.shipSprites.sprites.push cell.contents.sprite
end function

mapZeroZero = function()
	return {"x": PLAYER_SHIP_RENDER_X - playerShipImage.width/2 + shipData.ship.offset[0] * globals.CELLSIZE,
	        "y": PLAYER_SHIP_RENDER_Y - playerShipImage.height/2 + shipData.ship.offset[1] * globals.CELLSIZE}
end function

screenPositionToMapPosition = function(point)
	if point isa map then
		x = point.x
		y = point.y
	else
		x = point[0]
		y = point[0]
	end if	
	mapStartPoint = mapZeroZero
	return {"col": floor((x - mapStartPoint.x)/globals.CELLSIZE), 
	        "row": floor((y - mapStartPoint.y)/globals.CELLSIZE)}
end function

mapPositionToScreenPosition = function(point)
	if point isa map then
		x = point.col
		y = point.row
	else
		x = point[0]
		y = point[1]
	end if
	return {"x": mapZeroZero.x+x*globals.CELLSIZE+globals.CELLSIZE/2, 
	        "y": mapZeroZero.y+y*globals.CELLSIZE+globals.CELLSIZE/2}
end function

putItem = function(ship, item, point)
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
	renderContents targetCell
end function


updateSprites = function(dt = 0.1)
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
	globals.shipData = shipData
	cd currentDirectory
	renderShip shipData.ship
//	crateOne = new shipModel.Item; crateOne.init
//	crateTwo = new shipModel.Item; crateTwo.init
//	crateThree = new shipModel.Item; crateThree.init
//
//	putItem shipData.ship, crateOne,[3,0]
//	putItem shipData.ship, crateTwo,[7,7]
//	putItem shipData.ship, crateThree,[0,0]

	import "character"
	globals.character = character
	crewmember = new character.Character
	crewmember.setPosition(mapPositionToScreenPosition([4,6]))
	disp.shipSprites.sprites.push crewmember
	while not key.pressed("escape")
		if mouse.button then
			text.clear
			print shipData.ship.getCell(screenPositionToMapPosition(mouse))
			wait 0.25
		end if
		if mouse.button(1) then
			crate = new shipModel.Item
			putItem shipData.ship, crate, screenPositionToMapPosition(mouse)
		end if
		crewmember.update
		updateSprites
		yield
	end while
	key.clear
end function

init

if locals == globals then demo

