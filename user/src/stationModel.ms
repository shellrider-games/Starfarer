
if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "setup"
ensureImport "qa"
ensureImport "item"
ensureImport "randomNames"
ensureImport "mathUtil"
ensureImport "pics"

governments = ["Anarchy", "Democracy", "Technocracy", "Theocracy"]
techLevels = ["Primitive", "Agrarian", "Industrial", "Post-Industrial", "Modern"]
howMany = ["None", "Few", "Some", "Many", "Swarms"]  // how many police/pirates, 0-4

Station = {}
Station.name = "DEFAULT NAME"
Station.market = null		// a list of Commodity instances
Station.cantina = null		// a list of NPCs currently in cantina
Station.x = null
Station.y = null
Station.government = governments[1]
Station.techLevel = techLevels[-1]
Station.illegalTypes = []
Station.exportTypes = []
Station.police = 0		// 0-4
Station.pirates = 0		// 0-4

Station.init = function(name, x, y)
	if x == null then x = floor(rnd * 100)
	if y == null then y = floor(rnd * 100)
	self.name = name
	self.market = []
	self.cantina = []
	self.x = x
	self.y = y
	self.government = governments.any
	self.techLevel = techLevels.any
	self.police = round(mathUtil.randRange(0, 4))
	self.pirates = round(mathUtil.randRange(0, 4))
	
	self.exportTypes = []
	if self.techLevel == "Primitive" then
		self.exportTypes.push ["water", "wood", "ore"].any
	else if self.techLevel == "Agrarian" then
		self.exportTypes.push ["water", "food"].any
	else if self.techLevel == "Industrial" then
		self.exportTypes.push ["water", "food", "wood", "ore"].any
	else if self.techLevel == "Post-Industrial" then
		self.exportTypes.push ["water", "food", "ore", "medicine", "machines"].any
	else
		self.exportTypes.push ["medicine", "games", "machines", "robots"].any
	end if
	
	if self.government == "Technocracy" then
		self.techLevel = "Modern"
		self.illegalTypes = ["robots", "narcotics"]
		self.exportTypes = ["machines"]
	else if self.government == "Theocracy" then
		self.illegalTypes = ["games", "firearms", "narcotics"]
		self.police = 4
	else if self.government == "Democracy" then
		self.illegalTypes = ["firearms", "narcotics"]
		self.exportTypes = []
		self.exportTypes.push ["medicine", "games", "machines", "robots"].any
	else if self.government == "Anarchy" then
		self.illegalTypes = []
		self.police = 0
	else
		self.illegalTypes == ["narcotics"]
	end if
	
end function

Commodity = {}
Commodity.itemType = null // an Item subclass defining the commodity type
Commodity.itemPrice = 0
Commodity.soldHere = true
Commodity.name = function()
	return self.itemType.name
end function

CantinaNPC = {}
CantinaNPC.name = "Placeholder"
CantinaNPC.portrait = pics.portrait.human.any
CantinaNPC.encounter = null

Station.fillCantina = function()
	self.cantina = []
	encounters.addNPCsToCantina self
end function

Station.addCommodityToMarket = function(itemType, unadjustedPrice, isSold)
	qa.assert itemType isa Item and unadjustedPrice isa number
	itemPrice = unadjustedPrice
	if self.exportTypes.contains(itemType.name) then  itemPrice *= mathUtil.randRange(0.5, 0.9)
	if self.illegalTypes.contains(itemType.name) then itemPrice *= mathUtil.randRange(1.1, 2)
	newCommodity = new Commodity
	newCommodity.itemType = itemType
	newCommodity.itemPrice = round(itemPrice)
	newCommodity.soldHere = isSold
	qa.assert self.market isa list
	self.market.push newCommodity
end function

Station.getCommodityBuyPrice = function(itemType)
	qa.assert itemType isa item.Item
	for commodity in self.market
		if commodity.itemType.name == itemType.name then return commodity.itemPrice
	end for
	return null
end function

Station.getCommoditySellPrice = function(itemType)
	qa.assert itemType isa item.Item
	for commodity in self.market
		if commodity.itemType.name == itemType.name then return commodity.itemPrice
	end for
	return null
end function

// closestStation: return the station in stationList closest to the given
// point (a map containing x and y properties)
closestStation = function(xyPoint, stationList)
	if not stationList then return null
	best = stationList[0]
	if stationList.len < 2 then return best
	bestDist = mathUtil.distance(xyPoint, best)
	for i in range(1, stationList.len-1)
		dist = mathUtil.distance(xyPoint, stationList[i])
		if dist < bestDist then
			best = stationList[i]
			bestDist = dist
		end if
	end for
	return best
end function

// Generate a random station.
randomStation = function()
	result = new Station
	result.init randomNames.station
	result.x = round(mathUtil.randRange(80, 880))
	result.y = round(mathUtil.randRange(80, 590))
	result.starIsGiant = (rnd < 0.3)
	result.starTypeRow = floor(mathUtil.randRange(0, 3))
	result.starTypeCol = floor(mathUtil.randRange(0, 4))
	if result.starIsGiant then
		result.starTypeCol = result.starTypeCol + 4
		result.starSize = mathUtil.randRange(0.6, 1)
	else
		result.starSize = mathUtil.randRange(0.25, 0.5)
	end if
	for type in item.allTypes
		isSold = (rnd < 0.9)
		if result.exportTypes.contains(type.name) then isSold = true
		if result.illegalTypes.contains(type.name) then isSold = false
		value = floor(type.typicalValue * (1 + mathUtil.randNormal/4))
		result.addCommodityToMarket type, value, isSold
	end for
	return result
end function

// Generate a whole bunch of random stations, ensuring that no two stations
// are too close to each other.
manyRandomStations = function(quantity=30)
	result = []
	for i in range(1, quantity)
		while true
			noob = randomStation
			closest = closestStation(noob, result)
			if closest == null or mathUtil.distance(closest, noob) > 50 then break
		end while
		// Note: we won't fill the cantinas now; instead we will do
		// that for each cantina when we land, so they can respond
		// easily to the changing conditions of the game.
		result.push noob
	end for
	return result
end function

runUnitTests = function()
	testStation = new Station
	testStation.init "Station 1"
	testCommodity = new Commodity
	testItem = new item.Item
	qa.assert testCommodity isa Commodity
	testStation.addCommodityToMarket item.WaterItem, 120
	qa.assertEqual testStation.market.len, 1
	qa.assertEqual testStation.market[0].itemType, item.WaterItem
	qa.assertEqual testStation.market[0].name, "water"
	qa.assertEqual testStation.market[0].itemPrice, 120
	
	qa.assertEqual testStation.getCommodityBuyPrice(item.WaterItem), 120
	qa.assertEqual testStation.getCommoditySellPrice(item.WaterItem), 120

	otherTestStation = new Station
	otherTestStation.init "Station 2", 10, 10
	qa.assertEqual otherTestStation.market, []
	qa.assertEqual otherTestStation.x, 10
	qa.assertEqual otherTestStation.y, 10

end function

if locals == globals then runUnitTests
