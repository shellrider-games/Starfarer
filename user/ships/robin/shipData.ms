
ship = new shipModel.Ship
globals.ship = ship

ship.directory = file.curdir
ship.init 6,9
ship.offset = [1,2]

ship.digRoom 0,0,6,8
ship.digRoom 2,8,2,1

ship.placeBottomWalls 0,0, 6
ship.placeBottomWalls 3,2, 1
ship.placeBottomWalls 1,4, 2
ship.placeBottomWalls 4,4, 1
ship.placeBottomWalls 0,5, 1
ship.placeBottomWalls 5,5, 1
ship.placeBottomWalls 3,6, 1
ship.placeBottomWalls 0,7, 1
ship.placeBottomWalls 5,7, 1
ship.placeBottomWalls 2,8, 1

ship.placeTopWalls 3,1, 1
ship.placeTopWalls 1,3, 2
ship.placeTopWalls 4,3, 1
ship.placeTopWalls 0,4, 1
ship.placeTopWalls 5,4, 1
ship.placeTopWalls 3,5, 1
ship.placeTopWalls 0,6, 1
ship.placeTopWalls 5,6, 1
ship.placeTopWalls 0,7, 3
ship.placeTopWalls 4,7, 2
ship.placeTopWalls 2,8, 2

ship.placeLeftWalls 0,0, 4
ship.placeLeftWalls 0,5, 3
ship.placeLeftWalls 2,0, 4
ship.placeLeftWalls 2,5, 4
ship.placeLeftWalls 4,0, 4
ship.placeLeftWalls 4,5, 3

ship.placeRightWalls 1,0, 4
ship.placeRightWalls 3,0, 4
ship.placeRightWalls 3,5, 3
ship.placeRightWalls 3,5, 4
ship.placeRightWalls 5,0, 4
ship.placeRightWalls 5,5, 3

ship.placeDoor 0,3, NORTH
ship.placeDoor 1,4, NORTH
ship.placeDoor 1,6, NORTH

//ship.placeDoor 3, 3, NORTH
//ship.placeDoor 5, 3, NORTH
//ship.placeDoor 4, 6, NORTH
//ship.placeDoor 1, 6, NORTH
//ship.placeDoor 7, 6, NORTH
//ship.placeDoor 1, 11, NORTH
//ship.placeDoor 8, 9, NORTH
//ship.placeDoor 2, 10, EAST

ship.getCell(0,4).type = Celltype.CARGO_IN
ship.getCell(5,4).type = Celltype.CARGO_OUT

//And for prototyping purposes: let's start out with some items, too.
//ship.map[0][0].placeItem new item.FoodItem
//ship.map[1][0].placeItem new item.GunsItem
//ship.map[1][1].placeItem new item.MedsItem
//ship.map[9][2].placeItem new item.WaterItem
//
ship.addSystem systems.Reactor.make(2,2)
//ship.addSystem systems.Controls.make(7,13)
//ship.addSystem systems.Engines.make(4,0)
//ship.addSystem systems.O2.make(3,11)
//ship.addSystem systems.Sensors.make(7,10)
//ship.addSystem systems.System.makeInvisible("shields", 4)
//ship.addSystem systems.System.makeInvisible("doors", 3)
//ship.addSystem systems.MedBay.make(1, 12)