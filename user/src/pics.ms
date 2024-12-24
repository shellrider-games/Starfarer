// This module manages all the images/artwork in the pics folder.

import "importUtil"
ensureImport "stringUtil"

_cache = {}  // key: partial path; value: Image

// get: load an image directly by its path under the "pics" folder,
// and cache it for faster access on future calls.
get = function(path, failSilently=false)
	if path[-4:] != ".png" then path += ".png"
	if not _cache.hasIndex(path) then
		p = file.loadImage("/usr/pics/" + path)
		if p == null then
			p = file.loadImage("/sys/pics/" + path)
			if p == null and not failSilently then
				@qa.abort "Image not found: " + path
			end if
		end if
		_cache[path] = p
	end if
	return _cache[path]
end function

crates = {}	// key: "blank", "food", etc.; value: Image
for name in "blank food guns medicine water games machines narcotics ore robots wood".split
	crates[name] = get("crate_" + name)
end for

portrait = {}
portrait.human = {}
portrait.human.male = []
portrait.human.female = []
for child in file.children("/usr/pics/portraits")
	if not child.startsWith("human_") then continue
	name = child - ".png"
	number = val(name[-2:])
	batch = null
	if name.startsWith("human_male") then batch = portrait.human.male
	if name.startsWith("human_female") then batch = portrait.human.female
	if batch == null then continue
	while batch.len < number + 1; batch.push null; end while
	batch[number] = get("portraits/" + child)
end for

portrait.human.any = function
	return (portrait.human.male + portrait.human.female).any
end function

drawX = function(left, bottom, width, height)
	gfx.drawRect left, bottom, width, height, color.red
	gfx.line left, bottom, left+width, bottom+height, color.red
	gfx.line left+width, bottom, left, bottom+height, color.red
end function

demo = function
	drawInARow = function(pathsOrImages, x, y, gap=0)
		for p in pathsOrImages
			if p isa string then p = get(p)
			gfx.drawImage p, x, y
			x += p.width + gap
		end for
	end function

	clear
	y = 628
	gfx.print "Shots:", 10, y, color.silver, "small"
	drawInARow ["blueShot", "redShot"], 10, y-12
	y -= 32
	gfx.print "Crates:", 10, y, color.silver, "small"
	drawInARow crates.values, 10, y-16
	y -= 40
		
	y = 628
	x = 960 - 64*8
	gfx.print "portrait.human.male:", x, y, color.silver, "small"
	y -= 64
	for p in portrait.human.male
		if p == null then w = 64 else w = p.width
		if x + w > 960 then
			x = 960 - 64*8
			y -= 64
		end if
		if p == null then drawX x, y, 64, 64 else gfx.drawImage p, x, y
		x += w
	end for
	
	y -= 24
	x = 960 - 64*8
	gfx.print "portrait.human.female:", x, y, color.silver, "small"
	y -= 64
	for p in portrait.human.female
		if p == null then w = 64 else w = p.width
		if x + w > 960 then
			x = 960 - 64*8
			y -= 64
		end if
		if p == null then drawX x, y, 64, 64 else gfx.drawImage p, x, y
		x += w
	end for
	
	
	text.row = 0
end function

if locals == globals then demo
