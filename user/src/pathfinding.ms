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
	// A* + Heuristics pathfinding implementation
	if startPos isa map then startPos = [startPos.col,startPos.row]
	if endPos isa map then endPos = [endPos.col,endPos.row]

	//True distance function for diagnanols
	heuristic = function(endPos, nextPos)
	    a = endPos[0] - nextPos[0]
		b = endPos[1] - nextPos[1]
		return sqrt(a^2 + b^2)
	end function


	check = []
	check.push [startPos,0]
	camefrom = {}
	camefrom[startPos] = null
	cellCosts = {}
	cellCosts[startPos] = 0
	while check
		current = check.pull[0]

		if current == endPos then
			break
		end if
		
		for nextCellPos in ship.walkableNeighbors(current)
			cost = cellCosts[current] + heuristic(nextCellPos, current)
			if not cellCosts.hasIndex(nextCellPos) or cost < cellCosts[nextCellPos] then
				cellCosts[nextCellPos] = cost
				i = 0
				while i < check.len
					if check[i][1] > cost then break
					i = i + 1
				end while
				check.insert i, [nextCellPos, cost]
				camefrom[nextCellPos] = current
			end if
		end for
	end while

	current = endPos
	result = []
	if camefrom.hasIndex(current) then
		while current != startPos
			result.push current
			current = camefrom[current]
		end while
		result.reverse
	end if
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
		if path and path.len>1 then
			lastx = xAtPos(path[0]); lasty = yAtPos(path[0])
			for p in path[1:]
				x = xAtPos(p); y = yAtPos(p)
				gfx.line lastx, lasty, x, y, "#44FF4488", 4
				lastx = x; lasty = y
			end for
		end if
	end function
	drawPath findPath(ship, [2,12], [7,12])

end function


if locals == globals then demo
