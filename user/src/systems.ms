// This module defines the System base class and various subclasses,
// which represent things that can be installed on a ship.  Systems
// generally consume power and provide some benefit to the ship/crew.

import "miscUtil"

//----------------------------------------------------------------------
// System base class
//----------------------------------------------------------------------

System = {}
System.name = "GENERIC"
System.col = 0
System.row = 0
System.width = 1
System.height = 1
System.image = null

System.make = function(col, row, width=1, height=1, name="GENERIC")
	noob = new System
	noob.col = col; noob.row = row
	noob.width = width; noob.height = height
	noob.name = name
	return noob
end function

//This function should be overwritten by child classes
System.use = function(character, dt = 0.1)
	print character.name + " is using " + self.name + " for " + dt + " seconds."
end function

//----------------------------------------------------------------------
// Med Bay: heals crew standing over the system (while powered).
//----------------------------------------------------------------------
MedBay = new System
MedBay.name = "MedBay"
MedBay.width = 2
MedBay.height = 2
MedBay.image = file.loadImage("/usr/pics/systems/medbay.png")

MedBay.make = function(col, row)
	noob = new MedBay
	noob.col = col; noob.row = row
	return noob
end function

MedBay.use = function(character, dt = 0.1)
	character.health = miscUtil.min(character.health + dt, character.maxHealth)
end function