// Helper functions and utilities for working with Sprite and SpriteDisplay.

import "mathUtil"

Sprite.positionAtIndex = function(spriteDisp, desiredIndex)
	curIdx = spriteDisp.sprites.indexOf(self)
	if curIdx != desiredIndex then
		spriteDisp.sprites.remove curIdx
		if curIdx < desiredIndex then desiredIndex = desiredIndex - 1
		spriteDisp.sprites.insert desiredIndex, self
	end if
end function


// SpriteLerper class: represents a movement, scaling, and fade in/out
// of a sprite over some amount of time.
SpriteLerper = {}
SpriteLerper.startTime = 0
SpriteLerper.duration = 0.5
SpriteLerper.startPos = null	// map with x and y properties
SpriteLerper.endPos = null		// also map with x and y
SpriteLerper.startScale = 1
SpriteLerper.endScale = 1
SpriteLerper.fadeIn = false
SpriteLerper.fadeOut = false
if globals.hasIndex("disp") then SpriteLerper.display = disp.shipSprites

SpriteLerper.init = function(sprite)
	self.startPos = {"x": sprite.x, "y": sprite.y}
	self.endPos = {"x": sprite.x, "y": sprite.y}
	self.startScale = sprite.scale
	self.endScale = sprite.scale
	self.startTime = time
end function

SpriteLerper.apply = function(sprite)
	frac = (time - self.startTime) / self.duration
	sprite.x = mathUtil.lerp(self.startPos.x, self.endPos.x, frac)
	sprite.y = mathUtil.lerp(self.startPos.y, self.endPos.y, frac)
	sprite.scale = mathUtil.lerp(self.startScale, self.endScale, frac)
	if self.fadeIn or self.fadeOut then
		rgba = color.toList(sprite.tint)
		if self.fadeIn then a = frac else a = 1 - frac
		rgba[3] = round(mathUtil.clamp(a * 255, 0, 255))
		sprite.tint = color.fromList(rgba)
	end if
	if self.fadeOut and frac >= 1 then
		idx = self.display.sprites.indexOf(sprite)
		if idx != null then self.display.sprites.remove idx
	end if
end function

SpriteLerper.isDone = function()
	return time >= self.startTime + self.duration
end function
