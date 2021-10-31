// This module defines the Character class, which represents a single (usually
// humanoid) character in the game.  These are used for crewmates, invaders, etc.
// 
// Characters are sprites that can face in any of 4 directions, and have simple
// animations for walking around, "working", etc.

import "constants"
import "qa"
import "spriteUtil"
import "spriteControllers"
import "mathUtil"
ensureImport "charAI"

// Other constants
frameSize = 16		// width and height of each frame in the sprite sheet

defaultSheet = file.loadImage("/usr/pics/pixelguy.png")

getAnim = function(sheet, row=0, fromCol=0, count=1)
	frames = []
	for i in range(0, count-1)
		p = sheet.getImage((fromCol+i)*frameSize, row*frameSize, frameSize, frameSize)
		frames.push p
	end for
	return spriteControllers.newAnimation(frames)
end function

// AnimSet: represents all the animations for a particular type of character.
// We'll have different AnimSets for different species, genders, uniforms, etc.
// Access a particular animation as, e.g., animSet.walk[direction].
AnimSet = {}
AnimSet.idle = []
AnimSet.walk = []

AnimSet.make = function(sheet)
	result = new AnimSet
	result.idle = []	// (make our own unique list, rather than mutating the parent list)
	result.walk = []
	for dir in range(0, 3)
		result.idle.push getAnim(sheet, 3-dir, 0, 1)
		result.walk.push getAnim(sheet, 3-dir, 1, 2)
		result.walk[-1].fps = 3
	end for
	return result
end function

Character = new spriteControllers.Animated
Character.name = "Arthur"
Character.ship = null		// CAREFUL: circular reference; be sure to break when done
Character.renderer = null
Character.anims = AnimSet.make(defaultSheet)
Character.facing = SOUTH
Character.walking = false
Character.carrying = null	// Item we are currently carrying
Character.speed = 30		// walking speed, in pixels/sec
Character.path = []
Character.usingDoor = null
Character.col = 0			// horizontal position within the ship
Character.row = 0			// vertical position within the ship
Character.usingSystem = null
Character.maxHealth = 10
Character.health = 10
Character.brain = null		// added in boardShip, so we can select the right type of Brain

Character.boardShip = function(ship)
	self.ship = ship
	ship.minions.push self
	if self.brain == null then self.brain = charAI.Brain.make
end function

Character.leaveShip = function()
	if self.ship then self.ship.minions.removeVal self
	self.ship = null
	self.renderer = null
end function

// Move the character towards the given screen position, moving no more than the 
// given amount (distance, in pixels).  Return true if we moved, or false if we
// were already there.
Character.moveTowards = function(screenPos, amount)
	if screenPos.x == self.x and screenPos.y == self.y then return false
	self.turnToFaceScreenPos screenPos
	return mathUtil.moveTowardsXY(self, screenPos, amount)
end function

// Look at the next step in our path.  If that goes through a door, open it.
Character.openDoorIfNeeded = function()
	if not self.path or not self.ship then return

	dir = constants.dirFromDelta(self.path[0][1]-self.row, self.path[0][0]-self.col)
	door = self.ship.map[self.col][self.row].walls[dir]
	if door isa Door then
		door.openForUser self
		self.usingDoor = door
	end if
end function

Character.updateAnimation = function(dt=0.1)
	// make sure we're playing the right animation
	if self.walking then a = self.anims.walk[self.facing] else a = self.anims.idle[self.facing]
	if not self.curAnim or self.curAnim.frames != a.frames then
		self.curAnim = a.clone
	end if

	// and apply the animation to this sprite
	self.curAnim.applyTo self, dt
end function

Character.update = function(dt=0.1)
	if self.renderer == null then self.renderer = self.ship.renderer
	// follow our path
	if self.path then
		if not self.walking then
			self.walking = true
			self.openDoorIfNeeded
			if self.usingSystem then self.clearUseSystem
		end if
		moved = self.moveTowards(self.renderer.mapToScreenPosition(self.path[0]), self.speed * dt)
		if not moved then
			// We've reached the cell we were immediately walking towards.
			// If we passed through a door, we're done with it now.
			if self.usingDoor then
				self.usingDoor.userDone self
				self.usingDoor = null
			end if
			// Move to the next step of the path.
			self.path = self.path[1:]
			if self.path then
				self.openDoorIfNeeded
				nextPos = self.path[0]
				nextCell = self.ship.getCell(nextPos[0],nextPos[1])
				if self.path.len == 1 and self.carrying then
					// drop our item on the last step of the path, and call it a day
					self.dropItem self.path[0]
					self.path = null
				else if self.path.len == 1 and nextCell.contents then
					// pick up the item at the end of the path
					self.pickUp nextCell.contents
					self.path = null
				else
					// just keep walking, just keep walking!
					self.moveTowards self.renderer.mapToScreenPosition(nextPos), self.speed * dt
				end if
			end if
			if not self.path then self.autoUse
		end if
		newPos = self.renderer.screenToMapPosition(self)
		self.col = newPos.col; self.row = newPos.row
	else
		self.walking = false
	end if

	// update animation and any item we're carrying
	self.updateAnimation dt
	self.updateCarriedItem
	
	// update our brain
	if self.brain != null then self.brain.update self, dt
	
	// use or repair the cell we're in (toDo: based on current brain activity)
	ce = self.ship.getCell(self.col, self.row)
	if ce.broken then
		ce.repair dt
		mapPos = {}
		mapPos.col = self.col
		mapPos.row = self.row
		if ce.broken != true then self.renderer.removeBroken(mapPos)
	else if self.usingSystem then
		self.useSystem dt
	end if
