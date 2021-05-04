env.importPaths.push "/usr/src"

clear

print "Run tests for shipModel.ms"
import "shipModel"
shipModel.runUnitTests
print "RAN ALL TESTS"