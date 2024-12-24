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

### Roles to Play ###
There are many different ways to play the game.  These are not "classes" you have to choose between, but rather play styles you can mix in whatever ways you like.  It should be possible to win by any of these methods.
- trader: earn money & influence through clever buying/selling/transport
- pirate: attack fat cargo/transport vessels, earning money through plunder and ransom
- smuggler: trade in illegal goods, dodging the authorities for big profits
- officer: work for the authorities to fight the pirates, scum, and villany of the galaxy
- explorer: equip your ship with scientific instruments and earn money through exploration and research grants


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
- life support (generates breathable air)
- transporter pad
- holodeck (provides entertainment)
- spacesuit locker
- med bay

Any equipment can break down, either through normal wear & tear or as a result of combat.  Fires may break out, and need to be extinguished.  If a hull breach (or open outer door) occurs, air is lost very rapidly in that area and any areas of the ship connected to it by open doors; to fix the problem the breach must be sealed, and then the life support system given time to refill the air.  If life support breaks down, air will go bad more slowly wherever crewmembers are breathing.

## Reputation ##
The player's ship will have a reputation with each known faction (as well as each faction with each other faction that they are aware of) that will influence the types of events that can occur when interacting with a faction. Reputation can range from Ally to Hostile.

### Gain Reputation ###
- trading
- assisting in battles
- destroying other ships that are hostile to the controlling faction
- doing missions/jobs for the faction (not shady deals)
- rescuing ships/responding to distress calls
- rescuing crew from destroyed ships (that you may have destroyed) - detroying the ship will damage your reputation but you may be able to get some back if you return the crew to a station. 

### Lose reputation ###
- getting caught smuggling contraband - lose 1 point to a min of Untrusted
- attacking factions allied to the controlling faction - Lose 2 points to a min of Hostile
- attacking faction authority - Lose 3 points to a min of Hostile.

* Ally
	- Help players in battle if there is an ally ship nearby
	- Best trade prices
	- Ability to purchase special ships/items
	- High priority to respond to calls for distress if outside the faction's controlled space. Will travel outside faction's controlled space to reach you (if they hear the distress call in the first place)
	- Fees and punishment for crimes are less severe (but still lower reputation)
	- Rare to be scanned/bothered by faction authority unless in high security sectors.
* Friendly
	- Better trade prices
	- Less likely to be scanned by faction authority
	- Will respond to distress calls; but won't leave safe space to reach you.
* Neutral
	- Normal trade prices
	- Will be scanned when near faction authority.
* Untrusted
	- Worse trading prices
	- Faction authority will send a ship to scan you if you are in their space
	- Shady dealers inside the faction may be wary of doing business as you getting caught may lead the authorities back to the shady dealer
	- Certain shady dealers may offer more lucritive jobs with higher risk of lowering your reputation further with the controlling faction.
* Hostile
	- No trading at normal traders; they won't trade with an enemy (if you can even get close to a trading post in the first place)
	- Faction authority will scan their sectors looking for your ship, and if detected, will treat you as an enemy, sending ships to hunt you down (until you leave the faction's controlled space or raise your reputation)
	- Shady dealers in other factions may offer high paying high risk jobs that have you go into hostile faction territory
	- Gain reputation for factions that are also hostile to the same faction (enemy of my enemy is my friend).


## Trade & Economy

We will define some number (maybe 10-20) of commodity types.  Each planet/station will buy and sell some subset of these, at prices that vary from place to place, and can change in response to events.

Prices can also change in response to buying/selling; if you sell a lot of something at one location, the price goes down; and if you buy a lot in one place, the price goes up.  This stops the player from finding one profitable commodity/route and milking it over and over, forcing them to explore the galaxy more.

Some commodities are legal everywhere; others are illegal in certain systems (and exactly *which* items are illegal is not always the same).  A warning flag will appear on the map by any destination that considers something in your hold to be illegal.  Illegal goods may still be bought and sold on the black market, often at much higher prices.

While most cargo buying/selling is done at planet/station markets, you may occasionally encounter another trader in open space (i.e. when departing or arriving).  In this case the other ship presents the market UI for any items they are willing to buy or sell.  Goods may also be gained or lost (sometimes in exchange for money) by scripted events.

### Commodities

- Water (low tech)
- Wood (low tech)
- Food (low tech)
- Ore (low tech)
- Medicine (med/high tech)
- Machines (high tech)
- Robots (high tech; illegal on AI worlds)
- Games (illegal on theocratic worlds)
- Firearms (illegal on democratic and theocratic worlds)
- Narcotics (illegal on all but anarchist worlds)

## Combat

Ship-to-ship combat is similar to FTL: it happens in real time, with an RTS-like element of directing your crew while also managing ship resources (mainly power) and weapons.  Actions you may take during combat:

- rebalance power among ship systems
- fire weapons (each weapon has a cooldown period)
- open/close doors
- offer or demand surrender
- attempt to flee
- order crew to:
	- repair damaged equipment or hull breach
	- put out fires
	- teleport to enemy ship (if not protected by energy shields)
	- man weapons/piloting/power systems (improving these systems' efficacy)

Note that many rare or even story-driven capabilities will be represented in the game as a piece of equipment, and activated by sending a crewmate to it.  For example, if you have some alien cloaking system, you could send a crewmate to it in battle, making your ship seem to disappear.  The enemy ship would then cease attacking or break off pursuit.  (Presumably such an item would have limited uses, or be counterable in some way, so as to not break the game.)


## Encounters/Events

Scripted encounters and events can happen when approaching or departing a system, while visiting a station bar, or occasionally during/after combat.  These are little mini-programs that can present modal dialogs, giving you some information and often prompting you to choose between two or more response options.

Each of these mini-programs maintains its own state, and can examine and affect the state of the game, allowing for multi-step missions and stories to unfold.

## Lose the Game ##

It is possible to lose the game all crewmembers die at the same time. Events that pose a riks of game over are very clearly telegraphed and should always include an option to turn away. Death and Game Over will never come as a surprise to the player but is the result of an informed and calculated risk.
