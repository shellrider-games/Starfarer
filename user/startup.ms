import "listUtil"
cd "/usr/src"

print "Starfarer Launcher"
print "1. Starfarer.ms"
moduleMap = {"1":"Starfarer"}
modules = file.children("/usr/src")
i = 2
for f in modules
	if f[-3:] == ".ms" and f != "starfarer.ms" then
		moduleMap[str(i)] = f[:-3]
		print i+". "+f[0].upper + f[1:-3]
		i = i + 1
	end if
end for
print "press 'q' to exit launcher"
print "press a number to launch the module"

waitingOnUserChoice = true
while waitingOnUserChoice
	if key.available then
		k = key.get
		print k
		if k == "q" then
			exit
		else if moduleMap.hasIndex(k) then
			choice = moduleMap[k]
			waitingOnUserChoice = false
		end if 	
	else
		yield		
	end if
end while

if choice then
load choice
run
end if

