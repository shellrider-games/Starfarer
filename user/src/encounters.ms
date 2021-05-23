// This module is responsible for loading, considering, and presenting
// encounters as the player ship travels from station to station.
// The actual encounters are defined by the tiny modules in /usr/encounters.

import "encounterBase"
globals.encounterBase = encounterBase

encounterList = []

init = function()
	outer.encounterList = []
	loadEncountersFromFolder "/usr/encounters"
end function

loadEncountersFromFolder = function(path)
	for child in file.children(path)
		fullPath = file.child(path, child)
 		if child == "encounter.ms" then
			loadOneEncounter path, child
		else if file.info(fullPath).isDirectory then
			loadEncountersFromFolder fullPath
		end if
	end for
end function

loadOneEncounter = function(parentPath, filename)
	// On WebGL, file.children appends a trailing "/" to directory names.
	// But import doesn't like that (on its importPaths).  So, we'll just
	// subtract the "/", and that will strip it off, if found.
	env.importPaths.insert 0, parentPath - "/"
	filename = filename - ".ms"
	import filename
	env.importPaths.remove 0
	content = locals[filename]
	content.encounter.sourcePath = file.child(parentPath, filename + ".ms")
	encounterList.push content.encounter
end function

planEncounters = function(sourceStation, destStation)
	// first gather all the encounters we might present
	possibilities = []
	for enc in encounterList
		cons = enc.consider(sourceStation, false)
		if cons != null then
			cons.time = cons.distance * 2
			cons.encounter = enc
			possibilities.push cons
		end if
		cons = enc.consider(destStation, true)
		if cons != null then
			cons.time = 4 - cons.distance * 2
			cons.encounter = enc
			possibilities.push cons
		end if
	end for
		
	// then pick which ones to actually present, and sort them by time
	outer.pending = []
	outer.elapsed = 0
	if not possibilities then return
	// For now, we'll just shuffle and take the first 1-3.
	// ToDo: pay attention to priority.
	max = ceil(rnd*3)
	outer.pending = possibilities
	if pending.len > max then
		pending.shuffle
		pending = pending[:max]
	end if
	pending.sort "time"
end function

update = function(dt)
	if not pending then return
	outer.elapsed = elapsed + dt
	if elapsed > pending[0].time then
		event = pending.pull
		event.encounter.present event
	end if
end function

init
	
if locals == globals then
	print "Loaded " + encounterList.len + " encounters,"
	print "from " + encounterList[0].sourcePath
	print "  to " + encounterList[-1].sourcePath
end if