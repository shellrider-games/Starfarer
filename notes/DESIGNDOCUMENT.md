# Starfarer Design #

## What is the game about? ##

Starfarer is a game about managing the crew of a merchant spaceship.

### The mundane vs. the wonderful ###
The environment the crew is in is exciting. In space there is opportunity to encounter something new at every corner, so encounters are wonderful, mysterious and new. Their daily life on the other hand is not. The crew needs to eat and sleep and has simple needs that need to be fulfilled.

### The crewmembers are people ###
Our crewmembers are individuals that have unique wants, needs and personalities. We focus on the life of a handful of people so that it is possible to form attachments to every single one of them.

### The crew is not its members ###
Even though we focus on stories of individuals the crew can grow and shrink. People can join and leave but the crew will still be the crew.

### Fail forward ###
Mishaps and failures should be interesting. The focus of problems is not the setback it causes but new problems and challenges that can be solved and overcome.  Each playthrough should generate unique stories, many of them emergent rather than scripted.


## Primary Game Loop ##
1. Dock at a planet or space station.
	- Handle any scripted events triggered by your arrival.
	- Fire any crew members you no longer want on your ship.
	- Spend money to:
		- repair/fuel ship
		- buy cargo
		- hire crew
		- buy new equipment for the ship
		- buy an entirely new ship (trading in the old one)
		- enable certain event options
	- Earn money by:
		- selling cargo
		- selling equipment from your ship
		- selecting certain event options
2. Select another planet/star system to travel to.
	- On the way, encounter other ships either while departing your origin system, or approaching the destination.
	- These encounters can result in combat, trade, or scripted events, which can impact your ship, cargo, crew, and/or money.
3. Repeat.


## Directing the Crew ##
Crewmates are semi-autonomous AIs.  That means they have needs which they will independently act to meet:
- eating
- sleeping
- using the WC
- avoiding harm
- entertainment

But you can also give them orders (which basically add temporary, high-priority needs). These are mostly done by selecting a crewmember, then clicking on a target.  Examples:
- click on a crate: crewmate picks it up
- click on an empty space while crewmate is holding something: crewmate puts it down
- click on a fire: crewmate attempts to put it out
- click on some broken equipment: crewmate repairs it
- click on an enemy character: crewmate attacks
- click on any point in the ship while crewmate is empty-handed: crewmate goes there and hangs out for a while

These orders can be given any time the player ship map is on screen (though if time is paused, the orders will not be carried out until it resumes).  That includes while docked at a station, and while traveling through space.  (Though not while jumping between starsystems; that is instantaneous.)

Each crewmate has specific skills which determine how effective they are at various tasks.  Each also has an emotional state that depends on how well their needs are being met.  Keeping your crew safe and happy is a primary sub-goal of the game.

## Managing the Ship ##

Most of the time during the game, your ship appears on the left side of the screen in a cut-away plan view.  It is laid out on a grid, where a small room might be 2x2 grid cells (though the WC is typically only 1 grid cell).  Each grid cell can hold one cargo container.  Ship equipment takes up at least 1 grid cell, and often more.

The ship is composed of a hull, which defines the empty layout and amount of damage the ship can take; plus any equipment you have bought and installed.  Examples of ship equipment:
- power core (provides power to all other equipment)
- bunk (one bunk is required for each crewmember)
- WC
- food replicator
- weapons of various sorts (each hull has certain weapon slots)
- shield generator
- life support (generates O2)
- transporters
- holodeck (provides entertainment)

Any equipment can break down, either through normal wear & tear or as a result of combat.  Other problems you may need to deal with include:
- fires
- evacuation (loss of air due to hull breach or open door)

