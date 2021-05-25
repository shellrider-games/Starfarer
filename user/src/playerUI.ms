
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
		travelModeLabel.init 800,622,160,16, "TRAVEL"
		travelModeLabel.color = color.gray
		travelModeLabel.alignment = uiWidgets.ALIGNCENTER
	end if
		
	if travelStationLabel == null then
		outer.travelStationLabel = new uiWidgets.Label
		travelStationLabel.init 800,608,160,16, "STATION"
		travelStationLabel.color = color.white
		travelStationLabel.alignment = uiWidgets.ALIGNCENTER
	end if
	travelStationLabel.setText station.name.upper
	if travelProgressBar == null then
		outer.travelProgressBar = new uiWidgets.Bar
		travelProgressBar.init 810, 590, 140, 16, "TRAVEL PROGRESS"
		travelProgressBar.color = color.green
	end if

	if arriving then
		travelModeLabel.setText "ARRIVING:"
		travelProgressBar.setValue -distance
	else
		travelModeLabel.setText "DEPARTING:"
		travelProgressBar.setValue distance
	end if
end function

hideTravel = function()
	travelModeLabel.erase;		outer.travelModeLabel = null
	travelStationLabel.erase;	outer.travelStationLabel = null
	travelProgressBar.erase;	outer.travelProgressBar = null
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