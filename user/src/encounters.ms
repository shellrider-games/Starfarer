// This module is responsible for loading, considering, and presenting
// encounters as the player ship travels from station to station.
// The actual encounters are defined by the tiny modules in /usr/encounters.

import "miscUtil"
ensureImport "encounterBase"
ensureImport "log"
ensureImport "stationModel"

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

spaceOutTimes = function(items, startIdx, endIdx, minTime, maxTime)
	// Try to spread out the .time values of items[startIdx:endIdx]
	// such that no two are closer than 0.5 apart, BUT do not allow
	// any of them to exceed the range [minTime, maxTime].
	if endIdx - startIdx < 2 then return
	gap = 0.5

	// Save original times in case we need to fall back.
	origTimes = []
	for i in range(startIdx, endIdx-1)
		origTimes.push items[i].time
	end for

	// Forward pass: push items right to maintain minimum gap.
	for i in range(startIdx+1, endIdx-1)
		if items[i].time < items[i-1].time + gap then
			items[i].time = items[i-1].time + gap
		end if
	end for

	// If the last item still fits, we're done.
	if items[endIdx-1].time <= maxTime then return

	// Otherwise restore originals and do a backward pass instead.
	for i in range(startIdx, endIdx-1)
		items[i].time = origTimes[i - startIdx]
	end for
	for i in range(endIdx-2, startIdx, -1)
		if items[i].time > items[i+1].time - gap then
			items[i].time = items[i+1].time - gap
		end if
		if items[i].time < minTime then items[i].time = minTime
	end for
end function

planEncounters = function(sourceStation, destStation)
	// first gather all the encounters we might present
	possibilities = []
	for enc in encounterList
		cons = enc.consider(sourceStation, false)
		if cons isa map then cons = [cons]
		if cons == null then cons = []
		for c in cons
			c.time = c.distance * 2
			c.encounter = enc
			possibilities.push c
			log.info "Considering " + c.str
		end for
		cons = enc.consider(destStation, true)
		if cons isa map then cons = [cons]
		if cons == null then cons = []
		for c in cons
			c.time = 4 - c.distance * 2
			c.encounter = enc
			possibilities.push c
			log.info "Considering " + c.str
		end for
	end for
		
	// then pick which ones to actually present, and sort them by time
	outer.pending = []
	outer.elapsed = 0
	if not possibilities then return
	// For now, we'll just shuffle and take the first 1-3.
	maxCount = ceil(rnd*3)
	if possibilities.len > maxCount then
		possibilities.shuffle
		possibilities = possibilities[:maxCount]
	end if
	outer.pending = possibilities
	pending.sort "time"

	// Try to enforce a minimum gap between consecutive encounters.
	// (But keep encounters in the correct system, i.e., don't cross
	// the 2-second boundary at which the warp jump happens.)
	beforeJumpCount = 0
	for i in range(0, pending.len-1, 1)
		if pending[i].time < 2 then beforeJumpCount += 1
	end for
	spaceOutTimes pending, 0, beforeJumpCount, 0, 2
	spaceOutTimes pending, beforeJumpCount, pending.len, 2, 4

	// Log for debugging.
	lines = ["planEncounters: " + len(pending) + " scheduled encounter(s)"]
	for data in pending
		lines.push data.str
	end for
	log.info lines
end function

// Remove any pending encounters for which matchFn(data) returns true.
// Encounters may call this to cancel follow-up encounters made redundant
// by the current one (e.g. a clean police inspection cancels further
// inspections at the same station).
cancelPending = function(matchFn)
	for i in range(pending.len-1, 0, -1)
		if matchFn(pending[i]) then 
			log.info "cancel pending: " + pending[i].str
			pending.remove i
		end if
	end for
end function

update = function(dt)
	if not pending then return
	outer.elapsed = elapsed + dt
	if elapsed > pending[0].time then
		outer.event = pending.pull
		// Note: If you run into an encounter bug, examine encounters.event.encounter
		// to figure out which one it is!
		log.info "Elapsed=" + elapsed + ", presenting " + event.str
		disp.curtain.color = color.clear
		event.encounter.present event
	end if
end function

addNPCsToCantina = function(station)
	for enc in encounterList
		prevLen = station.cantina.len
		enc.addNPCsToCantina station
		// if the encounter added any NPCs, make sure they have their
		// 'encounter' and 'station' properties set so we can call back
		// to the same encounter if the player clicks on the NPC.
		if station.cantina.len > prevLen then
			for i in range(prevLen, station.cantina.len-1)
				station.cantina[i].encounter = enc
				station.cantina[i].station = station
			end for
		end if
	end for
end function

init
	
if locals == globals then
	print "Loaded " + encounterList.len + " encounters,"
	print "from " + encounterList[0].sourcePath
	print "  to " + encounterList[-1].sourcePath
	
	// Test spaceOutTimes.
	assertTimes = function(items, expectedTimes)
		actual = []
		for item in items; actual.push round(item.time, 1); end for
		if actual != expectedTimes then
			print "Test failure: expected " + expectedTimes
			print "but got " + actual
			exit
		end if
	end function
	t = "time"

	items = [{t:0.3}, {t:0.4}, {t:0.9}, {t:2.1}]
	spaceOutTimes items, 0, 3, 0, 2
	assertTimes items, [0.3, 0.8, 1.3, 2.1]

	items = [{t:1.3}, {t:1.4}, {t:1.9}, {t:2.1}]
	spaceOutTimes items, 0, 3, 0, 2
	assertTimes items, [0.9, 1.4, 1.9, 2.1]
	
end if