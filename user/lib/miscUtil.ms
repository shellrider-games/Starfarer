// Miscellaneous small helper functions that don't fit anywhere else.

import "importUtil"

// Get the maximum of two values
max = function(a,b)
	if a > b then return a else return b
end function

// Get the minimum of two values
min = function(a,b)
	if a < b then return a else return b
end function

// Get back the result of a die roll with a certain number of sides
rollDie = function(sides = 6)
	return ceil(rnd * sides)
end function

list.insertAfter = function(afterWhat, itemToAdd)
	idx = self.indexOf(afterWhat)
	self.insert idx+1, itemToAdd
end function

runUnitTests = function()
	ensureImport "qa"
	qa.assert max(2,5) == 5
	qa.assert max(5,2) == 5
	qa.assert min(2,5) == 2
	qa.assert min(5,2) == 2
	foo = [2, 4, 6, 8]
	foo.insertAfter 6, 7
	qa.assert foo == [2, 4, 6, 7, 8]
	print "miscUtil unit tests complete."
end function

if locals == globals then runUnitTests

	