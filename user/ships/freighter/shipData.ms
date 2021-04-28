
ship = new shipModel.Ship
ship.init 10,14

ship.digRoom 0,0,10,7
ship.digRoom 1,7,2,7
ship.digRoom 3,7,3,5
ship.digRoom 6,7,3,3
ship.digRoom 7,10,2,4

ship.placeBottomWalls 0,0,10
ship.placeBottomWalls 0,4,3
ship.placeBottomWalls 6,4,4
ship.placeBottomWalls 3,7,1
ship.placeBottomWalls 5,7,1

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

ship.placeDoor 4, 6, NORTH
