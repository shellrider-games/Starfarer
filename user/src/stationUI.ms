// This module implements the "station" user interface, which appears on
// the right half of the screen when the ship is docked at a station or base.
// It presents the various station services, including the market.

import "stringUtil"
import "qa"
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("item") then import "item"
if not globals.hasIndex("stationModel") then import "stationModel"
if not globals.hasIndex("crewStatistics") then import "crewStatistics"

// Import the widget classes directly into this module for more readable code:
for idx in uiWidgets.indexes
	if (idx[0] >= "A" and idx[0] <= "Z") or idx.startsWith("load") then
		locals[idx] = uiWidgets[idx]
	end if
end for

// Setup/draw the station UI.

// Draw station UI according to station model
show = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	top = bottom + height
	
	outer.background = new Panel
	background.init left, bottom, width, height, "background", load9SliceImage("panel")
	background.draw
	
	font = fonts.ArialBlack14
	font.setColor color.black
	font.print station.name + " Station : MARKET", left+4, top-14
	
	y = top - 60

	for commodity in station.market
		y = y - 40
		addCommodity left, y, width, 40, commodity.itemType, commodity.buyPrice, commodity.sellPrice 
	end for
	
	// navigation (depart/jump) button
	outer.navBtn = new Button
	navBtn.init 900, 610, 60, 30, "NAV"
	navBtn.backColor = color.black
	navBtn.start
	
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
