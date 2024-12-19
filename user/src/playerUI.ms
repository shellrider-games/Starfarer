
import "miscUtil"
ensureImport "uiWidgets"

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

fleeButton = null
enemyHullBar = null
enemyShipUI = []

selectedControl = null

show = function()
	uiWidgets.reset
	
    outer.moneyLabel = new uiWidgets.Label
    moneyLabel.init 0, 620, 150, 20, "Credits: " + game.money
	moneyLabel.draw

	outer.hullBar = new uiWidgets.ValuedBar
	hullBar.init 200, 600, 200, 40, playerShip.maxHp, playerShip.hp
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
		control = new system.powerControlClass
		control.init x, 0, control.width, 0
		control.initSystem system
		control.onChange = function()
			playerShip.distributePower
		end function
		control.draw
		control.start
		powerControls.push control
		if x == 0 then x = 20
		x = x + control.width
	end for
end function

// selectControl: called by a selectable power control when it is
// tapped to select it.  Returns true if the control should go ahead
// and do whatever it does (usually, add more UI widgets) when
// selected; false if it should not.  Also, if a previous control
// was selected, that one is told to close (tear down its UI).
selectControl = function(powerControl)
	if powerControl == selectedControl then return false
	if selectedControl != null then selectedControl.close
	outer.selectedControl = powerControl
	return true
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

// Show any extra UI needed during combat.
showCombat = function()
	if enemyShipUI then return	// (already showing)
	outer.fleeButton = new uiWidgets.Button
	fleeButton.init 900, 610, 60, 30, "FLEE"
	fleeButton.action = function()
		game.fleeCombat
	end function
	enemyShipUI.push fleeButton
	
	panel = new uiWidgets.Panel
	panel.init 600, 550, 240, 52
	enemyShipUI.push panel
	
	enemy = game.combatEncounter.ship
	label = new uiWidgets.Label
	label.init panel.left+10, panel.top-24, 200, 20, enemy.name
	enemyShipUI.push label

	outer.enemyHullBar = new uiWidgets.Bar
	enemyHullBar.init panel.left+50, panel.bottom+8, 180, 20
	enemyHullBar.backColor = panel.mainColor
	enemyHullBar.value = enemy.hp / enemy.maxHp
	enemyShipUI.insert 0, enemyHullBar	// (so it gets removed first when we stop)
	
	label = new uiWidgets.Label
	label.init enemyHullBar.left-8-50, enemyHullBar.bottom, 50, 20, "Hull:"
	label.alignment = uiWidgets.ALIGNRIGHT
	enemyShipUI.push label

	for widget in enemyShipUI; widget.start; end for
	enemyHullBar.redraw // (since it got overdrawn by the panel)
end function

showContinueJump = function()
	button = new uiWidgets.Button
	button.init 960-100, 610, 100, 30, "CONTINUE"
	button.action = function()
		game.continueJump
	end function
	button.start
	enemyShipUI.push button
end function

hideCombat = function()
	for widget in enemyShipUI; widget.stop; end for
	outer.enemyShipUI = []
	outer.fleeButton = null
	outer.enemyHullBar = null
end function

update = function(dt = 0.1)
	if game.money != lastMoney then
		outer.lastMoney = game.money
	    moneyLabel.setText "Credits: " + game.money
	end if
	if playerShip.hp != lastHull[0] or playerShip.maxHp != lastHull[1] then
		lastHull[0] = playerShip.hp
		lastHull[1] = playerShip.maxHp
		hullBar.setValue playerShip.hp, playerShip.maxHp
	end if
	if game.fuel != lastFuel[0] or game.maxFuel != lastFuel[1] then
		lastFuel[0] = game.fuel
		lastFuel[1] = game.maxFuel
		fuelBar.setValue game.fuel, game.maxFuel
	end if
	if enemyHullBar != null then
		enemy = game.combatEncounter.ship
		enemyHullBar.setValue enemy.hp / enemy.maxHp
	end if
	//text.row = 19; text.column = 0; playerShip.minions[0].brain.printNeeds
end function

demo = function()
    disp.uiPixel.clear
	disp.uiSprites.clear

    show
    showTravel {"name":"Demo"}, 0, false

	progress = 0.1    
    while not key.pressed("q")
        wait 1
        game.money -= 10
        if rnd < 0.3 then playerShip.hp = playerShip.hp - 1
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