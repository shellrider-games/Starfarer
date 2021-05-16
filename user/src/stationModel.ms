
if not globals.hasIndex("setup") then import "setup"
if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("item") then import "item"
if not globals.hasIndex("randomNames") then import "randomNames"
import "mathUtil"

Station = {}
Station.name = "DEFAULT NAME"
Station.market = null		// a list of Commodity instances
Station.x = null
Station.y = null

Station.init = function(name, x = floor(rnd * 100), y = floor(rnd * 100))
	self.name = name
	self.market = []
	self.x = x
	self.y = y
end function

Commodity = {}
Commodity.itemType = null // an Item subclass defining the commodity type
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.name = function()
	return self.itemType.name
end function

Station.addCommodityToMarket = function(itemType, buyPrice, sellPrice)
	newCommodity = new Commodity
	newCommodity.itemType = itemType
	newCommodity.buyPrice = buyPrice
	newCommodity.sellPrice = sellPrice
	qa.assert self.market isa list
	self.market.push newCommodity
end function

Station.getCommodityBuyPrice = function(itemType)
	for commodity in self.market
		if commodity.itemType.name == itemType then return commodity.buyPrice
	end for
	return null
end function

Station.getCommoditySellPrice = function(itemType)
	for commodity in self.market
		if commodity.itemType.name == itemType then return commodity.sellPrice
	end for
	return null
end function

randomStation = function()
	result = new Station
	result.init randomNames.station
	for type in [item.FoodItem, item.WaterItem, item.MedsItem, item.GunsItem]
		if rnd < 0.1 then continue	// commodity not traded here
		value = floor(type.typicalValue * (1 + mathUtil.randNormal/4))
		markup = floor(rnd * value)	
		result.addCommodityToMarket type, value, markup
	end for
	return result
end function

runUnitTests = function()
	testStation = new Station
	testStation.init "Station 1"
	testCommodity = new Commodity
	testItem = new item.Item
	qa.assert testCommodity isa Commodity
	testStation.addCommodityToMarket item.WaterItem, 120, 100
	qa.assertEqual testStation.market.len, 1
	qa.assertEqual testStation.market[0].itemType, item.WaterItem
	qa.assertEqual testStation.market[0].name, "water"
	qa.assertEqual testStation.market[0].buyPrice, 120
	qa.assertEqual testStation.market[0].sellPrice, 100
	
	qa.assertEqual testStation.getCommodityBuyPrice(item.WaterItem.name), 120
	qa.assertEqual testStation.getCommoditySellPrice(item.WaterItem.name), 100

	otherTestStation = new Station
	otherTestStation.init "Station 2", 10, 10
	qa.assertEqual otherTestStation.market, []
	qa.assertEqual otherTestStation.x, 10
	qa.assertEqual otherTestStation.y, 10

end function

if locals == globals then runUnitTests
