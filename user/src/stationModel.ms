
if not globals.hasIndex("setup") then import "setup"
if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("item") then import "item"

Station = {}
Station.name = "DEFAULT NAME"
Station.market = null		// a list of Commodity instances

Station.init = function(name, x = floor(rnd * 100), y = floor(rnd * 100))
	self.name = name
	self.market = []
end function

Commodity = {}
Commodity.itemType = null // an Item subclass defining the commodity type
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.name = function()
	return self.itemType.name
end function

Station.addCommodityToMarket = function(itemType, buyPrice, sellPrice)
	temporaryCommodity = new Commodity
	temporaryCommodity.itemType = itemType
	temporaryCommodity.buyPrice = buyPrice
	temporaryCommodity.sellPrice = sellPrice
	qa.assert self.market isa list
	self.market.push temporaryCommodity
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

	otherTestStation = new Station
	otherTestStation.init "Station 2"
	qa.assertEqual otherTestStation.market, []

end function

if locals == globals then runUnitTests
