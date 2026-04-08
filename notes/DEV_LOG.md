## Apr 04 2026

This project has gotten quite far (v0.4) without a dev log, but I think it's time to start one.  We have other notes files, including [DESIGNDOCUMENT.md] and [TODO.md], but I still find it hard both to pick up where I left off, and to remember why certain things are the way they are, without a chronological log.

So today I dusted the project off, got it set up with CLAUDE.md and SRC_INDEX.md so that we can have Claude do some of the grunt work, and knocked off a hodgepodge of small fixes and enhancements.  The game seems pretty playable now; you can trade, fight, flee, repair and upgrade your ship, hire crew, and do various missions and random events.

A big difficulty in testing a game like this is that it takes a long time.  I'm hoping that a full (winning) play-through will take at least 2 hours.  And there will be a lot of stuff you can't get to right away, like combat, which requires earning enough credits to buy a better ship.

So, I think a game save/load feature has become essential for testing.  With that we'll be able to generate saved games in various states of progress, and test by loading those game files.

This is in progress, but has run into what looks like a bug in GRFON.parse.  It's not parsing the ship data correctly, and so it breaks when trying to restore it.  I'll have to fix that, and put the fixed grfon.ms into /usr/lib for now.
