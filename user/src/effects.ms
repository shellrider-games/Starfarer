if not globals.hasIndex("disp") then import "setup"
if not globals.hasIndex("qa") then import "qa"
if not globals.hasIndex("sounds") then import "sounds"

Warp = {}
Warp.timeSpent = null
Warp.active = false
Warp.speed = 1

Warp.run = function()
    if not self.active then
        self.timeSpent = 0
        self.active = true
        sounds.warp.play 1, 0, self.speed
    end if
end function

Warp.update = function(delta)
    if self.active then
        self.timeSpent = self.timeSpent + delta * self.speed
        if self.timeSpent <= 1 then
            disp.curtain.color = color.lerp(color.clear, color.white, self.timeSpent)
        else if self.timeSpent <= 2 then
            disp.curtain.color = color.lerp(color.white, color.clear, self.timeSpent-1)
        else
            disp.curtain.color = color.clear
            self.active = false
        end if
    end if
end function

demo = function()
    
    wait 1
    
    Warp.speed = 3
    Warp.run

    while not key.pressed("escape")
		Warp.update 1/60
		yield
	end while
	key.clear

end function

if locals == globals then
	effects = locals
	demo
end if