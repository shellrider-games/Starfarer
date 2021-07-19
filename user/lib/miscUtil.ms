// Miscellaneous small helper functions that don't fit anywhere else.

// ensureImport: check whether the given module has been imported already
// (or is in the process of being imported).  If so, return immediately.
// If not, then import that module into the global namespace.
globals.ensureImport = function(moduleName)
	if globals.hasIndex(moduleName) then return
	//print "ensureImport(" + moduleName + ") called from " + stackTrace[1]
	globals[moduleName] = "PENDING"	// (module is being imported now)
	import moduleName
	globals[moduleName] = locals[moduleName]
end function

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

runUnitTests = function()
	ensureImport "qa"
	qa.assert max(2,5) == 5
	qa.assert max(5,2) == 5
	qa.assert min(2,5) == 2
	qa.assert min(5,2) == 2
end function

if locals == globals then runUnitTests

	