# Starfarer Source Index

> Auto-generated reference for future AI sessions. Last updated 2026-04-08.
> All source lives under `user/`. The game engine is Mini Micro (MiniScript).

---

## Architecture Overview

The game is a top-down merchant spaceship crew manager (FTL-like). Display is Mini Micro's layered system:

| Layer | disp alias | Mode | Purpose |
|-------|-----------|------|---------|
| 7 | `disp.background` | pixel | Star-field background |
| 6 | `disp.shipSprites` | sprite | Ship floor plan, crew, items, shots |
| 5 | `disp.shipOverlays` | pixel | Air-quality overlay (red tint) |
| 4 | `disp.fog` | solidColor | Sensor-malfunction fog |
| 3 | `disp.uiPixel` / `gfx` | pixel | UI panels, labels, bars |
| 2 | `disp.uiSprites` | sprite | Cursor, UI sprites |
| 1 | `disp.curtain` | solidColor | Fade-to-black / damage flash |
| 0 | `disp.text` / `text` | text | Debug text only |

### Boot sequence
```
startup.ms → devmenu.ms → (user picks a module to run)
                         → starfarer.ms  (the main game)
```

### Main loop (in `Starfarer.run`)
Each frame: processInput → shipDisplay.update → playerShip.update → enemy.update → uiWidgets.update → playerUI.update → minionUI.update → state-specific updates → yield

### Game states (`Starfarer.state`)
`STATE_NONE → STATE_AT_STATION ↔ STATE_NAVMAP → STATE_TRAVEL ↔ STATE_COMBAT → STATE_COMBAT_OVER → STATE_TRAVEL`

---

## Files

### `user/startup.ms`
Boot script — just loads and runs `devmenu`.

---

### `user/devmenu.ms`
Developer launcher menu. Lists all `.ms` files in `user/src/` and lets you run one, or run unit tests via `user/test/runTests.ms`.

---

### `user/lib/miscUtil.ms`
Small global utilities. Adds `max`, `min` to the global namespace; `rollDie(sides)` in module scope; extends `list` with `insertAfter(afterWhat, itemToAdd)`.

| Symbol | Kind | Notes |
|--------|------|-------|
| `max(a,b)` | global fn | pushed into `globals` |
| `min(a,b)` | global fn | pushed into `globals` |
| `rollDie(sides)` | fn | module-level |
| `list.insertAfter` | method | extends built-in list |

---

### `user/lib/spriteUtil.ms`
Sprite helpers. Extends the built-in `Sprite` class; adds `SpriteLerper`.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Sprite.positionAtIndex(spriteDisp, desiredIndex)` | method | reorder within a SpriteDisplay |
| `SpriteLerper` | class | animate position/scale/fade-in/fade-out over time |
| `SpriteLerper.init(sprite)` | method | snapshot start state |
| `SpriteLerper.apply(sprite)` | method | call each frame |
| `SpriteLerper.isDone()` | method | true when elapsed >= duration |

---

### `user/src/constants.ms`
Global constants and tiny math helpers. Everything exported into `globals`.

| Symbol | Kind | Value / Notes |
|--------|------|--------------|
| `EAST/NORTH/WEST/SOUTH` | global consts | 0/1/2/3 |
| `DIRECTIONS` | global | `range(0,3)` |
| `CELLSIZE` | global const | 20 px |
| `Celltype` | global map | `.STANDARD=0`, `.CARGO_IN=1`, `.CARGO_OUT=2` |
| `dx(dir)` | global fn | x-delta for a direction |
| `dy(dir)` | global fn | y-delta for a direction |
| `dirFromDelta(dy, dx)` | global fn | float direction (not rounded) |
| `inverseDir(dir)` | global fn | opposite direction |

---

### `user/src/setup.ms`
Module-level setup code (no classes). Run once at import. Configures all display layers, loads all fonts into `globals.fonts` (e.g. `fonts.Arial14`, `fonts.ArialBlack14`), sets `globals.gfx = disp.uiPixel` and `globals.text = display(0)`.

| Symbol | Kind | Notes |
|--------|------|-------|
| `disp` | global map | all display layers (see table above) |
| `gfx` | global | alias for `disp.uiPixel` |
| `text` | global | alias for `disp.text` |
| `fonts` | global map | all loaded bmfFonts, keyed by name |
| `showProgress(msg)` | fn | loading-screen helper |
| `loadFont(filename)` | fn | loads one .bmf font into `fonts` |
| `loadFonts()` | fn | loads all fonts in `/usr/fonts` |

---

### `user/src/pics.ms`
Image loading and caching. Provides `Image9Slice` (pushed to `globals`), a `get()` cache, crate images, and portrait images.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Image9Slice` | global class | 9-slice scalable image; `Make(image,l,b,r,t)`, `draw(l,b,w,h,tint)` |
| `pics.get(path, failSilently)` | fn | load/cache image from `/usr/pics/` |
| `pics.get9slice(path, ...)` | fn | load/cache Image9Slice |
| `pics.crates` | map | `blank/food/guns/medicine/water/games/machines/narcotics/ore/robots/wood` |
| `pics.portrait.human.male` | list | indexed portrait images |
| `pics.portrait.human.female` | list | indexed portrait images |
| `pics.portrait.human.any` | fn | random portrait from either list |
| `pics.drawX(l,b,w,h)` | fn | debug helper |

