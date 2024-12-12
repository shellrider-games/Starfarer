// Draws the crew status along the left side of the screen.

if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("character") then import "character"

minions = []
nametags = []
healthbars = []

show = function(crew)
	clear
		
    for minion in crew
    	addMinion minion
    end for
end function

clear = function()
	for tag in nametags; tag.stop; end for
	for bar in healthbars; bar.stop; end for
	outer.minions = []
	outer.nametags = []
	outer.healthbars = []
end function

update = function(dt = 0.1)
    for i in minions.indexes
        nametags[i].setText minions[i].name
        healthbars[i].setValue max(0, minions[i].health), minions[i].maxHealth
    end for
end function

updateSelection = function
	for i in minions.indexes
		if game.selectedMinion.contains(minions[i]) then
			nametags[i].setColor color.lime
		else
			nametags[i].setColor color.silver
		end if
	end for
end function

addMinion = function(minion)
	row = minions.len
	minions.push minion
	nametag = new uiWidgets.Label
	nametag.init 20, 530-60*row, 70, 20, minion.name
	nametag.color = color.silver
	nametag.draw
	nametags.push nametag

	healthbar = new uiWidgets.ValuedBar
	healthbar.init 20, 490-60*row, 70, 40, minion.maxHealth, minion.health
	healthbar.setColor color.lime
	healthbar.draw
	healthbars.push healthbar	
end function

removeMinion = function(minion)
	idx = minions.indexOf(minion)  // idx always means "index", Georg :)
	if idx == null then return
	minions.remove idx

	crew = minions
	clear
	show crew
end function
	
demo = function()
	import "randomNames"
    disp.uiPixel.clear
	disp.uiSprites.clear

    demoCharacter1 = new character.Character
    demoCharacter2 = new character.Character

    demoCharacter2.name = "Becca"
    demoCharacter2.maxHealth = 8
    demoCharacter2.health = 6

    show [demoCharacter1, demoCharacter2]
	print "Press n for new crewmember, r to remove, q or esc to quit."
	
	nextHealthChangeTime = time + 1
    while true
        update
    	yield
        if time > nextHealthChangeTime then
	        demoCharacter2.health = (demoCharacter2.health+1) % demoCharacter2.maxHealth
			nextHealthChangeTime = time + 1
	    end if
	    if not key.available then continue
	    k = key.get
	    if k == "q" or k.code == 27 then break
        if k == "n" then
        	// add a new crewmember
        	newChar = new character.Character
        	newChar.name = randomNames.human
        	newChar.maxHealth = round(5+10*rnd)
        	newChar.health = ceil(newChar.maxHealth * rnd)
        	addMinion newChar
        else if k == "r" and minions.len > 0 then
        	// remove a crewmember
        	removeMinion minions[minions.len * rnd]
        end if
    end while
end function

if locals == globals then
	demo
end if