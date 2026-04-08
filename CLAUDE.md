# Starfarer — Claude Notes

## Project
A Mini Micro game (MiniScript) about managing the crew of a merchant spaceship. See `notes/DESIGNDOCUMENT.md` for the full design.

## Source Layout
- `user/src/` — all game source modules
- `user/lib/` — shared utility libraries (`miscUtil.ms`, `spriteUtil.ms`)
- `user/encounters/e*/encounter.ms` — individual encounter scripts
- `user/ships/*/shipData.ms` — ship layout definitions
- `user/startup.ms` → `user/devmenu.ms` → game entry point

## Source Index
See `notes/SRC_INDEX.md` for a full bidirectional index: every file described, and every class/global function mapped back to its file.

## Key Globals
- `game` — the `Starfarer` singleton (game state, money, fuel, stations)
- `playerShip` — the player's `Ship` instance
- `Door`, `Item` — pushed to globals by `door.ms` and `item.ms`
- `max()`, `min()` — pushed to globals by `miscUtil.ms`
- `gfx` — alias for `disp.uiPixel` (pixel drawing display)
- `fonts` — map of all loaded bmfFonts (e.g. `fonts.Arial14`)

## Conventions
- MiniScript: prototype-based OOP; use `new Foo` and `Foo.make(...)` factories
- `ensureImport "module"` is the standard way to import (idempotent)
- Unit tests live in `runUnitTests` functions; run via `user/test/runTests.ms`
- Each module has a `demo` function runnable standalone via devmenu (or by directly loading and running the file)
