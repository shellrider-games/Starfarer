// This file defines constants for use by the entire game, and some very tiny
// methods that relate to those constants.

// Name constants in ALL_CAPS to distinguish them from normal classes,
// methods, or variables.

// Note too that any commonly-needed constants are stuffed into the global
// namespace, so they can be used without a prefix.

if not globals.hasIndex("qa") then import "qa"

// Directions:
// In the context of a screen, "north" is towards the top of the screen.
// In the context of a ship, "north" is the front (fore) end of the ship.
globals.EAST = 0
globals.NORTH = 1
globals.WEST = 2
globals.SOUTH = 3
globals.DIRECTIONS = range(0,3)

dx = function(dir)
	return (dir == EAST) - (dir == WEST)
end function

dy = function(dir)
	return (dir == NORTH) - (dir == SOUTH)
end function

// dirFromDelta: get a direction in the range of EAST to SOUTH (i.e. from 0 up to 4)
// that corresponds to the given delta position.  If you want a cardinal direction,
// just round() the result.
dirFromDelta = function(dy, dx)
	return ((atan(dy, dx) * 2/pi) + 4) % 4
end function

inverseDir = function(dir)
	return (dir + 2) % 4
end function

// Graphical/layout constants
globals.CELLSIZE = 20		// size of one map cell, in pixels

//Celltype globals for better readability
globals.Celltype = {}
Celltype.STANDARD = 0
Celltype.CARGO_EXCHANGE = 1

runUnitTests = function()
	qa.assertEqual inverseDir(globals.EAST), globals.WEST
	qa.assertEqual inverseDir(globals.WEST), globals.EAST
	qa.assertEqual inverseDir(globals.SOUTH), globals.NORTH
	qa.assertEqual inverseDir(globals.NORTH), globals.SOUTH

	qa.assertEqual dx(globals.EAST), 1
	qa.assertEqual dx(globals.WEST), -1
	qa.assertEqual dx(globals.NORTH), 0
	qa.assertEqual dx(globals.SOUTH), 0

	qa.assertEqual dy(globals.EAST), 0
	qa.assertEqual dy(globals.WEST), 0
	qa.assertEqual dy(globals.NORTH), 1
	qa.assertEqual dy(globals.SOUTH), -1

	qa.assertEqual dirFromDelta(1,1), 0.5
	qa.assertEqual dirFromDelta(-1,-1), 2.5
	qa.assertEqual dirFromDelta(1,-1), 1.5
	qa.assertEqual dirFromDelta(-1, 1), 3.5

end function