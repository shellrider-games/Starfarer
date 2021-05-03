env.importPaths.push "/usr/src"

print "Run tests for shipModel.ms"
import "shipModel"
shipModel.runUnitTests
print "RAN ALL TESTS"