if not globals.hasIndex("qa") then import "qa"

defaultCrateImage = file.loadImage("/usr/pics/crate_blank.png")

Station = {}
Station.market = []

Commodity = {}
Commodity.name = "DEFAULT NAME"
Commodity.buyPrice = 0
Commodity.sellPrice = 0
Commodity.image = defaultCrateImage

runUnitTests = function()
    testStation = new Station
    qa.assertEqual testStation , {"__isa":{"market":[]}}
    testCommodity = new Commodity
    qa.assertEqual testCommodity, {"__isa":{"name":"DEFAULT NAME","buyPrice":0,"sellPrice":0,"image":defaultCrateImage}}
end function