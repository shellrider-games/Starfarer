// This module adds the Item class, which represents any item that can be
// placed in a cell of a ship, and (in many cases) picked up and carried
// around by a Character.
// It is both model and view: that is, it contains the data which is part
// of a shipModel, but it's also a Sprite that can be loaded by shipDisplay.


// Item (sprite subclass)
Item = new Sprite
Item.image = file.loadImage("/usr/pics/crate_blank.png")
Item.name = "item"
Item.blocksWalking = true
Item.col = 0
Item.row = 0

// All the sprites that exist in the ship display need to have an update method
// that takes one parameter (dt).  Item doesn't really need this, so here's a
// do-nothing update method for it.
// ToDo: actually, items sometimes need to lerp into position/scale, often
// while also fading in/out.  THAT is what Item.update should do.
Item.update = function(dt); end function

// Now let's make a subclass for each of our commodity types.
FoodItem = new Item
FoodItem.image = file.loadImage("/usr/pics/crate_food.png")
FoodItem.name = "food"

GunsItem = new Item
GunsItem.image = file.loadImage("/usr/pics/crate_guns.png")
GunsItem.name = "guns"

MedsItem = new Item
MedsItem.image = file.loadImage("/usr/pics/crate_medicine.png")
MedsItem.name = "medicine"

WaterItem = new Item
WaterItem.image = file.loadImage("/usr/pics/crate_water.png")
WaterItem.name = "water"



// Item is an important enough class to push itself into the global namespace.
globals.Item = Item

