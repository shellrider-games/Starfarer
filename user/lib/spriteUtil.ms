// Helper functions and utilities for working with Sprite and SpriteDisplay.

Sprite.positionAtIndex = function(spriteDisp, desiredIndex)
	curIdx = spriteDisp.sprites.indexOf(self)
	if curIdx != desiredIndex then
		spriteDisp.sprites.remove curIdx
		if curIdx < desiredIndex then desiredIndex = desiredIndex - 1
		spriteDisp.sprites.insert desiredIndex, self
	end if
end function