---

### `user/src/sounds.ms`
Sound effect loading and playback. Extends `Sound` with positional variant.

| Symbol | Kind | Notes |
|--------|------|-------|
| `PositionalSound` | class | extends `Sound`; `playAt(x, volume, speed)` |
| `PositionalSound.load(filename)` | method | loads from `/usr/sounds/` or `/sys/sounds/` |
| `doorOpen`, `doorClose` | sound instances | |
| `warp` | sound instance | |
| `laserFire`, `laserHit` | sound instances | |
| `shieldUp`, `shieldHit` | sound instances | |

---

### `user/src/randomNames.ms`
Procedural name generation.

| Symbol | Kind | Notes |
|--------|------|-------|
| `generic()` | fn | random capitalized word |
| `station()` | fn | currently same as `generic` |
| `human()` | fn | syllable-based human name |
| `words` | list | loaded from English + German word files |

---

### `user/src/item.ms`
Cargo item types — both data model and view (each is a `Sprite` subclass).

| Symbol | Kind | Notes |
|--------|------|-------|
| `Item` | global class | base Sprite with `name`, `blocksWalking`, `col/row`, `lerper`, `typicalValue`; pushed to `globals` |
| `Item.update(dt)` | method | drives `lerper` |
| `Item.fadeIn(dx,dy)` | method | spawn animation |
| `Item.fadeOut(dx,dy)` | method | removal animation |
| `Item.lerpTo(screenPos,scale,duration)` | method | move/scale tween |
| `WaterItem` | class | typicalValue=25 |
| `FoodItem` | class | typicalValue=115 |
| `WoodItem` | class | typicalValue=250 |
| `OreItem` | class | typicalValue=400 |
| `GamesItem` | class | typicalValue=260 |
| `MedsItem` | class | typicalValue=500 |
| `MachinesItem` | class | typicalValue=750 |
| `RobotsItem` | class | typicalValue=2500 |
| `GunsItem` | class | name="firearms", typicalValue=950 |
| `NarcoticsItem` | class | typicalValue=2000 |
| `allTypes` | list | all 10 item types in canonical order |
| `getByName(typeName)` | fn | look up item type by string name |

---

