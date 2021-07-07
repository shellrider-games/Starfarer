// This module implements the "station" user interface, which appears on
// the right half of the screen when the ship is docked at a station or base.
// It presents the various station services, including the market.

import "stringUtil"
import "qa"
if not globals.hasIndex("uiWidgets") then import "uiWidgets"
if not globals.hasIndex("item") then import "item"
if not globals.hasIndex("stationModel") then import "stationModel"


costPerFuel = 10
costPerRepair = 15

SHOW_MARKET = 0
SHOW_CANTINA = 1

NPC_PORTRAIT = file.loadImage("/usr/pics/portraits/person_male01.png") 

currentTab = 0
tabs = []
activeButtons = []


// Import the widget classes directly into this module for more readable code:
for idx in uiWidgets.indexes
	if (idx[0] >= "A" and idx[0] <= "Z") or idx.startsWith("load") then
		locals[idx] = uiWidgets[idx]
	end if
end for

// Setup/draw the station UI.

// Draw station UI according to station model
show = function(station,left=550, bottom=150, width=350, height=400)
	
	for button in activeButtons
		button.stop
	end for

	outer.background = new Panel
	background.init left, bottom, width, height, "background", load9SliceImage("panel")
	background.draw

	if outer.tabs == [] then showTabs station, left, bottom+height, width, 24

	showNavButton

	if currentTab == SHOW_MARKET then showMarket station, left, bottom, width, height
	if currentTab == SHOW_CANTINA then showCantina station, left, bottom, width, height
	
end function

setCurrentTab = function(currentTab)
	outer.currentTab = currentTab
end function

resetTab = function(tab)
	for iTab in outer.tabs
		if tab != iTab then iTab.state = uiWidgets.Button.NORMAL
		iTab.redraw
	end for
end function


showTabs = function(station, left = 550, bottom = 550, width = 350, height = 24)
	tabs = outer.tabs

	marketTabButton = new TabButton
	marketTabButton.init left, bottom, 98, height, "Market"
	if currentTab == SHOW_MARKET then marketTabButton.state = Button.PRESSED
	marketTabButton.draw
	
	cantinaTabButton = new TabButton
	cantinaTabButton.init left+100, bottom, 98, height, "Cantina"
	if currentTab == SHOW_CANTINA then cantinaTabButton.state = Button.PRESSED
	cantinaTabButton.draw

	printCurrentTab = function()
		print outer.currentTab
	end function

	marketTabButton.action = function()
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_MARKET
		stationUI.show station
	end function

	cantinaTabButton.action = function()
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_CANTINA
		stationUI.show station
	end function

	outer.tabs.push marketTabButton
	outer.tabs.push cantinaTabButton
	
	marketTabButton.start
	cantinaTabButton.start
end function

showMarket = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	top = bottom + height
	
	printPanelTitle "MARKET", station, left, bottom, height
	
	y = top - 60

	for commodity in station.market
		y = y - 40
		addCommodity left, y, width, 40, commodity.itemType, commodity.buyPrice, commodity.sellPrice 
	end for
	
	// Buy (1) Fuel button
	x = right - 20
	if game.fuel < game.maxFuel and game.money > costPerFuel then
		outer.buyFuelBtn = addBottomButton("Fuel ($" + costPerFuel + ")", x)
		buyFuelBtn.action = @buyFuel
	end if
	x = x - 120
	
	// Repair (1) button
	if game.hull < game.maxHull and game.money > costPerRepair then
		outer.repairButton = addBottomButton("Repair ($" + costPerRepair + ")", x)
		repairButton.action = @buyRepair
	end if
	x = x - 120
end function

printPanelTitle = function(text, station, left=550, bottom=150, height=400)
	top = bottom + height
	font = fonts.ArialBlack14
	font.setColor color.black
	font.print station.name + " Station : " + text, left+4, top-14
end function

showCantina = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	top = bottom + height

	printPanelTitle "CANTINA", station, left, bottom, height

	availableQuestBackground = new Panel
	availableQuestBackground.init left+40, bottom+40, width-80, height-100,
	   "availableQuestBackground", load9SliceImage("subPanel")
	availableQuestBackground.draw

	y = top - 136
	for npc in station.cantina
		addCantinaNPC left + 44, y, width - 88, 72, npc
		y = y - 74
	end for
end function

showNavButton = function()
	// navigation (depart/jump) button
	outer.navBtn = new Button
	navBtn.init 900, 610, 60, 30, "NAV"
	navBtn.backColor = color.black

	outer.navBtn.action = function()
		game.enterState Starfarer.STATE_NAVMAP
	end function
	
	navBtn.start
	activeButtons.push navBtn
end function

buyFuel = function()
	game.fuel = game.fuel + 1
	game.money = game.money - costPerFuel
	if game.fuel >= game.maxFuel  or game.money < costPerFuel then buyFuelBtn.stop
end function

buyRepair = function()
	game.hull = game.hull + 1
	game.money = game.money - costPerRepair
	if game.hull >= game.maxHull  or game.money < costPerFuel then repairButton.stop
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

NPCButton = new Button
NPCButton.npc = null  // a stationModel.CantinaNPC instance
NPCButton.backColor = color.silver
NPCButton.draw = function()
	super.draw
	dy = 0
	if self.state == Button.PRESSED then dy = -2
	disp.uiPixel.drawImage NPC_PORTRAIT, self.left + 4, self.bottom + 6 + dy, 64, 64
	fonts.ArialBlack14.printRight self.npc.name, self.right - 8, self.top - 14 + dy
end function

addCantinaNPC = function(left, bottom, width, height, npc)
	button = new NPCButton
	button.init left, bottom, width, height, "NPC Button"
	button.caption = null	// (we don't use captions; instead override draw)
	button.npc = npc
	button.action = function()
		npc.encounter.presentNPC npc
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_CANTINA
		stationUI.show npc.station
	end function
	button.start
	activeButtons.push button
	return button
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
	activeButtons.push btn
	
	// column 2: sell button
	btn = new Button
	btn.init col1_2 + 8, bottom + 4, right - col1_2 - 16, height - 8, 
	    "Sell ($" + sellPrice + ")"
	btn.backColor = background.mainColor
	btn.start
	btn.action = function()
		playerShip.outgoingTypes.push itemType
	end function
	activeButtons.push btn
	
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
