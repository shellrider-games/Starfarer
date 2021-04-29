
ship = new shipModel.Ship

ship.directory = file.curdir
ship.init 10,14
ship.offset = [1,2]

ship.digRoom 0,0,10,7
ship.digRoom 1,7,2,7
ship.digRoom 3,7,3,5
ship.digRoom 6,7,3,3
ship.digRoom 7,10,2,4

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
ship.placeLeftWalls 4,0,4
ship.placeLeftWalls 7,10,4

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
ship.placeDoor 2, 9, EAST

// And for prototyping purposes: let's start out with some items, too.
ship.map[0][0].contents = new shipModel.Item
ship.map[1][0].contents = new shipModel.Item
ship.map[1][1].contents = new shipModel.Item
ship.map[9][2].contents = new shipModel.Item


