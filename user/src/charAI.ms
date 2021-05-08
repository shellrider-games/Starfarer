// This script forms the AI for controlling characters on the ship.
// It is a utility-based AI: each agent has certain needs that generally
// grow with time, and possible actions that reduce them (and costs,
// generally measured in time, of taking those actions).  The agent will
// act to reduce its needs as much as possible.


if not globals.hasIndex("character") then import "character"
if not globals.hasIndex("shipModel") then import "shipModel"
if not globals.hasIndex("miscUtil") then import "miscUtil"
if not globals.hasIndex("qa") then import "qa"

// Need: base class for any need an agent may have.
// Some needs increase with time; others increase only in response to 
// specific events (such as a need to heal after injury).
// Units of need are basically seconds-equivalent: i.e., if a need
// value is 10, then it's worth spending 10 seconds to address that need.
Need = {}
Need.name = "need"
Need.value = 0
Need.incPerSecond = 0
Need.maxValue = 100
Need.make = function(name, incPerSecond, maxValue)
	noob = new Need
	noob.name = name
	if incPerSecond != null then noob.incPerSecond = incPerSecond
	if maxValue != null then noob.maxValue = maxValue
	return noob
end function

Need.update = function(dt)
	self.value = miscUtil.min(self.value + self.incPerSecond * dt, self.maxValue)
end function

// Brain: all the AI data for one particular agent.
Brain = {}
Brain.init = function()
	self.hunger = Need.make("hunger", 1)
	self.sleep = Need.make("sleep", 0.1)
	self.heal = Need.make("heal")
end function


demo = function()

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

