// This script forms the AI for controlling characters on the ship.
// It is a utility-based AI: each agent has certain needs that generally
// grow with time, and possible actions that reduce them (and costs,
// generally measured in time, of taking those actions).  The agent will
// act to reduce its needs as much as possible.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "qa"
ensureImport "listUtil"
ensureImport "character"
ensureImport "shipModel"
ensureImport "systems"

// Need: base class for any need an agent may have.
// Some needs increase with time; others increase only in response to 
// specific events (such as a need to heal after injury).
// Units of need are basically seconds-equivalent: i.e., if a need
// value is 10, then it's worth spending 10 seconds to address that need.
Need = {}
Need.name = "need"
Need.value = 0
Need.incPerSecond = 0
Need.minValue = 0
Need.maxValue = 100
Need.make = function(name, incPerSecond, maxValue)
	noob = new Need
	noob.name = name
	if incPerSecond != null then noob.incPerSecond = incPerSecond
	if maxValue != null then noob.maxValue = maxValue
	return noob
end function
Need.add = function(amount)
	self.value = self.value + amount
	if self.value > self.maxValue then self.value = self.maxValue
end function

Need.update = function(dt=0.1)
	self.value = min(self.value + self.incPerSecond * dt, self.maxValue)
end function

// Activity: something an agent can do.  Each activity has a cost
// (how many seconds it will take to reach and then do the activity),
// and can reduce one or more needs.
Activity = {}
Activity.cost = 5		// approximate seconds to do this activity
Activity.benefit = {}	// e.g. "hunger":20 to reduce hunger by (up to) 20
Activity.path = null	// series of ship locations to follow (if applicable)
Activity.make = function(cost, need1, reduction1, need2, reduction2, need3, reduction3)
	result = new Activity
	result.cost = cost
	result.benefit = {}
	if need1 != null then result.benefit[need1] = reduction1
	if need2 != null then result.benefit[need2] = reduction2
	if need3 != null then result.benefit[need3] = reduction3
	return result
end function
Activity.begin = function(character)
	character.path = self.path
end function
Activity.isDone = function(character)
	return false
end function

// idle: standard do-nothing activity
idle = Activity.make(1 + rnd*2, "relax", 5); idle.name = "idle"

// work: operate the ship system of whatever room we're in,
// or if it needs repair, repair it.
work = Activity.make(5, "work", 5); work.name = "work"

// heal: go to the MedBay to heal
heal = function(pathToMedBay, benefit)
	result = Activity.make(pathToMedBay.len, "heal", benefit)
	result.path = pathToMedBay
	result.name = "heal"
	return result
end function

// stow: pick up some cargo in a cargo "in" cell, and stow it in the ship
stow = function(pathToCargo)
	result = Activity.make(pathToCargo.len, "work", 10)
	result.path = pathToCargo
	result.name = "stow"
	return result
end function

DirectOrderActivity = new Activity
DirectOrderActivity.targetPos = {"col":0, "row":0}
DirectOrderActivity.begin = function(character)
	character.path = pathfinding.findPath(character.ship, character, self.targetPos)
	if character.brain.orders == self then character.brain.orders = null
//	print "Starting DAO with path " + character.path
end function
DirectOrderActivity.isDone = function(character)
	done = (not character.path) and (character.col == self.targetPos.col and character.row == self.targetPos.row)
//	if done then print "DAO is done"
	return done
end function
DirectOrderActivity.cost = 0
DirectOrderActivity.cost = 60  // (stick with this activity for up to 60 seconds)
DirectOrderActivity.name = "obey"
DirectOrderActivity.make = function(targetPos)
	result = new DirectOrderActivity
	result.targetPos = targetPos
	return result
end function
	
// Brain: all the AI data for one particular agent.
Brain = {}
Brain.make = function()
	result = new Brain
	result.init
	return result
end function

Brain.init = function()
	self.hunger = Need.make("hunger", 1); self.hunger.minValue = -20
	self.sleep = Need.make("sleep", 0.1); self.sleep.minValue = -50
	self.heal = Need.make("heal")
	self.work = Need.make("work")
	self.relax = Need.make("relax", 0.01)
	// ToDo: add hunger and sleep below, once we have ways for characters
	// to do something about those.
	self.needs = [self.relax, self.work, self.heal]
	self.activities = [idle]
	self.doing = null	// which activity we are currently doing
	self.orders = null	// activity we've been directly ordered to do by player
end function

Brain.printNeeds = function()
	result = []
	for need in self.needs
		result.push need.name + ":" + need.value
	end for
	print result.join(", ") + "   "
end function

