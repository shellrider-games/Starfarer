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

// Other constants
frameSize = 16		// width and height of each frame in the sprite sheet

defaultSheet = file.loadImage("/usr/pics/pixelguy.png")

// functions to get a delta X and Y given a facing direction
// dx = function(dir)
// 	return [0, 1, 0, -1][dir]
// end function
// dy = function(dir)
// 	return [1, 0, -1, 0][dir]
// end function

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
		result.walk[-1].fps = 1
	end for
	return result
end function

Character = new spriteControllers.Animated
Character.name = "Arthur"
Character.ship = null		// CAREFUL: circular reference; be sure to break when done
Character.anims = AnimSet.make(defaultSheet)
Character.facing = SOUTH
Character.walking = false
Character.carrying = null	// Item we are currently carrying
Character.speed = 30		// walking speed, in pixels/sec
Character.path = []
Character.usingDoor = null
Character.col = 0			// horizontal position within the ship
Character.row = 0			// vertical position within the ship

Character.boardShip = function(ship)
	self.ship = ship
	ship.minions.push self
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
	d = self.ship.map[self.col][self.row].walls[dir]
	if d isa Door then
		d.openForUser self
		self.usingDoor = d
	end if
end function

Character.update = function(dt=0.1)
	// follow our path
	if self.path then
		if not self.walking then
			self.walking = true
			self.openDoorIfNeeded
		end if
		moved = self.moveTowards(renderer.mapToScreenPosition(self.path[0]), self.speed * dt)
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
				self.moveTowards renderer.mapToScreenPosition(self.path[0]), self.speed * dt
			else
				// We've reached the end of our path.
				self.dropItem
			end if
		end if
		newPos = renderer.screenToMapPosition(self)
		self.col = newPos.col; self.row = newPos.row
	else
		self.walking = false
	end if

	// make sure we're playing the right animation
	if self.walking then a = self.anims.walk[self.facing] else a = self.anims.idle[self.facing]
	if not self.curAnim or self.curAnim.frames != a.frames then
		self.curAnim = a.clone
	end if

	// and apply the animation to this sprite
	self.curAnim.applyTo self, dt
	
	// if carrying an item, update its position relative to this character
	if self.carrying then
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
	end if
end function

Character.turnToFaceScreenPos = function(pos)
	self.facing = round(constants.dirFromDelta(pos.y - self.y, pos.x - self.x)) % 4
end function

// Pick up the given Item.  If this character is already next to the item,
// it will pick it up immediately.  If not, it will path-find to it, and
// then pick it up once it's next to it.
Character.pickUp = function(item)
	// ToDo: check positions.
	// For now, just do it!
	self.carrying = item
	disp.shipSprites.sprites.removeVal item
	disp.shipSprites.sprites.push item
	self.ship.noteItemPickedUp item, self
end function

// Drop the item we're carrying into the cell we are currently facing.
Character.dropItem = function()
	item = self.carrying
	if item == null then return
	item.scale = 1
	item.x = self.x + CELLSIZE * constants.dx(self.facing)
	item.y = self.y + CELLSIZE * constants.dy(self.facing)
	self.carrying = null
	self.ship.noteItemDropped item, self
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
	//clear
	display(4).mode = displayMode.sprite
	spr = display(4)
	spr.clear
	
	gfx.clear
	gfx.fillRect 400, 240, 160, 160, color.gray
	c = new Character
	c.x = 480; c.y = 320
	spr.sprites.push c
	
	print "Use arrow keys or d-pad to move the character."
	while not key.pressed("escape")
		c.update null
		c.walking = true
		if key.axis("Horizontal") < 0 then
			c.facing = WEST
			c.x = c.x - 1
		else if key.axis("Horizontal") > 0 then
			c.facing = EAST
			c.x = c.x + 1
		else if key.axis("Vertical") > 0 then
			c.facing = NORTH
			c.y = c.y + 1
		else if key.axis("Vertical") < 0 then
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

