// This is our path-finding module.  Its job is to figure out how to get
// from point A to point B on a ship map, and to do so as quickly as possible.
// Paths can include diagonal steps, and may cross doors, but may not cross
// walls or cells blocked by items.


// findPath: our main entry point, this function finds and returns a path
// between two points on a ship.  Return the path as a list of [col,row]
// positions to visit in order, including endPos but not including startPos.
// parameters:
//	ship: a shipModel object
//	startPos: a [col,row] starting position within the ship
//	endPos: a [col,row] target position to reach
findPath = function(ship, startPos, endPos)
	// Dummy implementation: ignore walls and obstacles, and just
	// walk directly to the end.  This is usually invalid!
	result = []
	pos = startPos
	while pos != endPos
		pos = [pos[0] + sign(endPos[0] - pos[0]),
		       pos[1] + sign(endPos[1] - pos[1])]
		result.push pos
	end while
	return result
end function

demo = function()
	clear
	
	import "shipModel"
	globals.shipModel = shipModel
	
	dir = pwd
	cd "/usr/ships/freighter"
	import "shipData"
	cd dir

	ship = shipData.ship
	ship.draw
	
	xAtPos = function(pos); return (pos[0]+0.5) * CELLSIZE; end function
	yAtPos = function(pos); return (pos[1]+0.5) * CELLSIZE; end function
	
	drawPath = function(path)
		lastx = xAtPos(path[0]); lasty = yAtPos(path[0])
		for p in path[1:]
			x = xAtPos(p); y = yAtPos(p)
			gfx.line lastx, lasty, x, y, "#44FF4488", 4
			lastx = x; lasty = y
		end for
	end function
	
	drawPath findPath(ship, [0,1], [7,12])
end function


if locals == globals then demo
