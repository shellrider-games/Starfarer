// Simple logging facility, for debugging.
// Just call log.info, log.warn, or log.err with a string
// or a list of strings to log.

if not globals.hasIndex("importUtil") then import "importUtil"
ensureImport "dateTime"
ensureImport "mathUtil"
mathUtil.log = @intrinsics.log  // (patch up mathUtil's use of `log` intrinsic)

logFilePath = "/usr/temp/log.txt"

if file.exists(logFilePath) then
	prevPath = logFilePath - ".txt" + "-prev.txt"
	file.delete prevPath
	file.move logFilePath, prevPath
end if


_write = function(logType, lineOrLines)
	if lineOrLines isa string then lineOrLines = [lineOrLines]
	f = file.open(logFilePath, "a+")
	prefix = "[" + logType + " " + dateTime.now.split[-1] + "] "
	for line in lineOrLines
		f.writeLine prefix + line
	end for
	f.close
end function


info = function(lineOrLines)
	_write "INFO", lineOrLines
end function

warn = function(lineOrLines)
	_write "WARN", lineOrLines
end function

err = function(lineOrLines)
	_write "ERR!", lineOrLines
end function

