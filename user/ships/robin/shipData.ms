
ship = new shipModel.Ship

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

ship.placeDoor 0,6, NORTH
ship.placeDoor 1,3, NORTH
ship.placeDoor 1,4, NORTH
ship.placeDoor 2,1, NORTH
ship.placeDoor 2,4, NORTH
ship.placeDoor 2,5, NORTH
ship.placeDoor 3,3, NORTH
ship.placeDoor 3,7, NORTH
ship.placeDoor 4,3, NORTH
ship.placeDoor 4,4, NORTH
ship.placeDoor 5,6, NORTH
ship.placeDoor 0,1, WEST
ship.placeDoor 0,4, WEST
ship.placeDoor 1,0, EAST
ship.placeDoor 1,7, EAST
ship.placeDoor 3,2, EAST
ship.placeDoor 3,6, EAST
ship.placeDoor 5,1, EAST
ship.placeDoor 5,4, EAST

ship.getCell(0,4).type = Celltype.CARGO_IN
ship.getCell(5,4).type = Celltype.CARGO_OUT

ship.addSystem systems.Reactor.make(2,2)
ship.addSystem systems.Engines.make(2,0)
ship.addSystem systems.Controls.make(2,8)
ship.addSystem systems.O2.make(0,7)
ship.addSystem systems.MedBay.make(4,5)
ship.addSystem systems.Weapons.make(0,5)

