# Faunavia Prototype TODO

## Gate 0 — Project boots

- [x] Initialise repository.
- [x] Add Godot project configuration.
- [x] Add a runnable placeholder main scene.
- [x] Open the project in the current stable standard Godot editor.
- [x] Confirm the project runs without warnings or import errors.
- [x] Run the placeholder scene on macOS.

## Gate 1 — Driving toy

**Question:** Is basic traversal readable and satisfying enough to continue?

- [x] Create one short side-view test route.
- [x] Add one simple vehicle with accelerate and brake controls.
- [x] Add stable, deliberately simplified wheel and suspension behaviour.
- [x] Add fuel consumption and one fuel pickup.
- [x] Add a finish point and restart control.
- [ ] Test keyboard and touch controls. (Keyboard verified; touch buttons wired but untested on a device.)

## Gate 2 — First passenger

**Question:** Does carrying an expressive animal materially improve the driving loop?

- [x] Add one animal passenger.
- [x] Add animal weight to vehicle handling.
- [x] Track a simple comfort state based on rough travel.
- [x] Show at least three reactions: content, annoyed, delighted.
- [x] Add a humorous loading interaction.
- [x] Complete five internal playthroughs and record observations.

## Gate 3 — Logistics puzzle

**Question:** Is preparation and animal arrangement fun, rather than administrative?

- [x] Add three animal types with size, weight, and temperament traits.
- [x] Add vehicle capacity.
- [x] Add one incompatibility rule.
- [x] Add a divided cage that resolves the incompatibility.
- [x] Add one equipment requirement from nets, leashes, gloves, feed, or ramp.
- [x] Add a basic mission preparation screen.
- [x] Build five short levels.

## Gate 4 — Progression slice

**Question:** Do players want the next vehicle and mission?

- [x] Add bicycle, jeep, and truck.
- [x] Add one trailer.
- [x] Add fuel, food store, vet station, and sanctuary route nodes.
- [x] Add stars and level unlocks.
- [x] Add six animals total.
- [x] Build 10–15 levels. (12 levels)
- [x] Add basic save progress.

## Gate 5 — External phone test

- [ ] Produce a phone-playable build.
- [ ] Test with at least 10 unfamiliar players.
- [ ] Observe without explaining controls or rules.
- [ ] Record completion, replay, confusion, smiles, and requests for more.
- [ ] Make an explicit continue, revise, or stop decision.

### Open from the first external test

- [ ] Passenger reaction variance. Comfort is one global 0..100 value, so the
      whole crew shares a mood: on the five-animal level all five wear the exact
      same face and change it on the same frame, which reads as a chorus rather
      than as passengers. Each animal already carries a `temperament` in
      `Animals.DATA` (placid wombat, timid rabbit, sly fox, slow tortoise, loud
      parrot, stubborn goat) that does nothing during the drive. Give comfort a
      per-animal value keyed off temperament — a timid rabbit frets long before a
      placid wombat notices — so a crew reacts as individuals and the loadout
      choice from Gate 3 changes how the drive *feels*, not just what it weighs.
      Feeds the tester's "driving style doesn't seem to make any difference"
      (item 4 below): variance is what makes a reaction legible as a *reaction*.
- [ ] Make driving consequential in the moment (Gate 5 item 4). Still open. The
      animals now carry real expressions, so the signal exists — what is missing
      is a stake attached to it.
- [ ] Branching routes so the fuel stop can be missed (Gate 5 item 3). Fuel is
      disabled behind `FUEL_ENABLED` in main.gd until this lands.

## Deferred until the prototype earns them

- Commercial artwork and animation pipeline.
- Native app-store release work.
- Advertising, purchases, analytics, accounts, or notifications.
- Procedural level generation.
- Water slosh simulation.
- Free-roaming animal AI or manual capture actions.
- Multiplayer, social systems, or live events.
- Large upgrade economy or multiple currencies.
