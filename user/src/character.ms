// This module defines the Character class, which represents a single (usually
// humanoid) character in the game.  These are used for crewmates, invaders, etc.
// 
// Characters are sprites that can face in any of 4 directions, and have simple
// animations for walking around, "working", etc.

import "constants"
import "qa"
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
Character.anims = AnimSet.make(defaultSheet)
Character.facing = SOUTH
Character.walking = false
Character.speed = 1
Character.path = []

Character.update = function(dt=0.1)
	if self.path then
		self.walking = true
		moved = mathUtil.moveTowardsXY(self, renderer.mapToScreenPosition(self.path[0]), self.speed)
		if not moved then
			self.path = self.path[1:]
			if self.path then
				mathUtil.moveTowardsXY(self, renderer.mapToScreenPosition(self.path[0]), self.speed)
			end if
		end if
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
end function

Character.setPosition = function(point)
	if point isa map then
		x = point.x
		y = point.y
	else
		x = point[0]
		y = point[0]
	end if
	self.x = x; self.y = y
end function

Character.getPosition = function()
	return [self.x,self.y]
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
		c.update
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

