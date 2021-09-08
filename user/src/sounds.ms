// This file loads and manages sound effects for the game.

PositionalSound = new Sound

PositionalSound.playAt = function(x, volume=1, speed=1)
	self.play volume, (x-480)/400, speed
end function

PositionalSound.load = function(filename)
	path = "/usr/sounds/" + filename + ".wav"
	snd = file.loadSound(path)
	if snd == null then
		path = "/sys/sounds/" + filename + ".wav"
		snd = file.loadSound(path)
	end if
	if snd == null then
		print "Sound not found: " + path
	end if
	snd.__isa = PositionalSound
	return snd
end function

doorOpen = PositionalSound.load("door-open")
doorClose = PositionalSound.load("door-close")
warp = PositionalSound.load("warp-sound")

laserFire = PositionalSound.load("pew")
laserHit = PositionalSound.load("hit")

shieldUp = PositionalSound.load("shieldUp")
shieldHit = PositionalSound.load("shieldHit")

demo = function()
	clear
	print "Click anywhere to hear a sound."
	
	while true
		yield
		if not mouse.button then continue
		
		doorOpen.playAt mouse.x

		while mouse.button; yield; end while	// (wait for mouse-up)
	end while
end function

if locals == globals then demo

	