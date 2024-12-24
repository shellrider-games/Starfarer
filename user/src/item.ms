// This module adds the Item class, which represents any item that can be
// placed in a cell of a ship, and (in many cases) picked up and carried
// around by a Character.
// It is both model and view: that is, it contains the data which is part
// of a shipModel, but it's also a Sprite that can be loaded by shipDisplay.


if not globals.hasIndex("spriteUtil") then import "spriteUtil"

// Item (sprite subclass)
Item = new Sprite
Item.image = pics.crates.blank
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
WaterItem = new Item
WaterItem.image = pics.crates.water
WaterItem.name = "water"
WaterItem.typicalValue = 25

FoodItem = new Item
FoodItem.image = pics.crates.food
FoodItem.name = "food"
FoodItem.typicalValue = 115

WoodItem = new Item
WoodItem.image = pics.crates.wood
WoodItem.name = "wood"
WoodItem.typicalValue = 250

OreItem = new Item
OreItem.image = pics.crates.ore
OreItem.name = "ore"
OreItem.typicalValue = 400

GamesItem = new Item
GamesItem.image = pics.crates.games
GamesItem.name = "games"
GamesItem.typicalValue = 260

MedsItem = new Item
MedsItem.image = pics.crates.medicine
MedsItem.name = "medicine"
MedsItem.typicalValue = 500

MachinesItem = new Item
MachinesItem.image = pics.crates.machines
MachinesItem.name = "machines"
MachinesItem.typicalValue = 750

RobotsItem = new Item
RobotsItem.image = pics.crates.robots
RobotsItem.name = "robots"
RobotsItem.typicalValue = 2500

GunsItem = new Item
GunsItem.image = pics.crates.guns
GunsItem.name = "firearms"
GunsItem.typicalValue = 950

NarcoticsItem = new Item
NarcoticsItem.image = pics.crates.narcotics
NarcoticsItem.name = "narcotics"
NarcoticsItem.typicalValue = 2000

allTypes = [WaterItem, FoodItem, WoodItem, OreItem, MedsItem, 
			MachinesItem, RobotsItem, GamesItem, GunsItem, NarcoticsItem]

// Item is an important enough class to push itself into the global namespace.
globals.Item = Item

