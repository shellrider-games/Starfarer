// this is the main Starfarer Entrypoint.
// 

cd "/usr/src"
import "constants"
import "setup"
import "shipModel"

// We'll directly load the freighter ship type for now:
cd "../ships/freighter"
import "shipData"
playerShip = shipData.ship
cd "/usr/src"

Starfarer = {}

Starfarer.init = function()

end function

// cleanup before exit.
Starfarer.cleanup = function()
	clear
	key.clear
end function

//Process all available input
Starfarer.processInput = function()
	while key.available
		k = key.get
		text.print code(k) //print keycode for debugging purposes.
		if k == char(27) or k == "q" then
			self.cleanup
			exit
		end if
	end while
end function

// Start Game/Main loop
Starfarer.start = function()
	//Main Loop
	while true
		self.processInput
		yield
	end while
end function

game = new Starfarer
game.init
game.start






