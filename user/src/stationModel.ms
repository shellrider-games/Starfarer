
if not globals.hasIndex("setup") then import "setup"
if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("item") then import "item"

Station = {}
Station.name = "DEFAULT NAME"
Station.market = null		// a list of Commodity instances
Station.navigatePoints = null	// let's remove this!
Station.init = function(name)
	self.name = name
	self.market = []
end function

Commodity = {}
Commodity.name = "DEFAULT NAME"
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.item = null // an Item subclass defining the commodity type

Station.addCommodityToMarket = function(name, buyPrice, sellPrice, item = null)
	temporaryCommodity = new Commodity
	temporaryCommodity.name = name
	temporaryCommodity.buyPrice = buyPrice
	temporaryCommodity.sellPrice = sellPrice
	if item != null then temporaryCommodity.item = item
	qa.assert self.market isa list
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
	testStation.init "Station 1"
	testCommodity = new Commodity
	testItem = new item.Item
	qa.assert testCommodity isa Commodity
	testStation.addCommodityToMarket "Water", 120, 100
	qa.assertEqual testStation.market.len, 1
	qa.assertEqual testStation.market[0].buyPrice, 120
	qa.assertEqual testStation.market[0].sellPrice, 100

	otherTestStation = new Station
	otherTestStation.init "Station 2"
	qa.assertEqual otherTestStation.market, []
//	connect testStation, otherTestStation
//	qa.assertEqual testStation.navigatePoints, [otherTestStation]
//	qa.assertEqual otherTestStation.navigatePoints, [testStation]
end function

if locals == globals then runUnitTests
