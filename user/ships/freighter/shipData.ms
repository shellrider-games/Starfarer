cd "/usr/src"
import "shipModel"
cd "/usr"

self = new shipModel.Ship
self.init(10,14)

self.digRoom(0,0,10,7)
self.digRoom(1,7,2,7)
self.digRoom(3,7,3,5)
self.digRoom(6,7,3,3)
self.digRoom(7,10,2,4)

self.print