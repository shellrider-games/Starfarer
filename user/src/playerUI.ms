
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("crewStatistics") then import "crewStatistics"

moneyLabel = null
lastMoney = null

travelModeLabel = null
travelStationLabel = null
travelProgressBar = null

show = function()
    moneyLabel = new uiWidgets.Label
    moneyLabel.init 0, 620, 200, 20, "Credits: " + crewStatistics.money
	moneyLabel.draw

    outer.moneyLabel = moneyLabel
end function

// Show travel progress: we're the given distance (0-1)
// from the given station.  If arriving=false, that means
// we are departing this station.  This may be called multiple
// times as travel progresses.
showTravel = function(station, distance=0.5, arriving=true)
	if travelModeLabel == null then
		outer.travelModeLabel = new uiWidgets.Label
		travelModeLabel.init 860,620,100,20, "TRAVEL"
		travelModeLabel.color = color.gray
		travelModeLabel.alignment = uiWidgets.ALIGNCENTER
	end if
	if arriving then travelModeLabel.setText "ARRIVING:" else travelModeLabel.setText "DEPARTING:"
	if travelStationLabel == null then
		outer.travelStationLabel = new uiWidgets.Label
		travelStationLabel.init 860,600,100,20, "STATION"
		travelStationLabel.color = color.white
		travelStationLabel.alignment = uiWidgets.ALIGNCENTER
	end if
	travelStationLabel.setText station.name.upper
	if travelProgressBar == null then
		outer.travelProgressBar = new uiWidgets.Bar
		travelProgressBar.init 860, 585, 100, 10, "TRAVEL PROGRESS"
		travelProgressBar.color = color.green
	end if
	travelProgressBar.setValue distance
end function

hideTravel = function()

end function

update = function(dt = 0.1)
	if crewStatistics.money != lastMoney then
		outer.lastMoney = crewStatistics.money
	    moneyLabel.setText "Credits: " + crewStatistics.money
	end if
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear
	//text.clear

    show
    showTravel {"name":"Demo"}, 0, false

	progress = 0.1    
    while not key.pressed("q")
        wait 1
        crewStatistics.money = crewStatistics.money - 10
        showTravel {"name":"Demo"}, progress, false
        progress = progress + 0.1
        update
    end while
end function

if locals == globals then
	demo
end if