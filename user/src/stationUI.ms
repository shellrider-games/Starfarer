// This module implements the "station" user interface, which appears on
// the right half of the screen when the ship is docked at a station or base.
// It presents the various station services, including the market.

import "stringUtil"
import "qa"
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("item") then import "item"
if not globals.hasIndex("stationModel") then import "stationModel"
if not globals.hasIndex("crewStatistics") then import "crewStatistics"

costPerFuel = 10
costPerRepair = 15

SHOW_MARKET = 0
SHOW_CANTEEN = 1

currentTab = 0
tabs = []

// Import the widget classes directly into this module for more readable code:
for idx in uiWidgets.indexes
	if (idx[0] >= "A" and idx[0] <= "Z") or idx.startsWith("load") then
		locals[idx] = uiWidgets[idx]
	end if
end for

// Setup/draw the station UI.

// Draw station UI according to station model
show = function(station,left=550, bottom=150, width=350, height=400)
	
	outer.background = new Panel
	background.init left, bottom, width, height, "background", load9SliceImage("panel")
	background.draw

	if outer.tabs == [] then showTabs station, left, bottom+height, width, 24

	showNavButton

	if currentTab == SHOW_MARKET then showMarket station, left, bottom, width, height
	
end function

setCurrentTab = function(currentTab)
	outer.currentTab = currentTab
end function

showTabs = function(station, left = 550, bottom = 550, width = 350, height = 24)
	tabs = outer.tabs

	marketTabButton = new TabButton
	marketTabButton.init left, bottom, 98, height, "Market"
	marketTabButton.state = Button.PRESSED
	marketTabButton.draw
	
	canteenTabButton = new TabButton
	canteenTabButton.init left+100, bottom, 98, height, "Canteen"
	canteenTabButton.draw

	resetTab = function(tab)
		for iTab in outer.tabs
			if tab != iTab then iTab.state = uiWidgets.Button.NORMAL
			iTab.redraw
		end for
	end function

	printCurrentTab = function()
		print outer.currentTab
	end function

	marketTabButton.action = function()
		resetTab self
		stationUI.setCurrentTab stationUI.SHOW_MARKET
		stationUI.show station
	end function

	canteenTabButton.action = function()
		resetTab self
		stationUI.setCurrentTab stationUI.SHOW_CANTEEN
		stationUI.show station
	end function

	outer.tabs.push marketTabButton
	outer.tabs.push canteenTabButton
	
	marketTabButton.start
	canteenTabButton.start
end function

showMarket = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	top = bottom + height
	
	font = fonts.ArialBlack14
	font.setColor color.black
	font.print station.name + " Station : MARKET", left+4, top-14
	
	y = top - 60

	for commodity in station.market
		y = y - 40
		addCommodity left, y, width, 40, commodity.itemType, commodity.buyPrice, commodity.sellPrice 
	end for
	
	// Buy (1) Fuel button
	x = right - 20
	if crewStatistics.fuel < crewStatistics.maxFuel and crewStatistics.money > costPerFuel then
		outer.buyFuelBtn = addBottomButton("Fuel ($" + costPerFuel + ")", x)
		buyFuelBtn.action = @buyFuel
	end if
	x = x - 120
	
	// Repair (1) button
	if crewStatistics.hull < crewStatistics.maxHull and crewStatistics.money > costPerRepair then
		outer.repairButton = addBottomButton("Repair ($" + costPerRepair + ")", x)
		repairButton.action = @buyRepair
	end if
	x = x - 120
end function

showNavButton = function()
	// navigation (depart/jump) button
	outer.navBtn = new Button
	navBtn.init 900, 610, 60, 30, "NAV"
	navBtn.backColor = color.black
	navBtn.start
end function

buyFuel = function()
	crewStatistics.fuel = crewStatistics.fuel + 1
	crewStatistics.money = crewStatistics.money - costPerFuel
	if crewStatistics.fuel >= crewStatistics.maxFuel  or crewStatistics.money < costPerFuel then buyFuelBtn.stop
end function

buyRepair = function()
	crewStatistics.hull = crewStatistics.hull + 1
	crewStatistics.money = crewStatistics.money - costPerRepair
	if crewStatistics.hull >= crewStatistics.maxHull  or crewStatistics.money < costPerFuel then repairButton.stop
end function

addBottomButton = function(caption, right, width=100)
	button = new Button
	button.init right - width, background.bottom + 10, width, 30, caption
	button.backColor = background.mainColor
	button.start
	return button
end function

hide = function()
	uiWidgets.clearAll
end function

// Add a row of widgets for one market commodity.
addCommodity = function(left, bottom, width, height, itemType, buyPrice, sellPrice)
	qa.assert itemType isa item.Item
	
	col0_1 = left + width * 0.4		// X position between column 0 and column 1
	col1_2 = left + width * 0.7		// X position between columns 1 and 2
	midY = bottom + height/2
	right = left + width
	
	// column 0: name and icon
	disp.uiPixel.drawImage itemType.image, left + 8, midY-16, 32, 32
	fonts.ArialBlack14.print itemType.name, left + 48, midY - 6
	
	// column 1: buy button
	btn = new Button
	btn.init col0_1 + 8, bottom + 4, col1_2 - col0_1 - 16, height - 8, 
	    "Buy ($" + buyPrice + ")"
	btn.backColor = background.mainColor
	btn.start
	btn.action = function()
		playerShip.incomingTypes.push itemType
	end function
	
	// column 2: sell button
	btn = new Button
	btn.init col1_2 + 8, bottom + 4, right - col1_2 - 16, height - 8, 
	    "Sell ($" + sellPrice + ")"
	btn.backColor = background.mainColor
	btn.start
	btn.action = function()
		playerShip.outgoingTypes.push itemType
	end function
	
end function


//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	text.clear

	station = new stationModel.Station
	station.init "SUPER COOL SPACE STATION - 7"
	station.addCommodityToMarket item.FoodItem, 80, 50
	station.addCommodityToMarket item.WaterItem, 120, 100
	station.addCommodityToMarket item.MedsItem, 200, 150
	station.addCommodityToMarket item.GunsItem, 300, 200

	show station

	while not key.pressed("escape")
		uiWidgets.update 1/60
		yield
	end while
	key.clear
	
end function

if locals == globals then
	demo
end if
