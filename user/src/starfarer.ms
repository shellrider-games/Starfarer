// this is the main Starfarer Entrypoint.
// 

import "src/setup"

starfarer = {}
starfarer.init = function()
	// Start Game/Main loop
	self.start = function()

		//cleanup before exit.
		cleanup = function()
			clear
		end function

		//Process all available input
		processInput = function()
		while key.available
			k = key.get
			text.print code(k) //print keycode for debugging purposes.
			if k == char(27) or k == "q" then
				cleanup
				exit
			end if
		end while
		end function


		//Main Loop
		while true
			processInput
			yield
		end while

	end function
end function

game = new starfarer
game.init
game.start






