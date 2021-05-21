// This file defines the base class for any encounter.  The base class
// provides common utility functions that most encounters will need, like
// drawing a dialog describing what's happening, giving the user response
// choices, etc.

Encounter = {}

// Consider presenting this encounter.  Subclasses will usually want to
// override this to apply a different probability, or to present only when
// certain game conditions are met.  Return null if you don't want to
// present; otherwise, return self.consideration (a little map that
// wraps up this encounter with other data that may be needed).
Encounter.consider = function(station, arriving)
	if rnd < 0.2 then return null
	return self.consideration(station, arriving)
end function

// This function creates the little map that returns this encounter for
// consideration on a particular journey.  Subclasses will not usually
// need to override this.
Encounter.consideration = function(station, arriving, priority=1, distance=null)
	data = {}
	data.encounter = self
	data.priority = priority
	if distance == null then distance = 0.2 + 0.6 * rnd
	data.distance = distance
	data.station = station
	data.arriving = arriving
	return data
end function

// This method is called when the encounter should be presented.
// The data given is the same object returned from consider().
// Subclasses will usually override this.
Encounter.present = function(data)

end function