### `user/src/door.ms`
Door — both model and view (a `spriteControllers.Animated` subclass). Pushed to `globals.Door`.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Door` | global class | `isOpen`, `canOpen`, `tint`, `curUsers[]`, `power` |
| `Door.make()` | factory | creates a new door with cloned animations |
| `Door.open(withSound)` | method | |
| `Door.close(withSound)` | method | |
| `Door.toggle(withSound)` | method | |
| `Door.openForUser(user)` | method | push user, open if needed |
| `Door.userDone(user)` | method | pop user; auto-close if powered |

---

### `user/src/systems.ms`
Ship systems — all the equipment that can be installed on a ship.

| Symbol | Kind | Notes |
|--------|------|-------|
| `System` | class | base; props: `name`, `col/row`, `width/height`, `image`, `maxPower/curPower/setPoint`, `repairLevel`, `disabled`, `powerControlClass`, `powerControl`, `needsDisplay`, `needsRedistribute`, `canUpgrade`, `icon` |
| `System.make(col,row,w,h,name)` | factory | |
| `System.makeInvisible(name, maxPower)` | factory | invisible (0×0) system |
| `System.use(character, dt)` | method | repair logic; subclasses call `super.use` |
| `System.maxPossiblePower()` | method | min(setPoint, floor(repairLevel), maxPower-disabled) |
| `System.update(ship, dt)` | method | override per subclass |
| `System.containsColRow(col,row)` | method | |
| `System.takeDamage(pts)` | method | |
| `System.upgradeCost()` | method | 250 + 100*maxPower |
| `System.upgrade()` | method | +1 maxPower |
| `MedBay` | class | 2×2; heals crew using it |
| `O2` | class | 2×1; generates air; `airPerSec()` |
| `Sensors` | class | 2×1; visibility |
| `Controls` | class | 2×1; evasion/dodge |
| `Engines` | class | 2×2; propulsion |
| `Reactor` | class | 2×2; power source; `canUpgrade=true` always |
| `Doors` | class | 0×0 invisible; controls door auto-close |
| `DoorPowerControl` | class | extends `uiWidgets.PowerControl`; custom icon-tap UI for doors |
| `DoorPowerControl.handleShipClick(ship, screenPos, mapPos)` | method | toggle clicked door |
| `Shields` | class | 2×2; `curLayers`; recharges each frame |
| `Weapons` | class | 2×2; `curCharge/maxCharge`; auto-fires when charged |
| `Weapons.fire(owningShip)` | method | creates a `Shot` |
| `Shot` | class | Sprite subclass; animated projectile |
| `Shot.init(target, travelTime)` | factory | |
| `Shot.update(dt)` | method | animates arc; calls `target.takeDamage` on arrival |

Each concrete system class has a `make(col, row)` factory method.

---

### `user/src/shipModel.ms`
Ship data model. Defines the grid layout, walls, cells, and all ship state.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Wall` | class | `name`, `isOpen=false`, `canOpen=false` |
| `Cell` | class | `contents`, `col/row`, `air`, `fire`, `walls[4]`, `broken`, `repairLevel`, `type` |
| `Cell.make(col,row)` | factory | |
| `Cell.placeItem(item)` | method | |
| `Cell.walkable()` | method | true if contents==null or !blocksWalking |
| `Cell.canExitInDir(dir, assumeDoorsOpen)` | method | |
| `Cell.damage()` | method | sets `broken=true` |
| `Cell.repair(dt)` | method | increments `repairLevel` |
| `Ship` | class | the full ship state (see below) |
| `allDesigns` | list | all loaded ship designs (populated by `loadAll`) |
| `loadAll()` | fn | loads all `/usr/ships/*/shipData.ms` |
| `newShipOfDesign(designName)` | fn | returns `new <design>` |

**Ship properties**: `name`, `value`, `maxHp/hp`, `jumpFuel`, `directory`, `mapOffset`, `minions[]`, `incomingTypes[]`, `outgoingTypes[]`, `systems[]`, `reactor`, `inCombat`, `targetSpots[]`, `airTick`, `airChanged`, `isPlayer`, `columns`, `rows`, `columnRange`, `rowRange`, `map[][]`, `cargoSpots[]`

**Ship methods** (selection):
- `init(columns, rows)` — blank map
- `designName()` — `self.__isa.name`
- `distributePower()` — allocate reactor power to all systems
- `takeDamage(shot, mapPos)` — shields, hull, crew, system, cell damage
- `transferContents(newShip)` — move cargo & crew (for ship purchase)
- `walkable(colRow)`, `walkableNeighbors(colRow)` — for pathfinding
- `getCell(col,row)`, `minionAt(col,row)`, `systemAt(col,row)`
- `findSystemOfType(systemClass)` — first system of a given class
- `getFreeCargoInCells()`, `getAnyFreeCargoInCell()`, `getFullCargoInCells()`, `getCargoOutCells()`, `firstEmptyStorageCell()`
- `addCargo(item)`, `removeCargo()`, `addPurchasedItemType(itemType)`, `noteItemSold(itemType)`, `qtyOwnedOfType(type)`
- `findOutgoingItems()` — items on board that have been sold but not delivered
- `airSimulation(dt)` — O2 diffusion / consumption per cell
- `update(dt)` — drives all systems + air sim
- `healCrew()` — restore all crew to full health (used on docking)
- Ship-building helpers: `digRoom`, `place`, `placeRoom`, `placeDoor`, `placeBottomWalls/TopWalls/LeftWalls/RightWalls`, `removeWall`, `addSystem`, `allDoors()`
- Debug: `print()`, `printWalls*()`, `draw()` (gfx debug render)

---

