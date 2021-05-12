if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("item") then import "item"

defaultCrateImage = file.loadImage("/usr/pics/crate_blank.png")

Station = {}
Station.name = "DEFAULT NAME"
Station.market = []

Commodity = {}
Commodity.name = "DEFAULT NAME"
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.item = new item.Item

Station.addCommodityToMarket = function(name, buyPrice, sellPrice, item = null)
	temporaryCommodity = new Commodity
	temporaryCommodity.name = name
	temporaryCommodity.buyPrice = buyPrice
	temporaryCommodity.sellPrice = sellPrice
	if item != null then temporaryCommodity.item = item
	self.market.push temporaryCommodity
end function

runUnitTests = function()
	testStation = new Station
	testCommodity = new Commodity
	testItem = new item.Item
	qa.assertEqual testCommodity, {"__isa":Commodity}
	testStation.addCommodityToMarket("Water", 120, 100)
	qa.assertEqual testStation.market, [{"__isa":Commodity ,"name":"Water","buyPrice":120,"sellPrice":100}]
end function