end function

Character.updateCarriedItem = function()
	if not self.carrying then return
	self.carrying.scale = 0.75
	dist = CELLSIZE * 0.4
	self.carrying.x = self.x + dist * constants.dx(self.facing)
	self.carrying.y = self.y + dist * constants.dy(self.facing)
	myIdx = disp.shipSprites.sprites.indexOf(self)
	if self.facing == NORTH then
		// position item just under the character
		self.carrying.positionAtIndex disp.shipSprites, myIdx-1
	else
		// position item just on top of the character
		self.carrying.positionAtIndex disp.shipSprites, myIdx+1
	end if
end function

Character.turnToFaceScreenPos = function(pos)
	// calculate the "ideal" facing, including diagonals
	idealFacing = constants.dirFromDelta(pos.y - self.y, pos.x - self.x)
	// if that's withing 0.5 of our current facing, leave it alone;
	// otherwise, set the new facing (as close as we can)
	diff = abs(idealFacing - self.facing)
	if diff > 2 then diff = abs(diff - 4)  // (accounts for wrap-around)
	if diff > 0.6 then self.facing = round(idealFacing) % 4
end function

// Pick up the given Item.  If this character is already next to the item,
// it will pick it up immediately.  If not, it will path-find to it, and
// then pick it up once it's next to it.
Character.pickUp = function(item)
	if self.carrying != null then return
	dcol = item.col - self.col; drow = item.row - self.row
	if abs(dcol) > 1 or abs(drow) > 1 then
		// Too far away!  Walk over there, and THEN pick it up.
		cell = self.ship.getCell(item.col, item.row)
		self.path = pathfinding.findPathUpTo(self.ship, self, item)
		return
	end if
	// Close enough; let's pick it up now.
	self.turnToFaceScreenPos item
	self.carrying = item
	disp.shipSprites.sprites.removeVal item
	disp.shipSprites.sprites.push item
	self.ship.noteItemPickedUp item
end function

// Drop the item we're carrying into the cell at the given position.
// If that position is more than 1 square away, walk to it first.
Character.dropItem = function(onPos)
	if onPos isa map then
		col = onPos.col; row = onPos.row
	else
		col = onPos[0]; row = onPos[1]
	end if
	if self.ship.getCell(col,row).contents != null then return
	item = self.carrying
	if item == null then return

	dcol = col - self.col; drow = row - self.row
	if abs(dcol) > 1 or abs(drow) > 1 then
		// Too far away!  Hoof it over there.
		self.path = pathfinding.findPath(self.ship, self, onPos)
		return
	end if
	
	// Close enough; let's put it down now.
	dropScreenPos = self.renderer.mapToScreenPosition(onPos)
	self.turnToFaceScreenPos self.renderer.mapToScreenPosition(onPos)
	self.updateCarriedItem
	item.lerpTo dropScreenPos, 1, 0.25
	self.ship.map[col][row].placeItem item

	self.turnToFaceScreenPos item
	self.carrying = null
	self.walking = false
end function

Character.goTo = function(mapPos)
	self.brain.orders = charAI.DirectOrderActivity.make(mapPos)
	self.brain.doFor = 0
end function

Character.useSystem = function(dt)
	self.usingSystem.use self, dt
end function

Character.setUseSystem = function(system)
	self.usingSystem = system
end function

Character.clearUseSystem = function()
	self.usingSystem = null
end function

Character.takeDamage = function(healthLost)
	self.health = self.health - healthLost
	// ToDo: die when health < 1
end function

Character.autoUse = function()
	// if we are standing on a system square, start using that system
	self.setUseSystem self.ship.systemAt(self.col, self.row)
end function

Character.setScreenPos = function(point)
	if point isa map then
		x = point.x
		y = point.y
	else
		x = point[0]
		y = point[0]
	end if
	self.x = x; self.y = y
end function

Character.getScreenPos = function()
	return [self.x,self.y]
end function

Character.setMapPos = function(pos)
	if pos isa map then
		self.col = pos.col; self.row = pos.row		
	else
		self.col = pos[0]; self.row = pos[1]
	end if
end function

Character.getMapPos = function()
	return {"row": self.row, "col":self.col}
end function

demo = function()
	clear
	display(4).mode = displayMode.sprite
	spr = display(4)
	spr.clear
	
	gfx.clear
	gfx.fillRect 400, 240, 160, 160, color.gray
	globals.c = new Character
	c.x = 480; c.y = 320
	spr.sprites.push c
	
	print "Use arrow keys or d-pad to move the character."
	while not key.pressed("escape")
		c.updateAnimation 1/60
		c.walking = true
		if key.axis("Horizontal") < -0.5 then
			c.facing = WEST
			c.x = c.x - 1
		else if key.axis("Horizontal") > 0.5 then
			c.facing = EAST
			c.x = c.x + 1
		else if key.axis("Vertical") > 0.5 then
			c.facing = NORTH
			c.y = c.y + 1
		else if key.axis("Vertical") < -0.5 then
			c.facing = SOUTH
			c.y = c.y - 1
		else
			c.walking = false
		end if
		yield
	end while
	key.clear
end function

if locals == globals then demo