### `user/src/shipDisplay.ms`
Renders a ship (and all its sprites) onto the display. Can handle multiple ships simultaneously.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Renderer` | class | one per ship on screen |
| `Renderer.renderShip(ship)` | method | full setup of a ship renderer |
| `Renderer.addSprite(image,x,y,baseClass)` | method | tracked sprite helper |
| `Renderer.renderMinion(minion)` | method | |
| `Renderer.renderDoors(cell)` | method | |
| `Renderer.renderContents(cell)` | method | |
| `Renderer.removeCellContents(cell)` | method | |
| `Renderer.renderTargets()` | method | enemy target reticles |
| `Renderer.screenToMapPosition(point)` | method | pixel → `{col, row}` |
| `Renderer.mapToScreenPosition(point)` | method | `{col,row}` → `{x, y}` (cell center) |
| `Renderer.breakCell(mapPos)` | method | visual break + model damage |
| `Renderer.renderBroken(mapPos)` / `removeBroken` | methods | broken-cell overlay sprite |
| `Renderer.renderShipSystems()` | method | draws system images; creates shield sprite |
| `Renderer.updateShields()` | method | tint shield sprite per layer count |
| `Renderer.renderAirValues()` | method | red overlay per cell air quality |
| `Renderer.updateSelectionReticles()` | method | green/clear tint on minion reticles |
| `Renderer.stop()` | method | tear down all owned sprites |
| `Renderer.update(dt)` | method | handle buy/sell animations, shields, air |
| `TargetSprite` | class | Sprite subclass for enemy-target reticle |
| `renderers` | list | global list of active Renderer instances |
| `update(dt)` | fn | module-level; updates all renderers + all sprites |
| `BROKEN_CELL_IMAGE`, `SHIELD_GLOW_IMAGE` | consts | cached images |

---

### `user/src/character.ms`
Crew member (and any humanoid NPC). Both model and view (`spriteControllers.Animated` subclass).

| Symbol | Kind | Notes |
|--------|------|-------|
| `AnimSet` | class | idle[4] + walk[4] animations per direction |
| `AnimSet.make(sheet)` | factory | |
| `Character` | class | the crew/NPC sprite |
| `Character.boardShip(ship, atPosition)` | method | adds to ship.minions, creates reticle, assigns brain |
| `Character.leaveShip()` | method | |
| `Character.moveTowards(screenPos, amount)` | method | |
| `Character.openDoorIfNeeded()` | method | used in path following |
| `Character.updateAnimation(dt)` | method | |
| `Character.update(dt)` | method | main per-frame: path-follow, anim, brain, repair/use |
| `Character.updateCarriedItem()` | method | position carried item relative to self |
| `Character.turnToFaceScreenPos(pos)` | method | |
| `Character.pickUp(item)` | method | immediate or path-find to item |
| `Character.dropItem(onPos)` | method | immediate or path-find to destination |
| `Character.goTo(mapPos)` | method | issues a `DirectOrderActivity` via brain |
| `Character.useSystem(dt)` | method | delegates to `usingSystem.use(self, dt)` |
| `Character.setUseSystem(system)` / `clearUseSystem()` | methods | |
| `Character.autoUse()` | method | starts using system at current cell |
| `Character.takeDamage(healthLost)` | method | |
| `Character.setMapPos(pos)` / `getMapPos()` | methods | |
| `Character.setScreenPos(point)` / `getScreenPos()` | methods | |

**Key properties**: `name`, `ship`, `renderer`, `anims`, `facing`, `walking`, `carrying`, `speed`, `path`, `usingDoor`, `col/row`, `usingSystem`, `maxHealth/health`, `brain`, `reticle`

---

### `user/src/charAI.ms`
Utility-based AI for crew members (and potentially enemies).

| Symbol | Kind | Notes |
|--------|------|-------|
| `Need` | class | `name`, `value`, `incPerSecond`, `minValue/maxValue` |
| `Need.make(name, incPerSecond, maxValue)` | factory | |
| `Need.add(amount)` | method | clamped to maxValue |
| `Need.update(dt)` | method | auto-increment |
| `Activity` | class | `cost`, `benefit{name:reduction}`, `path` |
| `Activity.make(cost, need1, red1, ...)` | factory | up to 3 need reductions |
| `Activity.begin(character)` | method | sets path on character |
| `Activity.isDone(character)` | method | default returns false |
| `idle` | Activity instance | do-nothing, reduces "relax" |
| `work` | Activity instance | operate current room system |
| `heal(pathToMedBay, benefit)` | fn | returns Activity |
| `stow(pathToCargo)` | fn | returns Activity for cargo handling |
| `DirectOrderActivity` | class | extends Activity; player-issued goto order |
| `DirectOrderActivity.make(targetPos)` | factory | |
| `Brain` | class | all AI state for one agent |
| `Brain.make()` | factory | calls `init` |
| `Brain.init()` | method | sets up needs + default activities |
| `Brain.findActivities(character)` | method | rebuilds `activities[]` from ship state |
| `Brain.update(character, dt)` | method | main per-frame; updates needs, picks/runs activity |
| `Brain.choose(activities)` | method | picks highest benefit/cost activity |
| `Brain.applyBenefits(activity)` | method | reduce needs after activity completes |

**Built-in needs** on Brain: `hunger` (grows 1/sec), `sleep` (grows 0.1/sec), `heal`, `work`, `relax`

---

### `user/src/pathfinding.ms`
A* pathfinding on ship grid. Supports diagonal movement and doors.

| Symbol | Kind | Notes |
|--------|------|-------|
| `findPath(ship, startPos, endPos)` | fn | returns `[[col,row],...]` excluding start, including end |
| `findPathUpTo(ship, startPos, endPos)` | fn | path to a cell adjacent to a blocked target |

---

### `user/src/stationModel.ms`
Data model for space stations (the game world / galaxy).

| Symbol | Kind | Notes |
|--------|------|-------|
| `Station` | class | `name`, `market[]`, `cantina[]`, `x/y`, `government`, `techLevel`, `illegalTypes[]`, `exportTypes[]`, `police/pirates` (0-4) |
| `Station.init(name,x,y)` | method | randomizes government, tech, police/pirates, exports |
| `Station.fillCantina()` | method | delegates to `encounters.addNPCsToCantina` |
| `Station.addCommodityToMarket(itemType, price, isSold)` | method | price adjusted by export/illegal status |
| `Station.getCommodityBuyPrice(itemType)` | method | |
| `Station.getCommoditySellPrice(itemType)` | method | (same as buy for now) |
| `Commodity` | class | `itemType`, `itemPrice`, `soldHere`; `name()` method |
| `CantinaNPC` | class | `name`, `portrait`, `encounter` |
| `governments` | list | `["Anarchy","Democracy","Technocracy","Theocracy"]` |
| `techLevels` | list | `["Primitive","Agrarian","Industrial","Post-Industrial","Modern"]` |
| `howMany` | list | `["None","Few","Some","Many","Swarms"]` |
| `closestStation(xyPoint, stationList)` | fn | nearest station by distance |
| `randomStation()` | fn | generates a fully randomized station |
| `manyRandomStations(quantity)` | fn | generates galaxy, spaced min 50 units apart |

---

### `user/src/starmap.ms`
Star-map screen UI (navigation between stations).

| Symbol | Kind | Notes |
|--------|------|-------|
| `init()` | fn | loads star sheet images, creates selection sprite |
| `draw(stationList, curStation, jumpLimit)` | fn | renders map, jump lines, star icons |
| `hide()` | fn | clears map UI |
| `update(dt)` | fn | hover/click handling, info panel |
| `drawSystemInfoPanel(target)` | fn | shows station details + jump button |
| `eraseInfoPanel()` | fn | |
| `jump()` | fn | calls `jumpCallback(target)` |
| `jumpCallback` | module var | set by `Starfarer.enterState` to handle jumps |
| `backBtn` | module var | Button wired by `Starfarer.enterState` |
| `starImages` | module var | 2D array [col][row] of star images |

---

### `user/src/stationUI.ms`
Station docking UI: market, cantina, shipyard tabs.

| Symbol | Kind | Notes |
|--------|------|-------|
| `show(station, ...)` | fn | full station panel redraw |
| `hide()` | fn | clears all widgets |
| `showMarket(station, ...)` | fn | commodity list with buy/sell buttons |
| `showCantina(station, ...)` | fn | NPC list with portrait buttons |
| `showShipyard(station, ...)` | fn | upgrades + ships for sale + fuel/repair |
| `showTabs(station, ...)` | fn | market/cantina/shipyard tab buttons |
| `showNavButton()` | fn | NAV button → STATE_NAVMAP |
| `addCommodity(...)` | fn | one commodity row |
| `addCantinaNPC(...)` | fn | one NPC button |
| `addBottomButton(caption, right, width)` | fn | bottom-row button |
| `upgradeButtonAction` | fn | purchase a system upgrade |
| `buyShipButtonAction` | fn | purchase a new ship |
| `buyFuel()` / `buyRepair()` | fns | purchase fuel/repairs |
| `SHOW_MARKET/CANTINA/SHIPYARD` | consts | 0/1/2 |
| `NPCButton` | class | Button subclass drawing portrait |
| `tabs`, `activeButtons` | module vars | |

---

### `user/src/playerUI.ms`
HUD elements: credits, hull bar, fuel bar, power controls, travel info, combat info.

| Symbol | Kind | Notes |
|--------|------|-------|
| `show()` | fn | draw all HUD elements and power controls |
| `selectControl(powerControl)` | fn | exclusive selection of a PowerControl; returns true/false |
| `showTravel(station, distance, arriving)` | fn | travel-mode labels and progress bar |
| `hideTravel()` | fn | |
| `showCombat()` | fn | flee button + enemy hull bar |
| `showContinueJump()` | fn | CONTINUE button after combat ends |
| `hideCombat()` | fn | |
| `update(dt)` | fn | sync labels/bars to current game state |
| `fuelBar`, `hullBar`, `moneyLabel` | module vars | |
| `enemyHullBar`, `fleeButton` | module vars | |
| `powerControls[]` | module var | list of PowerControl widgets |
| `selectedControl` | module var | the currently selected PowerControl (if any) |

---

### `user/src/minionUI.ms`
Left-side crew status panel (names + health bars).

| Symbol | Kind | Notes |
|--------|------|-------|
| `show(crew)` | fn | rebuild from crew list |
| `clear()` | fn | stop all nametags and healthbars |
| `update(dt)` | fn | sync labels/bars to current crew state |
| `updateSelection()` | fn | highlight selected crew in lime green |
| `addMinion(minion)` | fn | add one crew row |
| `removeMinion(minion)` | fn | remove one crew row and rebuild |

---

### `user/src/uiWidgets.ms`
All reusable UI widget classes.

| Symbol | Kind | Notes |
|--------|------|-------|
| `ALIGNLEFT/CENTER/RIGHT` | consts | 0/1/2 |
| `Widget` | base class | axis-aligned rect; `init`, `start`, `stop`, `draw`, `erase`, `redraw`, `update`, `contains` |
| `Panel` | class | Image or Image9Slice background; `captureBackground()`, `stop()` restores |
| `Label` | class | text display; `setText`, `setColor`, `wrap`, `resetHeight` |
| `Bar` | class | filled bar, value -1..1 (negative fills from right) |
| `ThinBar` | class | extends Bar; thinner, two-color |
| `HorizontalSlider` | class | draggable ThinBar |
| `PowerControl` | class | vertical power-bar widget for a System; `initSystem`, `drawBar`, `onIconTap`, `onChange` |
| `ChargedPowerControl` | class | extends PowerControl; adds vertical charge bar (for Weapons) |
| `ValuedBar` | class | Bar + "value/max" Label; `setValue(value, maxValue)`, `setColor` |
| `Button` | class | push button; `action` fn, `enabled`, `setEnabled`, `caption` (string or Label) |
| `TabButton` | class | extends Button; stays pressed after click |
| `LineEdit` | class | single-line text input |
| `clearAll()` | fn | stop all widgets + clear gfx |
| `redrawAll()` | fn | |
| `update(dt)` | fn | **must be called each frame**; updates mouse state + all widgets |
| `reset()` | fn | erase all widgets without stopping them |
| `_allWidgets` | module var | list of all active widgets |
| `mousePressed`, `mouseDown`, `mouseUp` | module vars | set by `update()` each frame |
| `load9SliceImage(name, ...)` | fn | shortcut to `Image9Slice.Make(pics.get(name), ...)` |

---

### `user/src/effects.ms`
Visual effects.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Warp` | map (singleton) | warp flash effect |
| `Warp.run()` | method | starts the effect |
| `Warp.update(delta)` | method | drives `disp.curtain` fade; call each frame |
| `Warp.speed` | property | 1=slow, 3=fast |

