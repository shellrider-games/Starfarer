if not globals.hasIndex("disp") then import "setup"
if not globals.hasIndex("qa") then import "qa"

Warp = {}
Warp.timeSpent = null
Warp.active = false

Warp.run = function()
    if not self.active then
        self.timeSpent = 0
        self.active = true
    end if
end function

Warp.update = function(delta)
    if self.active then
        self.timeSpent = self.timeSpent + delta
        if self.timeSpent <= 1 then
            disp.curtain.color = color.lerp(color.clear, color.black, self.timeSpent)
        else if self.timeSpent <= 2 then
            disp.curtain.color = color.lerp(color.black, color.clear, self.timeSpent-1)
        else
            disp.curtain.color = color.clear
            self.active = false
        end if
    end if
end function

demo = function()
    
    wait 1
    
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