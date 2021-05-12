env.importPaths.push "/usr/src"

clear

import "shipDisplay"
shipDisplay.runUnitTests
print "Run tests for shipDisplay.ms"

print "Run tests for shipModel.ms"
import "shipModel"
shipModel.runUnitTests
print "Run tests for miscUtil.ms"
import "miscUtil"
miscUtil.runUnitTests
print "Run tests for constants.ms"
import "constants"
constants.runUnitTests
print "Run tests for charAI.ms"
import "charAI"
charAI.runUnitTests
print "Run tests for uiWidgets.ms"
import "uiWidgets"
uiWidgets.runUnitTests
print "Run tests for stationModel.ms"
import "stationModel"
stationModel.runUnitTests


print "RAN ALL TESTS"