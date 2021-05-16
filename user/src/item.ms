// This module adds the Item class, which represents any item that can be
// placed in a cell of a ship, and (in many cases) picked up and carried
// around by a Character.
// It is both model and view: that is, it contains the data which is part
// of a shipModel, but it's also a Sprite that can be loaded by shipDisplay.

if not globals.hasIndex("spriteUtil") then import "spriteUtil"

// Item (sprite subclass)
Item = new Sprite
Item.image = file.loadImage("/usr/pics/crate_blank.png")
Item.name = "item"
Item.blocksWalking = true
Item.col = 0
Item.row = 0
Item.lerper = null	// a SpriteLerper instance, when needed
Item.typicalValue = 100

Item.update = function(dt)
	if self.lerper == null then return
	self.lerper.apply self
	if self.lerper.isDone then self.lerper = null
end function

Item.fadeIn = function(dx = -16, dy = 0)
	self.lerper = new spriteUtil.SpriteLerper
	self.lerper.init self
	self.x = self.x + dx; self.y = self.y + dy
	self.lerper.startPos.x = self.x
	self.lerper.startPos.y = self.y
	self.lerper.fadeIn = true
end function

Item.fadeOut = function(dx = 16, dy = 0)
	self.lerper = new spriteUtil.SpriteLerper
	self.lerper.init self
	self.lerper.endPos.x = self.x + dx
	self.lerper.endPos.y = self.y + dy
	self.lerper.fadeOut = true
end function

Item.lerpTo = function(screenPos, scale=null, duration=0.5)
	self.lerper = new spriteUtil.SpriteLerper
	self.lerper.init self
	self.lerper.duration = duration
	self.lerper.endPos = screenPos
	if scale != null then self.lerper.endScale = scale
end function

// Now let's make a subclass for each of our commodity types.
FoodItem = new Item
FoodItem.image = file.loadImage("/usr/pics/crate_food.png")
FoodItem.name = "food"
FoodItem.typicalValue = 50

GunsItem = new Item
GunsItem.image = file.loadImage("/usr/pics/crate_guns.png")
GunsItem.name = "guns"
GunsItem.typicalValue = 150

MedsItem = new Item
MedsItem.image = file.loadImage("/usr/pics/crate_medicine.png")
MedsItem.name = "medicine"
MedsItem.typicalValue = 250

WaterItem = new Item
WaterItem.image = file.loadImage("/usr/pics/crate_water.png")
WaterItem.name = "water"
WaterItem.typicalValue = 25


// Item is an important enough class to push itself into the global namespace.
globals.Item = Item

