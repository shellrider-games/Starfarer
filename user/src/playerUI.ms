
if not globals.hasIndex("uiWidgets") then import "uiWidgets"


moneyLabel = null
lastMoney = null

travelModeLabel = null
travelStationLabel = null
travelProgressBar = null

hullBar = null
lastHull = [null,null]  // current, max value

fuelBar = null
lastFuel = [null,null]	// current, max value

powerControls = []

show = function()
	uiWidgets.reset
	
    outer.moneyLabel = new uiWidgets.Label
    moneyLabel.init 0, 620, 150, 20, "Credits: " + game.money
	moneyLabel.draw

	outer.hullBar = new uiWidgets.ValuedBar
	hullBar.init 200, 600, 200, 40, game.maxHull, game.hull
	hullBar.draw
	outer.hullBarLabel = new uiWidgets.Label
	hullBarLabel.init hullBar.left-8-100, 620, 100, 20, "Hull:"
	hullBarLabel.alignment = uiWidgets.ALIGNRIGHT
	hullBarLabel.draw

	outer.fuelBar = new uiWidgets.ValuedBar
	fuelBar.init 500, 600, 200, 40, game.maxFuel, game.fuel
	fuelBar.draw
	outer.fuelBarLabel = new uiWidgets.Label
	fuelBarLabel.init fuelBar.left-8-100, 620, 100, 20, "Fuel:"
	fuelBarLabel.alignment = uiWidgets.ALIGNRIGHT
	fuelBarLabel.draw
	
	outer.powerControls = []
	x = 0
	for system in playerShip.systems
		if system.maxPower == 0 then continue
		// create the power control for this system
		control = new uiWidgets.PowerControl
		control.init x, 0, 40, 0
		control.initSystem system
		control.onChange = function()
			playerShip.distributePower
			for c in playerUI.powerControls; c.draw; end for
		end function
		control.draw
		control.start
		powerControls.push control
		if x == 0 then x = 20
		x = x + 48
	end for
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
	if game.money != lastMoney then
		outer.lastMoney = game.money
	    moneyLabel.setText "Credits: " + game.money
	end if
	if game.hull != lastHull[0] or game.maxHull != lastHull[1] then
		lastHull[0] = game.hull
		lastHull[1] = game.maxHull
		hullBar.setValue game.hull, game.maxHull
	end if
	if game.fuel != lastFuel[0] or game.maxFuel != lastFuel[1] then
		lastFuel[0] = game.fuel
		lastFuel[1] = game.maxFuel
		fuelBar.setValue game.fuel, game.maxFuel
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
        game.money = game.money - 10
        if rnd < 0.3 then game.hull = game.hull - 1
        if rnd < 0.3 then game.fuel = game.fuel - 1
        showTravel {"name":"Demo"}, progress, false
        progress = progress + 0.2
        if progress > 1 then progress = -1
        update
    end while
end function

if locals == globals then
	demo
end if