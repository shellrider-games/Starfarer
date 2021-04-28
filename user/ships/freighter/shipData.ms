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

self.drawBottomWalls(0,0,10)
self.drawBottomWalls(0,4,3)
self.drawBottomWalls(6,4,4)
self.drawBottomWalls(3,7,1)
self.drawBottomWalls(5,7,1)

self.drawTopWalls(2,11,4)
self.drawTopWalls(8,6,2)
self.drawTopWalls(6,9,2)
self.drawTopWalls(0,6,1)
self.drawTopWalls(1,13,2)
self.drawTopWalls(7,13,2)

self.drawLeftWalls(0,0,7)
self.drawLeftWalls(1,7,7)
self.drawLeftWalls(4,0,4)
self.drawLeftWalls(7,10,4)

self.drawRightWalls(2,7,7)
self.drawRightWalls(5,7,5)
self.drawRightWalls(8,7,7)
self.drawRightWalls(9,0,7)