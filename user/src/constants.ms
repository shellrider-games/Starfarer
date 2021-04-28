// This file defines constants for use by the entire game, and some very tiny
// methods that relate to those constants.

// Name constants in ALL_CAPS to distinguish them from normal classes,
// methods, or variables.

// Note too that any commonly-needed constants are stuffed into the global
// namespace, so they can be used without a prefix.

// Directions:
// In the context of a screen, "north" is towards the top of the screen.
// In the context of a ship, "north" is the front (fore) end of the ship.
globals.NORTH = 0
globals.EAST = 1
globals.SOUTH = 2
globals.WEST = 3
globals.DIRECTIONS = range(0,3)

dx = function(dir)
	return (dir == EAST) - (dir == WEST)
end function

dy = function(dir)
	return (dir == NORTH) - (dir == SOUTH)
end function
