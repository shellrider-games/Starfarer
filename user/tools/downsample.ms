// This tool does a "smart" downsampling of pixely
// (but imprecise) images.


img = file.loadImage("/usr2/image_big.png")

list.mode = function
	counts = {}
	for elem in self
		if counts.hasIndex(elem) then
			counts[elem] += 1
		else
			counts[elem] = 1
		end if
	end for
	bestVal = null
	bestCount = null
	for kv in counts
		if bestCount == null or kv.value > bestCount then
			bestVal = kv.key
			bestCount = kv.value
		end if
	end for
	return bestVal
end function

clear
xbase = 480-256
ybase = 320-256
gfx.drawImage img, xbase, ybase, 512, 512

xrange2 = range(0, img.width-2, 2)
yrange2 = range(0, img.height-2, 2)

columnDiff = function(x0, x1)
	sum = 0
	for y in yrange2
		c0 = color.toList(img.pixel(x0, y))
		c1 = color.toList(img.pixel(x1, y))
		sum += abs(c0[0]-c1[0]) + abs(c0[1]-c1[1]) + abs(c0[2]-c1[2])
	end for
	return sum
end function	

rowDiff = function(y0, y1)
	sum = 0
	for x in xrange2
		c0 = color.toList(img.pixel(x, y0))
		c1 = color.toList(img.pixel(x, y1))
		sum += abs(c0[0]-c1[0]) + abs(c0[1]-c1[1]) + abs(c0[2]-c1[2])
	end for
	return sum
end function

// Find column differences (every 2 pixels, for speed)
gfx.color = color.white
if globals.hasIndex("foundDiffs") then
	columnDiffs = foundDiffs
	for i in columnDiffs.indexes
		x = i*2
		diff = columnDiffs[i]
		gfx.line xbase + x/2, 0, xbase + x/2, diff/1000	
	end for
else
	columnDiffs = []
	for x in xrange2
		diff = columnDiff(x, x+2)
		//print diff
		columnDiffs.push diff
		gfx.line xbase + x/2, 0, xbase + x/2, diff/1000	
	end for
	foundDiffs = columnDiffs
end if

// Now, find the positions of local maxima, and the spacing
// between them.
xbreaks = []
diffs = []
for i in range(1, columnDiffs.len-2)
	if columnDiffs[i] > columnDiffs[i-1] and
	  columnDiffs[i] > columnDiffs[i-2] and
	  columnDiffs[i] > columnDiffs[i+1] and
	  columnDiffs[i] > columnDiffs[i+2] then
		xbreaks.push i*2
		print xbreaks[-1], ""
		if xbreaks.len > 1 then 
			diffs.push xbreaks[-1] - xbreaks[-2]
			print " (diff: " + diffs[-1] + ")"
		else
			print
		end if
	end if
end for

print diffs.len + " peaks found."
mode = diffs.mode
print "Mode gap: " + mode

// Now, look for gaps of twice the mode or more, and split 'em.
for i in diffs.indexes
	d = diffs[i]
	if d >= mode * 2 then
		diffs[i] = d/2
		diffs.insert i+1, d/2
		xbreaks.insert i+1, xbreaks[i] + d/2
		print "Split at " + i
		print "Diffs: " + diffs[i-2:i+4]
		print "Xbreaks: " + xbreaks[i-2:i+4]
	end if
end for

// And look for gaps that are too small, and take one out.
for i in range(diffs.len-2)
	d = diffs[i]
	if d < mode * 0.6 then
		diffs.remove i
		diffs[i-1] += d
		xbreaks.remove i
		print "Removed at " + i
		print "Diffs: " + diffs[i-2:i+4]
		print "Xbreaks: " + xbreaks[i-2:i+4]
	end if
end for

gfx.color = "#FF00FF"
for x in xbreaks
	gfx.line xbase + x/2, ybase, xbase + x/2, ybase+512
end for

// Now do the same for the Y axis!
gfx.color = color.white
if globals.hasIndex("foundYDiffs") then
	rowDiffs = foundYDiffs
	for i in rowDiffs.indexes
		y = i*2
		diff = rowDiffs[i]
		gfx.line xbase-64, ybase + y/2, xbase-64 + diff/1000, ybase + y/2
	end for
else
	rowDiffs = []
	for y in yrange2
		diff = rowDiff(y, y+2)
		//print diff
		rowDiffs.push diff
		gfx.line xbase-64, ybase + y/2, xbase-64 + diff/1000, ybase + y/2
	end for
	foundYDiffs = rowDiffs
end if

// Now, find the positions of local maxima, and the spacing
// between them.
ybreaks = []
diffs = []
for i in range(1, rowDiffs.len-2)
	if rowDiffs[i] > rowDiffs[i-1] and
	rowDiffs[i] > rowDiffs[i-2] and
	rowDiffs[i] > rowDiffs[i+1] and
	rowDiffs[i] > rowDiffs[i+2] then
		ybreaks.push i*2
		print ybreaks[-1], ""
		if ybreaks.len > 1 then 
			diffs.push ybreaks[-1] - ybreaks[-2]
			print " (diff: " + diffs[-1] + ")"
		else
			print
		end if
	end if
end for

print diffs.len + " peaks found."
mode = diffs.mode
print "Mode gap: " + mode

// Now, look for gaps of twice the mode or more, and split 'em.
for i in diffs.indexes
	d = diffs[i]
	if d >= mode * 2 then
		diffs[i] = d/2
		diffs.insert i+1, d/2
		ybreaks.insert i+1, ybreaks[i] + d/2
		print "Split at " + i
		print "Diffs: " + diffs[i-2:i+4]
		print "Xbreaks: " + ybreaks[i-2:i+4]
	end if
end for

// And look for gaps that are too small, and take one out.
for i in range(diffs.len-2)
	d = diffs[i]
	if d < mode * 0.6 then
		diffs.remove i
		diffs[i-1] += d
		ybreaks.remove i
		print "Removed at " + i
		print "Diffs: " + diffs[i-2:i+4]
		print "Xbreaks: " + ybreaks[i-2:i+4]
	end if
end for

gfx.color = "#FF00FF"
for y in ybreaks
	gfx.line xbase, ybase + y/2, xbase+512, ybase + y/2
end for

// Now, iterate over the x and y breaks, plucking out
// the pixel in the center of each cell.
outbaseX = 960-128
outbaseY = 640-128

for j in range(0, ybreaks.len-2)
	y = (ybreaks[j] + ybreaks[j+1])/2
	for i in range(0, xbreaks.len-2)
		x = (xbreaks[i] + xbreaks[i+1])/2
		c = img.pixel(x,y)
		gfx.setPixel outbaseX+i, outbaseY+j, c
	end for
end for
smallimg = gfx.getImage(outbaseX, outbaseY, xbreaks.len, ybreaks.len)
file.saveImage "/usr2/image_small.png", smallimg

