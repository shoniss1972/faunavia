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

- [x] **KEYSTONE — an animal bails at zero comfort** (DONE 2026-07-18, commit
      d2601b7; see PLAYTEST_NOTES). Rough driving now costs you an animal. Comfort
      is per-passenger, keyed to temperament off the shared suspension jolt (timid
      rabbit frets and bails long before the placid wombat is bothered); at zero
      the animal hops off and the run continues but it scores nothing. Stars: 0
      empty / 1 someone-bailed / 2 all-arrived / 3 all-arrived-none-annoyed.
      Food/vet signs restore per-animal comfort (a lifeline); over-cab emote
      escalates to "About to jump!". This also folded in the old reaction-variance
      item — the crew now reacts as individuals. Verified by driving: careful vs
      reckless is a real star gradient, no level unwinnable.

  IMPORTANT — the keystone made the drive consequential, but it did NOT by itself
  fix the prep / signs / vehicle complaints below. It is the PRECONDITION that
  makes those worth building as real choices; the choices themselves still do not
  exist. The player currently has no control over loadout or vehicle — both are
  fixed per level (prep.gd iterates `level["deliver"]`/`["equipment"]`/`["vehicle"]`).
  Each item below is now its own design-and-build task, not a knock-on.

- [ ] Signs feel meaningless — PARTLY ADDRESSED. Food/vet now restore per-animal
      comfort, so reaching one saves an animal from the brink (the code path and
      "steadied just in time!" message exist). Still to confirm in real play that
      they READ as a lifeline; may need placement tuning (a sign right after a
      rough stretch) and a clearer on-pass cue. Re-drive and judge.
- [ ] Prep is administrative — NEEDS A CHOICE BUILT. Today prep is a confirm
      gate: the manifest is mandatory (`level["deliver"]` + required equipment),
      so there is nothing to decide. The keystone only makes a decision *worth*
      having; it does not create one. To make prep a real decision, add player
      freedom the stake can price, e.g.:
        - optional calming feed that costs a cargo slot but slows comfort drain →
          on a rough route, weigh feed vs another animal;
        - levels that offer more animals than capacity → choose who rides now;
        - a route/vehicle pick (below) surfaced at prep.
      Separate design work; not started. If we choose not to build a choice, the
      honest fallback is to cut the click-aboard step to an auto-load.
- [ ] Vehicle doesn't relate to the load — NEEDS A CHOICE BUILT. Vehicle is
      assigned per level (`level["vehicle"]`) and its stats are only speed/accel/
      fuel — nothing comfort-related, so a bigger vehicle is not a gentler ride.
      The keystone gives this meaning only once a choice or a felt difference
      exists. Options: add a suspension/smoothness stat so the truck rides gentler
      for fragile cargo, and/or let the player pick among unlocked vehicles so
      "which vehicle for this load" becomes a real tradeoff. Not started.
- [ ] Landscape is barren (owner replay). Independent of the keystone — pure
      scenery/juiciness now that the 2x camera shows the empty world. Add
      parallax features, foreground props, roadside detail. Cheap; do alongside.
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
