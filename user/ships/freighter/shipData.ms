
ship = new shipModel.Ship
ship.name = "Freighter"

ship.directory = file.curdir
ship.init 10,14
ship.offset = [1,2]

ship.digRoom 0,0,10,7
ship.digRoom 1,7,2,7
ship.digRoom 3,7,3,5
ship.digRoom 6,7,3,3
ship.digRoom 7,10,2,4

ship.map[4][1] = null   //doing this causes the game to not work without any Error messages

ship.placeBottomWalls 0,0,10
ship.placeBottomWalls 0,4,3
ship.placeBottomWalls 4,4,1
ship.placeBottomWalls 6,4,4
ship.placeBottomWalls 2,7,2
ship.placeBottomWalls 5,7,2

ship.placeTopWalls 2,11,4
ship.placeTopWalls 8,6,2
ship.placeTopWalls 6,9,2
ship.placeTopWalls 0,6,1
ship.placeTopWalls 1,13,2
ship.placeTopWalls 7,13,2

ship.placeLeftWalls 0,0,7
ship.placeLeftWalls 1,7,7
ship.placeLeftWalls 7,10,4

ship.placeRightWalls 3,0,4
ship.placeRightWalls 2,7,7
ship.placeRightWalls 5,7,5
ship.placeRightWalls 8,7,7
ship.placeRightWalls 9,0,7

ship.placeDoor 3, 3, NORTH
ship.placeDoor 5, 3, NORTH
ship.placeDoor 4, 6, NORTH
ship.placeDoor 1, 6, NORTH
ship.placeDoor 7, 6, NORTH
ship.placeDoor 1, 11, NORTH
ship.placeDoor 8, 9, NORTH
ship.placeDoor 2, 10, EAST

ship.getCell(0,1).type = Celltype.CARGO_IN
ship.getCell(0,2).type = Celltype.CARGO_IN
ship.getCell(9,1).type = Celltype.CARGO_OUT

// And for prototyping purposes: let's start out with some items, too.
ship.map[0][0].placeItem new item.FoodItem
ship.map[1][0].placeItem new item.GunsItem
ship.map[1][1].placeItem new item.MedsItem
ship.map[9][2].placeItem new item.WaterItem

ship.addSystem systems.Reactor.make(4,2)
ship.addSystem systems.Controls.make(7,13)
ship.addSystem systems.Engines.make(4,0)
ship.addSystem systems.O2.make(3,11)
ship.addSystem systems.Sensors.make(7,10)
ship.addSystem systems.System.makeInvisible("shields", 4)
ship.addSystem systems.System.makeInvisible("doors", 3)
ship.addSystem systems.MedBay.make(1, 12)