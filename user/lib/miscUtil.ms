// Miscellaneous small helper functions that don't fit anywhere else.

if not globals.hasIndex("qa") then import "qa"

max = function(a,b)
	if a > b then return a else return b
end function

min = function(a,b)
	if a < b then return a else return b
end function


runUnitTests = function()
	qa.assert max(2,5) == 5
	qa.assert max(5,2) == 5
	qa.assert min(2,5) == 2
	qa.assert min(5,2) == 2
end function

if locals == globals then runUnitTests

	