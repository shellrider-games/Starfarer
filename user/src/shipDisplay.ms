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

Door = new spriteControllers.Animated
Door.tint = color.blue

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

addSprite = function(image, x, y, baseClass)
	if baseClass == null then baseClass = Sprite
	if image isa string then image = file.loadImage(image)
	qa.assert image != null, "invalid image in shipDisplay.addSprite"
	sp = {}
	sp.__isa = baseClass
	sp.image = image
	sp.x = x
	sp.y = y
	disp.shipSprites.sprites.push sp
	return sp
end function

init = function()
	// clear the sprite display, and load the ship background
	disp.shipSprites.clear
	//outer.ship = addSprite("/usr/ships/falcon/image.png", 200, 320)	
	
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

renderShip = function(ship)
	currentDirectory = pwd
	cd ship.directory
	outer.playerShipImage = file.loadImage("map.png")
	addSprite(playerShipImage,PLAYER_SHIP_RENDER_X,PLAYER_SHIP_RENDER_Y)
	cd currentDirectory
end function

mapZeroZero = function()
	return {"x": PLAYER_SHIP_RENDER_X - playerShipImage.width/2 + shipData.ship.offset[0] * globals.CELLSIZE,"y": PLAYER_SHIP_RENDER_Y - playerShipImage.height/2 + shipData.ship.offset[1] * globals.CELLSIZE}
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
	return {"x": floor((x - mapStartPoint.x)/globals.CELLSIZE), "y": floor((y - mapStartPoint.y)/globals.CELLSIZE)}
end function

mapPositionToscreenPosition = function(point)
	if point isa map then
		x = point.x
		y = point.y
	else
		x = point[0]
		y = point[1]
	end if
	return {"x": mapZeroZero.x+x*globals.CELLSIZE+globals.CELLSIZE/2, "y": mapZeroZero.y+y*globals.CELLSIZE+globals.CELLSIZE/2}
end function

putItem = function(ship, item, point)
	if ship.getCell(point) != null and ship.getCell(point).contents == null then
		for col in range(0,ship.columns-1)
			for row in range(0,ship.rows-1)
				if ship.getCell([col,row]) != null and ship.getCell([col,row]).contents != null and ship.getCell([col,row]).contents == item then 
					ship.getCell([col,row]).contents = null
				end if
			end for
		end for
		ship.getCell(point).contents = item
		item.sprite.x = mapPositionToscreenPosition(point).x; item.sprite.y = mapPositionToscreenPosition(point).y
		if disp.shipSprites.sprites.indexOf(item.sprite) == null then disp.shipSprites.sprites.push item.sprite
	end if
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
	crateOne = new shipModel.Item; crateOne.init
	crateTwo = new shipModel.Item; crateTwo.init
	crateThree = new shipModel.Item; crateThree.init


	putItem(shipData.ship, crateOne,[3,0])
	putItem(shipData.ship, crateTwo,[7,7])
	putItem(shipData.ship, crateThree,[0,0])

	import "character"
	globals.character = character
	crewmember = new character.Character
	crewmember.setPosition(mapPositionToscreenPosition([4,6]))
	disp.shipSprites.sprites.push crewmember
	while not key.pressed("escape")
		if mouse.button then
			text.clear
			print shipData.ship.getCell(screenPositionToMapPosition(mouse))
			wait 0.25
		end if
		if mouse.button(1) then
			crate = new shipModel.Item; crate.init
			putItem(shipData.ship, crate, screenPositionToMapPosition(mouse))
		end if
		crewmember.update
	end while
end function

init

if locals == globals then demo

