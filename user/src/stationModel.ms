if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("item") then import "item"

Station = {}
Station.name = "DEFAULT NAME"
Station.market = []
Station.navigatePoints = []

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

//Station.linkStation = function(station)
//	if station != self and self.navigatePoints.indexOf(station) == null then 
//		self.navigatePoints.push station
//	end if
//end function

//connect = function(station1, station2)
//	station1.linkStation(station2)
//	station2.linkStation(station1)
//end function

runUnitTests = function()
	testStation = new Station
	testCommodity = new Commodity
	testItem = new item.Item
	qa.assertEqual testCommodity, {"__isa":Commodity}
	testStation.addCommodityToMarket("Water", 120, 100)
	qa.assertEqual testStation.market, [{"__isa":Commodity ,"name":"Water","buyPrice":120,"sellPrice":100}]
//	otherTestStation = new Station
//	testStation.name = "Station 1"
//	otherTestStation.name = "Station 2"
//	connect testStation, otherTestStation
//	qa.assertEqual testStation.navigatePoints, [otherTestStation]
//	qa.assertEqual otherTestStation.navigatePoints, [testStation]
end function