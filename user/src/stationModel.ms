if not globals.hasIndex("qa") then import "qa"

defaultCrateImage = file.loadImage("/usr/pics/crate_blank.png")

Station = {}
Station.name = "DEFAULT NAME"
Station.market = []

Commodity = {}
Commodity.name = "DEFAULT NAME"
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.image = defaultCrateImage

Station.addCommodityToMarket = function(name, buyPrice, sellPrice, imagepath = null)
	temporaryCommodity = new Commodity
	temporaryCommodity.name = name
	temporaryCommodity.buyPrice = buyPrice
	temporaryCommodity.sellPrice = sellPrice
	if(imagepath != null) then temporaryCommodity.image = load(imagepath)
	self.market.push temporaryCommodity
end function

runUnitTests = function()
	testStation = new Station
	testCommodity = new Commodity
	qa.assertEqual testCommodity, {"__isa":{"name":"DEFAULT NAME","buyPrice":0,"sellPrice":0,"image":defaultCrateImage}}
	testStation.addCommodityToMarket("Water", 120, 100)
	qa.assertEqual testStation.market, [{"__isa": {"name":"DEFAULT NAME","buyPrice":0,"sellPrice":0,"image":defaultCrateImage},"name":"Water","buyPrice":120,"sellPrice":100}]
end function