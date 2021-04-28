// This is the data model for a ship (either the player ship, or an
// NPC ship).  It contains everything we need to know about its layout,
// equipment, and current status.

import "qa"
import "listUtil"

// Item: represents anything that can be placed in (or removed from)
// a map cell.
Item = {}
Item.name = "item"
Item.blocksWalking = true

// Wall: an ordinary wall between cells.  Considered unbreachable.
Wall = {}
Wall.name = "wall"
Wall.isOpen = false

// Door: a wall that can open and close.
Door = {}
Door.name = "door"
Door.isOpen = true

// Cell class: information about one map cell, including whether it is
// walkable, what equipment or cargo is there, whether it is on fire,
// its air quality, etc.
Cell = {}
Cell.contents = null		// an Item instance, or null
Cell.col = 0				// column within its ship map
Cell.row = 0				// row within its ship map
Cell.air = 100				// air quality, from 0 (vacuum) - 100 (fine)
Cell.fire = 0				// on fire? 0 (nope) to 100 (raging inferno)
Cell.above = Wall			// wall or door on the top (north) side of this cell
Cell.right = Wall			// wall or door on the right (east) side of this cell

// Cell.walkable: returns whether an agent can step into this cell.
Cell.walkable = function()
	return self.contents == null or not self.contents.blocksWalking
end function

Cell.canExitUp = function()
	return self.above == null or self.above.isOpen
end function

Cell.canExitRight = function()
	return self.right == null or self.right.isOpen
end function

// Ship: everything there is to know about a ship.
Ship = {}
Ship.maxHp = 20			// hull points (basically ship health)
Ship.hp = Ship.maxHp
Ship.jumpFuel = 5		// how many jumps we can make before refueling

// Ship.init: initialize this ship with a blank map.  The map is initialized
// to all nulls, meaning not usable by any means (i.e. not part of the ship
// interior).  See the methods below to procedurally set up rooms etc.
Ship.init = function(columns, rows)
	// set up a map, as a 2D array of Cells (or null) indexed as [column][row]
	self.columns = columns
	self.rows = rows
	self.columnRange = range(0, columns-1)
	self.rowRange = range(0, rows-1)
	self.map = list.init2d(columns, rows)
end function

// Ship.digRoom: clear a room on the map.
Ship.digRoom = function(left, bottom, width, height)
	for col in range(left, left+width-1)
		for row in range(bottom, bottom+height-1)
			c = new Cell
			c.col = col; c.row = row
			if col < left+width-1 then c.right = null
			if row < bottom+height-1 then c.above = null
			self.map[col][row] = c
		end for
	end for
end function

// Ship.walkable: return whether an agent can step in the given
// position (given as a [column, row] list).  In other words: is the
// given position in bounds, and a walkable Cell?
Ship.walkable = function(colRow)
	if colRow[0] < 0 or colRow[0] >= self.columns then return false
	if colRow[1] < 0 or colRow[1] >= self.rows then return false
	c = self.map[colRow[0]][colRow[1]]
	return c != null and c.walkable
end function

// Ship.walkableNeighbors: return a list of [col,row] positions
// which can be entered from the given [col,row] point on the map.
// That means neighbors that are walkable, without a wall or
// closed door in between.
Ship.walkableNeighbors = function(colRow)
	result = []
	col = colRow[0]; row = colRow[1]
	c = self.map[col][row]
	if c.canExitUp and self.walkable([col, row+1]) then result.push [col, row+1]
	if c.canExitRight and self.walkable([col+1, row]) then result.push [col+1, row]
	if self.walkable([col, row-1]) and self.map[col][row-1].canExitUp then
		result.push [col, row-1]
	end if
	if self.walkable([col-1, row]) and self.map[col-1][row].canExitRight then
		result.push [col-1, row]
	end if
	return result
end function

Ship.print = function()
	text.delimiter = " "
	print
	for row in range(self.rows-1, 0)
		for col in self.columnRange
			if self.map[col][row] == null then print "X" else print "."
		end for
		print char(13)
	end for
	text.delimiter = char(13)
	print
end function

demo = function()
	outer.s = new Ship
	s.init 10,6
	s.digRoom 4,1, 3,2
	s.print
	print "Neighbors of [4,1]: " + s.walkableNeighbors([4,1])
	print "Neighbors of [5,1]: " + s.walkableNeighbors([5,1])
end function

if locals == globals then demo