Brain.findActivities = function(character)
	ship = character.ship
	
	self.work.value = 0
	
	if self.orders != null then
		self.activities = [self.orders]
		return
	end if
	
	// always consider doing nothing!
	self.activities = [idle]

	// if we are holding cargo, either take it to the output queue
	// or stow it
	if character.carrying == null then
		// consider picking up cargo that's been sold
		self.work.add 10 * ship.outgoingTypes.len
		for cell in ship.findOutgoingItems
			path = pathfinding.findPathUpTo(ship, character, cell)
			if path then self.activities.push stow(path)
		end for
		// consider picking up fresh cargo, if we have any waiting for that
		for pickUpCell in ship.getFullCargoInCells
			self.work.add 10
			path = pathfinding.findPathUpTo(ship, character, pickUpCell)
			if path then self.activities.push stow(path)
		end for
	else
		// if we're already carrying something, go put it down
		self.work.add 10
		if ship.outgoingTypes.contains(character.carrying.__isa) then
			// player has sold an item of this type; carry it to output
			for cell in ship.getCargoOutCells
				path = pathfinding.findPath(ship, character, cell)
				if path then self.activities.push stow(path)
			end for
		else
			// look for an empty cargo spot we can reach;
			// only consider the first one, as that is most preferred
			// (according to the ship designer)
			storageCell = ship.firstEmptyStorageCell
			if storageCell then
				path = pathfinding.findPath(ship, character, storageCell)
				if path then self.activities.push stow(path)
			end if
		end if
	end if

	// consider healing, if needed
	if character.health < character.maxHealth then
		self.heal.value = round(120 * (1 - character.health / character.maxHealth))
		medbay = ship.findSystemOfType(systems.MedBay)
		if medbay != null and medbay.curPower > 0 then
			path = pathfinding.findPath(ship, character, medbay)
			if path then self.activities.push heal(path, self.heal.value)
		end if
	end if

end function

Brain.update = function(character, dt=0.1)
	for need in self.needs; need.update; end for
	if self.doing != null then
		// check whether we are done with this activity
		self.doFor -= dt
		if self.doFor <= 0 or self.doing.isDone(character) then
			self.applyBenefits self.doing
			self.doing = null
		else
			//text.row = 17; print "Still doing " + self.doing.name + " for " + self.doFor + " sec"
		end if
	end if
	if self.doing == null then
		// Reevaluate possible activities.
		self.findActivities character
		
		// Then, choose one.
		self.doing = self.choose
		if self.doing != null then
			self.doFor = self.doing.cost
			self.doing.begin character
		end if
		//text.row = 18; print "Choosing to do " + self.doing.name + " for " + self.doFor + " at " + round(time,1)
	end if
end function

Brain.choose = function(activities=null)
	if activities == null then activities = self.activities
	if not activities then return null
	if activities.len == 1 then return activities[0]
	choice = null
	bestValue = 0
	for activity in activities
		// calculate the actual benefit of this activity, by summing
		// up all the benefits but limited to the amount of our actual need
		benefit = 0
		for kv in activity.benefit  // (kv is standard abbreviation for key-value pair)
			if not self.hasIndex(kv.key) then continue
			need = self[kv.key]
			benefit = benefit + min(need.value, kv.value)
		end for
		// now calculate value of this activity, as benefit/cost
		value = benefit / activity.cost
		//print "value of " + activity.name + ": " + benefit + "/" + activity.cost + "=" + value
		if choice == null or value > bestValue then
			choice = activity
			bestValue = value
		end if
	end for
	return choice
end function

Brain.applyBenefits = function(activity)
	for kv in activity.benefit
		if not self.hasIndex(kv.key) then continue
		need = self[kv.key]
		need.value = max(need.value - kv.value, need.minValue)
	end for
end function



demo = function()
	brain = new Brain
	brain.init
	brain.sleep.value = -30
	
	eat = Activity.make(20, "eat", 50); eat.name = "eat"
	heal = Activity.make(10, "heal", 100); heal.name = "heal"
	sleep = Activity.make(80, "sleep", 50); sleep.name = "sleep"
	work = Activity.make(20, "work", 0); work.name = "work"
	activities = [idle, eat, heal, sleep, work]

	while true
		brain.printNeeds
		act = brain.choose(activities)
		print "brain spends " + act.cost + " sec doing: " + act.name
		brain.applyBenefits act
		wait act.cost/10
		brain.update act.cost/10
		if rnd < 0.1 then
			print "OUCH!  Took an injury."
			brain.heal.value = 10 + round(rnd*10)
		end if
		if rnd < 0.1 then
			print "Got some new work that needs doing."
			brain.work.add 10
			work.benefit["work"] = brain.work.value
		end if
	end while
end function

runUnitTests = function()
	n = new Need
	qa.assert n.value == 0
	n.incPerSecond = 2
	n.update 5
	qa.assert n.value == 10
	n.update 500
	qa.assert n.value == 100
	
	n = Need.make("Test", 3, 50)
	qa.assert n.name == "Test"
	qa.assert n.incPerSecond == 3
	qa.assert n.maxValue == 50
	n.update 2
	qa.assert n.value == 6
	
end function


if locals == globals then
	charAI = locals
	runUnitTests
	demo
end if

