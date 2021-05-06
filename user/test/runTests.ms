env.importPaths.push "/usr/src"

clear

print "Run tests for shipModel.ms"
import "shipModel"
shipModel.runUnitTests
print "Run tests for miscUtil.ms"
import "miscUtil"
miscUtil.runUnitTests
print "RAN ALL TESTS"