---

### `user/src/dialogs.ms`
Modal dialog box system.

| Symbol | Kind | Notes |
|--------|------|-------|
| `DialogOptions` | global map | `buttonsPerRow=1`, `captionAlign`, `portrait`, `onScreen` |
| `showGeneric(whereText, text, choices, options)` | fn | **blocks until user clicks**; returns choice index (or null for OK-only) |

---

### `user/src/encounters.ms`
Encounter system: loads encounter scripts, plans which ones to show during travel, and routes cantina NPCs.

| Symbol | Kind | Notes |
|--------|------|-------|
| `encounterList` | list | all loaded Encounter instances |
| `init()` | fn | loads all encounters from `/usr/encounters` |
| `loadEncountersFromFolder(path)` | fn | recursive folder scan |
| `loadOneEncounter(parentPath, filename)` | fn | imports encounter module |
| `planEncounters(sourceStation, destStation)` | fn | call at start of travel; builds `pending[]` |
| `update(dt)` | fn | call each frame during travel; fires encounters at right time |
| `addNPCsToCantina(station)` | fn | call when docking; populates `station.cantina` |
| `pending` | module var | sorted list of planned encounter events |
| `elapsed` | module var | time since travel started |
| `event` | module var | most recently fired encounter event |

---

### `user/src/encounterBase.ms`
Base classes for encounters.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Encounter` | class | base; `ship` property |
| `Encounter.consider(station, arriving)` | method | 20% chance; returns consideration or null |
| `Encounter.consideration(station, arriving, priority, distance)` | method | builds consideration map |
| `Encounter.present(data)` | method | override in subclasses |
| `Encounter.addNPCsToCantina(station)` | method | override for cantina NPCs |
| `Encounter.presentNPC(npc)` | method | override for NPC click |
| `Encounter.showDialog(dataOrStation, text, choices, dialogOpts)` | method | convenience wrapper around `dialogs.showGeneric` |
| `CombatEncounter` | class | extends Encounter |
| `CombatEncounter.updateCombat(dt)` | method | calls `enemyAI.update` |
| `CombatEncounter.destroyShip()` | method | shows dialog, tears down renderer |
| `CombatEncounter.handleFlee(dataOrStation, failMsg)` | method | 50% flee chance |
| `CombatEncounter.removeOtherShip()` | method | tear down enemy renderer |

---

### `user/src/enemyAI.ms`
Enemy ship AI during combat.

| Symbol | Kind | Notes |
|--------|------|-------|
| `update(encounter, dt)` | fn | main entry point from `CombatEncounter.updateCombat` |
| `updateTargeting()` | fn | picks new random target on player ship every 3–6 sec |
| `updatePower()` | fn | every 1–1.5 sec: max Reactor/O2/Weapons, zero everything else |

---

### `user/src/starfarer.ms`
**Main game script** — the top-level game object and main loop.

| Symbol | Kind | Notes |
|--------|------|-------|
| `Starfarer` | class | singleton; instantiated as global `game` |
| `game` | global | the `Starfarer` instance |
| `Starfarer.STATE_*` | consts | `NONE/AT_STATION/NAVMAP/TRAVEL/COMBAT/COMBAT_OVER` |
| `Starfarer.init()` | method | create player ship, crew, galaxy, renderer; enter AT_STATION |
| `Starfarer.run()` | method | **main loop** |
| `Starfarer.cleanup()` | method | |
| `Starfarer.enterState(newState)` | method | calls exitState then sets up new state |
| `Starfarer.exitState(toNextState)` | method | tears down current state UI |
| `Starfarer.updateTravel(dt)` | method | advance `travelProgress`, handle arrival/departure |
| `Starfarer.beginCombat(encounter)` | method | |
| `Starfarer.fleeCombat()` | method | |
| `Starfarer.continueJump()` | method | |
| `Starfarer.destroyShip(ship)` | method | game over (player) or combat won (enemy) |
| `Starfarer.handlePlayerShipClick(pos)` | method | select minion, pick up item, or give move order |
| `Starfarer.handleEnemyShipClick(pos)` | method | set weapon target on enemy ship |
| `Starfarer.handlePrimaryClick(pos)` | method | routes to player or enemy ship |
| `Starfarer.handleSecondaryClick(pos)` | method | (currently unused) |
| `Starfarer.processInput()` | method | mouse buttons + background scroll |
| `Starfarer.selectedMinion` | property | list of selected Character instances |
| `Starfarer.money`, `fuel`, `maxFuel` | properties | |
| `Starfarer.stations[]`, `station`, `nextStation` | properties | galaxy + current/next station |
| `Starfarer.combatEncounter` | property | current CombatEncounter or null |
| `Starfarer.travelProgress` | property | 0–2 (0–1 departing, 1–2 arriving) |
| `Starfarer.renderer` | property | the Renderer for the player ship |

---

### `user/src/maintenance.ms`
Maintenance Bay screen (work-in-progress) — drag-and-drop ship system arrangement.

| Symbol | Kind | Notes |
|--------|------|-------|
| `SystemSprite` | class | Sprite subclass; wraps a System for drag-drop |
| `SystemSprite.Make(system, x, y)` | factory | |
| `SystemSprite.fitsAt(col, row)` | method | bounds check on ship map |
| `SystemSprite.snapToPosition()` | method | snaps to nearest grid cell if close |
| `SystemSprite.handleClick()` | method | drag while mouse held |
| `SystemSprite.HandleClick()` | class fn | find and handle any clicked instance |
| `drawShip()` | fn | module-local ship drawing |
| `drawWall(...)` | fn | module-local wall drawing |
| `setup()` | fn | init the maintenance screen |
| `mainLoop()` | fn | event loop |

---

### `user/encounters/e001–e010/encounter.ms`
Individual encounter scripts. Each exports a single `encounter` variable (an `Encounter` subclass instance). Known types include:

- **e001**: Space anomaly (transit) — 20% chance, awards 5–14 credits
- Other encounters include combat encounters and NPC/cantina encounters

Each follows the pattern:
```
encounter = new encounterBase.Encounter  // or CombatEncounter
encounter.consider = function(station, arriving) ... end function
encounter.present = function(data) ... end function
// optionally:
encounter.addNPCsToCantina = function(station) ... end function
encounter.presentNPC = function(npc) ... end function
```

---

### `user/ships/*/shipData.ms`
One file per ship design. Each creates a `ship` variable (a `new shipModel.Ship`) and sets up its layout.

| Ship | Columns×Rows | Notable Systems |
|------|-------------|-----------------|
| `wren` | 4×7 | Reactor, Doors, Engines, Controls, O2; value=5000 |
| `robin` | ? | (full complement; referenced in demos) |
| `hummingbird` | ? | |
| `freighter` (disabled) | ? | |

Each `shipData.ms` is loaded by `shipModel.loadAll()` by scanning `/usr/ships/`.

---

## Reverse Index: Class/Function → File

| Symbol | File |
|--------|------|
| `Activity`, `Need`, `Brain`, `DirectOrderActivity` | `charAI.ms` |
| `AnimSet` | `character.ms` |
| `Bar`, `ThinBar`, `HorizontalSlider` | `uiWidgets.ms` |
| `Button`, `TabButton` | `uiWidgets.ms` |
| `Cell`, `Wall` | `shipModel.ms` |
| `CantinaNPC`, `Commodity`, `Station` | `stationModel.ms` |
| `Character` | `character.ms` |
| `ChargedPowerControl` | `uiWidgets.ms` |
| `CombatEncounter`, `Encounter` | `encounterBase.ms` |
| `Controls`, `Doors`, `DoorPowerControl` | `systems.ms` |
| `DialogOptions` | `dialogs.ms` |
| `Door` | `door.ms` (also `globals.Door`) |
| `Engines` | `systems.ms` |
| `Image9Slice` | `pics.ms` (also `globals.Image9Slice`) |
| `Item` + all commodity item classes | `item.ms` (also `globals.Item`) |
| `Label` | `uiWidgets.ms` |
| `LineEdit` | `uiWidgets.ms` |
| `MedBay` | `systems.ms` |
| `NPCButton` | `stationUI.ms` |
| `O2` | `systems.ms` |
| `Panel` | `uiWidgets.ms` |
| `PositionalSound` | `sounds.ms` |
| `PowerControl` | `uiWidgets.ms` |
| `Reactor` | `systems.ms` |
| `Renderer` | `shipDisplay.ms` |
| `Sensors` | `systems.ms` |
| `Shields` | `systems.ms` |
| `Ship` | `shipModel.ms` |
| `Shot` | `systems.ms` |
| `Sprite.positionAtIndex` | `spriteUtil.ms` |
| `SpriteLerper` | `spriteUtil.ms` |
| `Starfarer` (class) | `starfarer.ms` |
| `System` (base) | `systems.ms` |
| `SystemSprite` | `maintenance.ms` |
| `TargetSprite` | `shipDisplay.ms` |
| `ValuedBar` | `uiWidgets.ms` |
| `Warp` | `effects.ms` |
| `Weapons` | `systems.ms` |
| `Widget` | `uiWidgets.ms` |
| `addNPCsToCantina(station)` | `encounters.ms` |
| `allDesigns`, `loadAll()`, `newShipOfDesign()` | `shipModel.ms` |
| `allTypes`, `getByName()` | `item.ms` |
| `CELLSIZE`, `EAST/NORTH/WEST/SOUTH`, `Celltype` | `constants.ms` |
| `clearAll()`, `redrawAll()`, `update(dt)` (widgets) | `uiWidgets.ms` |
| `closestStation()`, `manyRandomStations()`, `randomStation()` | `stationModel.ms` |
| `dx()`, `dy()`, `dirFromDelta()`, `inverseDir()` | `constants.ms` |
| `encounterList`, `planEncounters()`, `update()` (encounters) | `encounters.ms` |
| `findPath()`, `findPathUpTo()` | `pathfinding.ms` |
| `fonts`, `gfx`, `text`, `disp` | `setup.ms` |
| `game` (global) | `starfarer.ms` |
| `max()`, `min()` | `miscUtil.ms` |
| `pics.get()`, `pics.crates`, `pics.portrait` | `pics.ms` |
| `playerShip` (global) | set in `starfarer.ms` init |
| `rollDie()` | `miscUtil.ms` |
| `showGeneric()` | `dialogs.ms` |
| `list.insertAfter()` | `miscUtil.ms` |
| Sound instances (`doorOpen`, `laserFire`, etc.) | `sounds.ms` |
| `human()`, `station()`, `generic()` (names) | `randomNames.ms` |
