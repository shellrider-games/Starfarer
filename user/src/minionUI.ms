if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("character") then import "character"

minions = []

init = function(minions)
    outer.minions = minions
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear
    while not key.pressed("q")
        wait 1
    end while
end function

if locals == globals then
	demo
end if