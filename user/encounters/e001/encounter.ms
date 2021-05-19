// Our very first encounter!

// Consider whether we want to present this encounter while traveling
// to (if arriving=true) or from (arriving=false) the given station.
// If it's not a good time to present this encounter, return null.
// If it is, return a map containing the following data:
//		priority: 0 (unimportant), 1 (normal), 2 (crucial)
//		distance: how far (0-1) from the station this encounter should happen
// The host app will then decide whether to actually present this
// encounter.
consider = function(station, arriving)
	probability = 0.20
	if rnd > probability then return null
	result = {}
	result.priority = 0
	result.distance = 0.2 + 0.6 * rnd
	return result
end function

// If the host app decides to present this encounter, then it will call
// this present method:
present = function()
	print "Presenting E001!"

end function


if locals == globals then
	present
end if