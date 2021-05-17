// This module is responsible for generating random names for things.
// There are generic names, and there are also names for specific kinds
// of things (stations, humans, etc.).

import "listUtil"
import "stringUtil"

engWords = file.readLines("/sys/data/englishWords.txt")

// Generate a generic name we can use when we don't have anything better.
generic = function()
	// For now, we'll just pick a random word and capitalize it.
	return engWords.any.titleCase
end function

// Generate a good name for a star/planet/station.
station = function()
	return generic	// ToDo: something better here.
end function

demo = function()
	print "Generic names:"
	for i in range(9)
		print "  - " + generic
	end for
end function

if locals == globals then demo
