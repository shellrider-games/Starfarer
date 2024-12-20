if locals == globals then
	import "miscUtil"
	ensureImport "shipModel"
end if

ship = new shipModel.Ship
ship.name = "Wren"

ship.directory = file.curdir
ship.init 4,7
ship.offset = [1,2]

ship.digRoom 0,0,4,6
ship.digRoom 2,6,2,1

ship.placeRoom 2, 6, 2, 1 // Control room at front of ship
ship.placeRoom 0, 5, 2, 1
ship.placeRoom 2, 5, 2, 1
ship.placeRoom 0, 3, 2, 2
ship.placeRoom 2, 3, 2, 2
ship.placeRoom 0, 2, 4, 1 // central corridor
ship.placeRoom 0, 0, 2, 2
ship.placeRoom 2, 0, 2, 2

// An example to remove an unwanted wall. 
//ship.removeWall 1, 1, EAST

ship.placeDoor 3,5, NORTH
ship.placeDoor 0,4, NORTH
ship.placeDoor 2,4, NORTH
ship.placeDoor 1,2, NORTH
ship.placeDoor 2,2, NORTH
ship.placeDoor 0,2, WEST
ship.placeDoor 3,2, EAST
ship.placeDoor 0,1, NORTH
ship.placeDoor 3,1, NORTH

ship.getCell(0,2).type = Celltype.CARGO_IN
ship.getCell(3,2).type = Celltype.CARGO_OUT

ship.addSystem systems.Reactor.make(2,0)
ship.addSystem systems.Doors.make
ship.addSystem systems.Engines.make(0,0)
ship.addSystem systems.Controls.make(2,6)
ship.addSystem systems.O2.make(0,5)

for row in [4, 3]
	for col in [0, 1, 3]
		ship.cargoSpots.push [col, row]
	end for
end for

if locals == globals then ship.draw