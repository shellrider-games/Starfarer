if locals == globals then
	import "miscUtil"
	ensureImport "shipModel"
end if

ship = new shipModel.Ship
ship.name = "Robin"
ship.value = 20000

ship.directory = file.curdir
ship.init 6,9
ship.offset = [1,2]

ship.digRoom 0,0,6,8
ship.digRoom 2,8,2,1

ship.placeRoom 0, 7, 2, 1 // Oxygen room
ship.placeRoom 0, 5, 2, 2 // Weapons room
ship.placeRoom 0, 0, 2, 4 // Bottom Left room
ship.placeRoom 2, 0, 2, 2 // Engine room
ship.placeRoom 2, 2, 2, 2 // Electrical room?
ship.placeRoom 4, 0, 2, 4 // Bottom Right room
ship.placeRoom 2, 8, 2, 1 // Control room
ship.placeRoom 2, 5, 2, 1 // Center(?) room
ship.placeRoom 4, 5, 2, 2 // Medical room
ship.placeRoom 4, 7, 2, 1 // Above Medical room

// An example to remove an unwanted wall. 
//ship.removeWall 1, 1, EAST

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
ship.addSystem systems.Doors.make
ship.addSystem systems.Engines.make(2,0)
ship.addSystem systems.Controls.make(2,8)
ship.addSystem systems.O2.make(0,7)
ship.addSystem systems.MedBay.make(4,5)
ship.addSystem systems.Weapons.make(0,5)

for row in range(0,3)
	for col in [0, 1, 4, 5]
		ship.cargoSpots.push [col, row]
	end for
end for

if locals == globals then ship.draw