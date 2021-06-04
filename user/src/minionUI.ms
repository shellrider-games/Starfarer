if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("character") then import "character"

minions = []
nametags = []
healthbars = []

init = function(minions)
    outer.minions = minions
end function

show = function()
    uiWidgets.reset

    for i in range(0, minions.len-1)
        nametag = new uiWidgets.Label
        nametag.init 20, 530-60*i, 100, 20, minions[i].name
        nametag.draw
        nametags.push nametag

        healthbar = new uiWidgets.ValuedBar
        healthbar.init 20, 490-60*i, 100, 40, minions[i].maxHealth, minions[i].health
        healthbar.setColor color.lime
        healthbar.draw
        healthbars.push healthbar
    end for
end function

update = function(dt = 0.1)
    for i in range(0, minions.len-1)
        nametags[i].setText minions[i].name
        healthbars[i].setValue minions[i].health, minions[i].maxHealth
    end for
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear

    demoCharacter1 = new character.Character
    demoCharacter2 = new character.Character

    demoCharacter2.name = "Becca"
    demoCharacter2.maxHealth = 8
    demoCharacter2.health = 6

    minions = [demoCharacter1, demoCharacter2]

    init(minions)
    show()
    while not key.pressed("q")
        wait 1
        demoCharacter2.health = (demoCharacter2.health+1) % demoCharacter2.maxHealth
        update(1)
    end while
end function

if locals == globals then
	demo
end if