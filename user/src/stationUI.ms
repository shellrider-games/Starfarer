// This module implements the "station" user interface, which appears on
// the right half of the screen when the ship is docked at a station or base.
// It presents the various station services, including the market.

import "importUtil"
ensureImport "stringUtil"
ensureImport "listUtil"
ensureImport "qa"
ensureImport "uiWidgets"
ensureImport "item"
ensureImport "stationModel"


costPerFuel = 10
costPerRepair = 15

SHOW_MARKET = 0
SHOW_CANTINA = 1
SHOW_SHIPYARD = 2

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
	if currentTab == SHOW_SHIPYARD then showShipyard station, left, bottom, width, height
	
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
	marketTabButton.action = function()
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_MARKET
		stationUI.show station
	end function
	
	cantinaTabButton = new TabButton
	cantinaTabButton.init left+100, bottom, 98, height, "Cantina"
	if currentTab == SHOW_CANTINA then cantinaTabButton.state = Button.PRESSED
	cantinaTabButton.action = function()
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_CANTINA
		stationUI.show station
	end function

	shipyardTabButton = new TabButton
	shipyardTabButton.init left+200, bottom, 98, height, "Shipyard"
	if currentTab == SHOW_SHIPYARD then shipyardTabButton.state = Button.PRESSED
	shipyardTabButton.action = function()
		stationUI.resetTab self
		stationUI.setCurrentTab stationUI.SHOW_SHIPYARD
		stationUI.show station
	end function

	printCurrentTab = function()
		print outer.currentTab
	end function

	for tab in [marketTabButton, cantinaTabButton, shipyardTabButton]
		outer.tabs.push tab
		tab.start
	end for

end function

showMarket = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	top = bottom + height
	
	printPanelTitle "MARKET", station, left, bottom, height
	
	y = top - 60

	for commodity in station.market
		y = y - 40
		allPrices = []
		for st in game.stations
			price = st.getCommoditySellPrice(commodity.itemType)
			if price != null then allPrices.push price
		end for
		avgPrice = round(allPrices.mean)
		addCommodity left, y, width, 40, commodity.itemType, commodity.itemPrice, avgPrice
	end for
	
	// Buy (1) Fuel button
	x = right - 20
	if game.fuel < game.maxFuel and game.money > costPerFuel then
		outer.buyFuelBtn = addBottomButton("Fuel ($" + costPerFuel + ")", x)
		buyFuelBtn.action = @buyFuel
	end if
	x = x - 120
	
	// Repair (1) button
	if playerShip.hp < playerShip.maxHp and game.money > costPerRepair then
		outer.repairButton = addBottomButton("Repair ($" + costPerRepair + ")", x)
		repairButton.action = @buyRepair
	end if
	x = x - 120
end function

printPanelTitle = function(text, station, left=550, bottom=150, height=400)
	top = bottom + height
	font = fonts.ArialBlack14
	font.print station.name + " Station : " + text, left+4, top-14, 1, color.black
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

showShipyard = function(station,left=550, bottom=150, width=350, height=400)
	right = left + width
	midx = left + width/2
	top = bottom + height

	printPanelTitle "SHIPYARD", station, left, bottom, height

	font = fonts.ArialBlack14
	y = top - 40
	
	font.print "System Upgrades:", left+20, y;	y = y - 50
	col = 0
	outer.upgradeButtons = []
	for sys in playerShip.systems
		if not sys.canUpgrade then continue
		if sys.upgradeCost > game.money then continue
		button = new Button
		if col==0 then x = midx - 160 else x = midx + 10
		button.init x, y, 150, 30, sys.name + " ($" + sys.upgradeCost + ")"
		button.backColor = background.mainColor
		button.system = sys
		button.action = @upgradeButtonAction
		button.start
		upgradeButtons.push button
		col = 1 - col
		if col == 0 then y = y - 32
	end for
end function

