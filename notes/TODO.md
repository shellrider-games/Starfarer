This document is a loose list of near-term features we'd like to add (or bugs that need fixing).

Longer-term features can stay in DESIGNDOCUMENT or IDEAS.

## Features

- Shipyard tab: offer sale of new systems your ship doesn't already have.
- Add more ship types.
- Ship: when a cargo item is sold, put some kind of overlay on the crate so it's clear this one has already been sold (until a crewman can grab it and put it off the ship).
 
With the above features, you'll be able to start in a small (Hummingbird) ship, trade and explore to earn money, then upgrade to bigger ships.

Then, fleshing out the various mechanics:

- Add a crewman silhouette in the power area of any ship system that can be crewed.  Having a crewmember there is equivalent to an extra bar of power.  (_Later_, some systems may have two silhouettes, supporting up to two crew.)
- Rework system UI to better support controls.  Maybe tap the icon at bottom to switch to controls for that icon, rather than toggle power fully on/off.
- Add a Captain's Log at bottom right (when no system controls are selected).  This keeps a log of recent major events.
- "Ship for Sale" UI should show the ship and give stats about it, so you can make an informed purchase.
- A "maintenance bay" UI should allow you to install, remove, or upgrade your ship systems (including invisible systems and hull upgrades) right on a map of your ship.  Maybe this is where you do repairs, too.

## Bugs

- Sometimes when I tell my crewman to place a crate down on the right side of the ship, he starts to do it, then changes his mind and plops it down in the left cargo hold instead.  Haven't quite pinned down the circumstances but it seems easy to reproduce.
- When I have two crewmembers and sell something, both crewmen try to go get it and put it out the airlock.  They should coordinate better (one crewman "claim" the task, and nobody else tries to do it).
- If you click a doors "Open All" or "Close All" control button, it _also_ moves the targeting reticle (into empty space!).
- Encounters happen too quickly back to back.  There should always be at least a little bit of flight (a second or so of real time) between encounters.
