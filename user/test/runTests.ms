env.importPaths.push "/usr/src"

clear
print "Run tests for shipDisplay.ms"
import "shipDisplay"
shipDisplay.runUnitTests
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

print "RAN ALL TESTS"