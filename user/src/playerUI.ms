if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("crewStatistics") then import "crewStatistics"

moneyLabel = null

show = function()
    moneyLabel = new uiWidgets.Label
    moneyLabel.init 0, 620, 200, 20, "Credits: " + crewStatistics.money
	moneyLabel.draw

    outer.moneyLabel = moneyLabel
end function

update = function(dt = 0.1)
    outer.moneyLabel.setText("Credits: " + crewStatistics.money)
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear
	text.clear

    show
    
    while(not key.pressed("q"))
        wait 1
        crewStatistics.money = crewStatistics.money - 10
        update
    end while
end function

if locals == globals then
	demo
end if