upgradeButtonAction = function()
	game.money -= self.system.upgradeCost
	self.system.upgrade
	for i in range(upgradeButtons.len - 1)
		btn = upgradeButtons[i]
		if not btn.system.canUpgrade or btn.system.upgradeCost > game.money then
			btn.stop
			upgradeButtons.remove i
		else
			btn.caption = btn.system.name + " ($" + btn.system.upgradeCost + ")"
			btn.redraw
		end if
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
	game.money -= costPerFuel
	if game.fuel >= game.maxFuel  or game.money < costPerFuel then buyFuelBtn.stop
end function

buyRepair = function()
	playerShip.hp = playerShip.hp + 1
	game.money -= costPerRepair
	if playerShip.hp >= playerShip.maxHp or game.money < costPerFuel then repairButton.stop
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
	fonts.ArialBlack14.printRight self.npc.name, self.right - 8, self.top - 14 + dy,
			1, color.black
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
addCommodity = function(left, bottom, width, height, itemType, price, avgPrice)
	qa.assert itemType isa item.Item
	
	// column positions:
	btnWidth = 48
	right = left + width
	x = [left + 8, left + width * 0.4, right - btnWidth*2 - 16, right - btnWidth - 8]
	midY = bottom + height/2
	
	// column 0: name and icon
	disp.uiPixel.drawImage itemType.image, x[0], midY-16, 32, 32
	fonts.ArialBlack14.print itemType.name, x[0] + 40, midY - 6, 1, color.black
	
	// column 1: price (and difference from average price)
	gfx.color = color.black
	fonts.Arial14.print "$" + price, x[1], midY - 6, 1, color.black
	diff = price - avgPrice
	if diff >= 0 then sign = "+" else sign = "-"
	fonts.Arial14.print "(" + sign + abs(diff) + ")", x[1] + 40, midY - 6, 1, color.gray
		
	// column 3: sell button
	sellBtn = new Button
	sellBtn.init x[3], bottom + 4, btnWidth, height - 8, "Sell"
	sellBtn.backColor = background.mainColor
	sellBtn.enabled = playerShip.qtyOwnedOfType(itemType) > 0
	sellBtn.start
	sellBtn.action = function()
		playerShip.noteItemSold itemType
		sellBtn.enabled = playerShip.qtyOwnedOfType(itemType) > 0
		sellBtn.draw
	end function
	activeButtons.push sellBtn
	
	// column 2: buy button
	buyBtn = new Button
	buyBtn.init x[2], bottom + 4, btnWidth, height - 8, "Buy"
	buyBtn.backColor = background.mainColor
	buyBtn.start
	buyBtn.action = function
		playerShip.addPurchasedItemType itemType
		sellBtn.enabled = playerShip.qtyOwnedOfType(itemType) > 0
		sellBtn.draw
	end function
	activeButtons.push buyBtn

end function


//----------------------------------------------------------------------
// Demo/testing functions
//----------------------------------------------------------------------
demo = function()
	disp.uiPixel.clear
	disp.uiSprites.clear
	text.clear

	globals.game = {}
	game.fuel = 10
	game.maxFuel = 12
	game.money = 1000
	globals.playerShip = {}
	playerShip.hp = 15
	playerShip.maxHp = 20
	playerShip.qty = {}
	playerShip.qty[item.FoodItem.name] = 3
	playerShip.qty[item.WaterItem.name] = 10
	playerShip.qty[item.MedsItem.name] = 1
	playerShip.qty[item.GunsItem.name] = 0
	playerShip.qtyOwnedOfType = function(type)
		return self.qty[type.name]
	end function
	playerShip.addPurchasedItemType = function(type)
		self.qty[type.name] += 1
	end function
	playerShip.noteItemSold = function(type)
		self.qty[type.name] -= 1
	end function

	station = new stationModel.Station
	station.init "SUPER COOL SPACE STATION - 7"
	station.addCommodityToMarket item.FoodItem, 80, 50
	station.addCommodityToMarket item.WaterItem, 120, 125
	station.addCommodityToMarket item.MedsItem, 200, 150
	station.addCommodityToMarket item.GunsItem, 183, 200

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
