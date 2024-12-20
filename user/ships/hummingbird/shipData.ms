if locals == globals then
	import "miscUtil"
	ensureImport "shipModel"
end if

ship = new shipModel.Ship
ship.name = "Hummingbird"

ship.directory = file.curdir
ship.init 3,5
ship.offset = [1,2]

ship.digRoom 0,0,3,4
ship.digRoom 0,4,2,1

ship.placeRoom 0, 4, 2, 1 // Control room at front of ship
ship.placeRoom 0, 2, 1, 2
ship.placeRoom 1, 3, 2, 1
ship.placeRoom 1, 2, 2, 1
ship.placeRoom 0, 0, 2, 2
ship.placeRoom 0, 2, 1, 2
ship.placeRoom 2, 0, 1, 2

// An example to remove an unwanted wall. 
//ship.removeWall 1, 1, EAST

ship.placeDoor 0, 4, SOUTH
ship.removeWall 0, 2, EAST
ship.placeDoor 0, 2, WEST
ship.placeDoor 2, 2, EAST
ship.placeDoor 1, 2, NORTH
ship.removeWall 2, 2, SOUTH
ship.placeDoor 1, 2, SOUTH

ship.getCell(0,2).type = Celltype.CARGO_IN
ship.getCell(2,2).type = Celltype.CARGO_OUT

ship.addSystem systems.Reactor.make(0,0)
ship.addSystem systems.Doors.make
//ship.addSystem systems.Engines.make(0,0)
ship.addSystem systems.Controls.make(0,4)
ship.addSystem systems.O2.make(1,3)

ship.cargoSpots = [[2,0], [2,1]]

if locals == globals then ship.draw