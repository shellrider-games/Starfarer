if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("character") then import "character"

minions = []

init = function(minions)
    outer.minions = minions
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear

    demoCharacter1 = new character.Character
    demoCharacter2 = new character.Character

    demoCharacter2.name = "Becca"
    demoCharacter2.maxHealth = 8
    demoCharacter2.health = 6

    print demoCharacter1.name + " HP: " + demoCharacter1.health + "/" + demoCharacter1.maxHealth
    print demoCharacter2.name + " HP: " + demoCharacter2.health + "/" + demoCharacter2.maxHealth

    while not key.pressed("q")
        wait 1
    end while
end function

if locals == globals then
	demo
end if