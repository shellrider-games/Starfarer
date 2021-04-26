


starfarer = {}
starfarer.init = function()
    // Debug function for writing to debug screen. display(0)
    globals.debug = function(s="")
        if display(0).mode == displayMode.text then display(0).print(s)
    end function

    //---Set default display mode configuration---.
    display(0).mode = displayMode.text // Debug text
    display(0).clear
    display(1).mode = displayMode.off //Main Menu/Pause Menu
    display(2).mode = displayMode.pixel //Pixel Overlay/Information
    display(2).clear color.clear
    //display(3).mode = displayMode.sprite //Sprite top layer(ceiling/hats/floaty things) commented out to allow error messages.
    display(4).mode = displayMode.sprite //Sprite entities/objects
    display(5).mode = displayMode.tile //Tile Level
    display(6).mode = displayMode.pixel //background
    display(7).mode = displayMode.pixel //scratch pixelDisplay
    //---End Display mode configuration---

    


    // Start Game/Main loop
    self.start = function()

        //cleanup before exit.
        cleanup = function()
            clear
            globals.remove("debug")
        end function

        //Process all available input
        processInput = function()
        while key.available
            k = key.get
            debug code(k) //print keycode for debugging purposes.
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

clear
game = new starfarer
game.init
game.start






