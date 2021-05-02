// This file defines constants for use by the entire game, and some very tiny
// methods that relate to those constants.

// Name constants in ALL_CAPS to distinguish them from normal classes,
// methods, or variables.

// Note too that any commonly-needed constants are stuffed into the global
// namespace, so they can be used without a prefix.

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
	return atan(dy, dx) * 2/pi
end function

inverseDir = function(dir)
	return [WEST, SOUTH, EAST, NORTH][dir]
end function

// Graphical/layout constants
globals.CELLSIZE = 20		// size of one map cell, in pixels

globals.Celltype = {}
Celltype.STANDARD = 0
Celltype.CARGO_EXCHANGE = 1