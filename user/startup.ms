clear
cd "/usr/src"

print "Starfarer Launcher"
print

print "1. Starfarer.ms"
moduleMap = {"1":"Starfarer"}
modules = file.children("/usr/src")
i = 2
for f in modules
	if f[-3:] == ".ms" and f != "starfarer.ms" then
		if i > modules.len/2 then
			text.row = 24 - (i - floor(modules.len/2))
			text.column = 34
		end if
		moduleMap[str(i)] = f[:-3]
		print i+". "+f[0].upper + f[1:-3]
		i = i + 1
	end if
end for
print
print
print "enter 'q' to exit launcher"
print "enter a number to launch the module"

mainLoop = function()
	while true
		inp = input("==>")
		if inp == "q" then
			cd
			exit
		else if moduleMap.hasIndex(inp) then
			choice = moduleMap[inp]
			reset; load choice; run
			exit
		end if
	end while
end function

mainLoop
