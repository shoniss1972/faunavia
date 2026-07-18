# Faunavia Prototype TODO

## Product direction — current truth (2026-07-18)

Faunavia is now a functioning vertical-slice prototype. The next phase is **not**
to add more systems or content. It is to prove that the existing idea is
interesting, understandable, replayable, and worth continuing.

### Core player promise

> **Choose a sensible rescue plan, then drive well enough that every
> opinionated animal stays aboard.**

Every feature must strengthen at least one of these four things:

1. **Plan** — make a real choice before or during the rescue.
2. **Drive** — read the terrain and control the vehicle with intent.
3. **Animals** — understand and care about distinct passengers.
4. **Reward** — know what happened, why it mattered, and what comes next.

Anything that does not serve one of those should be removed, automated, or
deferred.

### The three motivations the game must communicate

- **During the drive:** Can I keep everyone aboard?
- **At the result:** Can I improve this rescue and earn the missing star?
- **Across the campaign:** What new animal, route, or vehicle problem comes next?

The player should never need the designer to explain those motivations.

### Design rules for the next build

- **Never ask the player to click the only correct answer.**
- Do not keep a mechanic merely because it has already been implemented.
- No meter, route stop, item, screen, or stat without a visible stake.
- Prefer one memorable rule per animal over many small numerical differences.
- Prefer five excellent, distinct missions over twelve mechanically complete but
  similar missions.
- Do not add economy, upgrade trees, more animals, more equipment, or more levels
  until unfamiliar players understand the loop and voluntarily retry.
- Make consequences playful and clear: annoyance, refusal, bailing, lost stars,
  and missed opportunities — never injury or distress.

## Current prototype state

Implemented on `main`:

- 12 missions with varied lengths and terrain profiles.
- Cargo trike, jeep, truck, and trailer.
- Six animal species with size, weight, temperament, compatibility, equipment
  requirements, distinct sprites, and three moods.
- Level select, prep screen, stars, sequential unlocks, and saved progress.
- Keyboard and touch controls, portrait mobile layout, and HTML5 export.
- Per-animal comfort keyed to temperament.
- Rough driving can make an animal bail at zero comfort; the run continues but
  loses delivery credit and stars.
- Food and vet route nodes restore comfort.
- Fuel exists but is disabled behind `FUEL_ENABLED` until route choice makes it
  meaningful.

The key remaining weakness is not lack of functionality. It is that several
implemented systems still do not create real choices or clearly explain why the
player should replay or continue.

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
- [ ] Test touch controls on at least one real phone. Keyboard is verified; touch
      buttons are wired but not yet proven on-device.

## Gate 2 — First passenger

**Question:** Does carrying an expressive animal materially improve the driving
loop?

- [x] Add one animal passenger.
- [x] Add animal weight to vehicle handling.
- [x] Track comfort based on rough travel.
- [x] Show at least three reactions: content, annoyed, delighted.
- [x] Add a humorous loading interaction.
- [x] Complete five internal playthroughs and record observations.
- [x] Make comfort consequential: an animal bails at zero.
- [x] Make comfort per-animal and temperament-sensitive.

## Gate 3 — Logistics puzzle

**Question:** Is preparation and animal arrangement fun, rather than
administrative?

- [x] Add three animal types with size, weight, and temperament traits.
- [x] Add vehicle capacity.
- [x] Add one incompatibility rule.
- [x] Add a divided cage that resolves the incompatibility.
- [x] Add equipment requirements.
- [x] Add a basic mission preparation screen.
- [x] Build five short levels.
- [ ] Re-answer the Gate 3 question honestly. Current answer: **no**. The screen
      validates a predetermined manifest rather than offering a decision.

## Gate 4 — Progression slice

**Question:** Do players want the next vehicle and mission?

- [x] Add cargo trike, jeep, and truck.
- [x] Add one trailer.
- [x] Add fuel, food store, vet station, and sanctuary route nodes.
- [x] Add stars and level unlocks.
- [x] Add six animals total.
- [x] Build 10–15 levels. (12 levels)
- [x] Add basic save progress.
- [x] Make the next mission and vehicle desirable rather than merely unlocked.
      (Level-select hooks + result-screen teaser; see milestone 7.)
- [x] Show the player what new problem, character, route, or capability is coming.
      (Per-level `hook` teaser; see milestone 7.)

## Gate 5 — External phone test

- [ ] Produce and verify a phone-playable build on real devices.
- [ ] Test with at least 10 unfamiliar players.
- [ ] Observe without explaining controls, rules, scoring, or progression.
- [ ] Record completion, replay, confusion, smiles, and requests for more.
- [ ] Make an explicit continue, revise, or stop decision.

### Gate 5 success evidence

The prototype earns expansion only when unfamiliar players can:

- explain why an animal became upset or bailed;
- explain why they chose a route, vehicle, or optional aid;
- understand the star result without explanation;
- identify what they could do differently for a better result;
- retry voluntarily after a weak result;
- express curiosity about the next animal, route, or vehicle.

## Next milestone — prove the fun and the reason to continue

This is the authoritative order of work. Do not skip ahead to upgrades, economy,
more content, or broad polish.

### 1. Remove fake preparation decisions

**Problem:** The prep screen currently asks the player to select every required
animal and item. Departure is blocked until they reproduce the predetermined
answer. That is validation, not gameplay.

- [ ] Auto-load mission-required animals.
- [ ] Auto-include mandatory safety/handling equipment, or treat it as an unlocked
      capability rather than a repeated toggle.
- [ ] Show preparation only when the player has at least two valid plans with a
      meaningful trade-off.
- [ ] When no real choice exists, go directly from a concise mission brief to the
      drive.
- [ ] Remove any remaining click whose only function is to confirm the one correct
      answer.

Possible future **real** prep choices, to build one at a time rather than all at
once:

- optional calming feed occupies capacity but slows comfort loss;
- more rescue candidates than capacity, requiring a choice of who travels now;
- route selection based on the animals aboard;
- vehicle selection where two unlocked vehicles are both valid but behave
  differently.

**Acceptance test:** A player can explain what they chose, what they gave up, and
why that mattered on the drive.

### 2. Add a proper result and replay screen

**Problem:** The game currently records stars and returns to level select without
clearly explaining the result, the improvement path, or the next reward.

- [ ] Add a result screen after each rescue.
- [ ] Show who arrived and who bailed.
- [ ] Explain the exact star result in plain language.
- [ ] Give one specific improvement hint based on the run, not a generic tutorial.
- [ ] Add clear **Retry for 3 stars** and **Continue** actions.
- [ ] Preview the next unlock or next mission's new problem.

Example result language:

> **2 stars — Everyone arrived, but Rabbit panicked on the final hill.**
> Ease off before sharp crests to keep Rabbit calm for all 3 stars.

Example continuation language:

> **Next: Heavy Rescue** — unlock the truck and move a load the jeep cannot carry
> comfortably.

**Acceptance test:** Without explanation, a player knows what happened, why they
received that rating, what to change, and why continuing may be interesting.

### 3. Build one genuine route decision — DONE (2026-07-18)

Level 3 is now "Which Road?" (wombat + timid rabbit). The prep brief offers two
routes; the pick feeds the drive via `GameState.loadout_route`.

- [x] Two clearly different valid routes:
  - **Rough shortcut:** 1450px, rough 1.0, no stops — greater comfort risk.
  - **Safe road:** 2400px, rough 0.6, early feeding stop (later a fuel cost once
    fuel returns).
- [x] Relevant traits shown alongside the choice — the manifest lists the rabbit
      as "timid" directly above the route buttons, and the brief calls it out.
- [x] Consequences perceptible in the drive (terrain shape, the food stop, a bail)
      and the result (stars + who arrived/rattled/bailed).
- [x] No hidden correct answer. Verified by driving the shipped data:
      | driving  | safe road      | rough shortcut     |
      | reckless | 2★ (10.1s)     | 1★, rabbit bails (6.4s) |
      | careful  | 3★ (21.4s)     | 2★ (12.8s)         |
      | expert   | 3★ (29.0s)     | 3★ (17.2s)         |
      Safe road guarantees delivery (2★ floor, never lose an animal); the shortcut
      risks the rabbit but is the FASTER path to 3★ for a skilled driver.

**Acceptance test:** met in principle — a timid rabbit makes the safe road the
sensible pick, without making the shortcut a trap. Wants a human playtest to
confirm players read the trade-off unaided.

CAVEAT — honest state: with fuel disabled, the shortcut's only scored edge is
that its 3★ is faster/shorter; the safe road has no scored *cost* yet, just its
length. The trade-off is real but completes when fuel returns (milestone 10) and
prices the long road. Do not over-tune around this now.

### 4. Give every animal one memorable gameplay identity — DONE (2026-07-18)

Each animal now carries a plain-language `personality` phrase in `Animals.DATA`
(surfaced via `Animals.personality(id)`). The prep brief leads each passenger row
with that phrase instead of a bare temperament word, so the player reads how to
treat the animal — not an invisible multiplier — before departing.

Target identities (as shipped in the brief):

- **Wombat:** "shrugs off the roughest ride" — forgiving, ideal for learning.
- **Rabbit:** "panics on bumps — drive it gently" — highly bump-sensitive.
- **Fox:** "a sly escape artist; handle with gloves" — handling + compatibility.
- **Tortoise:** "heavy but unflappable; needs a ramp" — sturdy, boards slowly.
- **Parrot:** "loud and dramatic when jostled" — lively, unsettles a nervous mate.
- **Goat:** "a stubborn wanderer; keep it leashed" — needs the leash capability.

- [x] Make each identity visible in mission text, expression, behaviour, or a
      concise trait badge — the brief row now leads with the trait phrase.
- [x] Avoid exposing raw sensitivity multipliers to the player — phrases only.
- [x] Remove or merge traits that players cannot remember or use when deciding —
      the bare temperament word is folded into the memorable phrase.
- [ ] Verify that a tester can describe at least three animals differently after a
      short session. (Needs the next human playtest.)

### 5. Rebuild the test campaign around five memorable missions — SUPERSEDED (2026-07-18)

Built the five-mission path, then — at owner request the same day — reintroduced
the full twelve-level campaign. The refined five stay as levels 1–5 unchanged;
levels 6–12 (new pairings, the trailer, multi-animal hauls, lifeline stops, the
grand convoy) are appended, each with a `hook`. `Levels.DATA` is the twelve-level
campaign again and `ARCHIVED_LEVELS` is removed. Star totals count all levels
(★ / 36). The distillation rationale below is kept for the record.

1. **First Rescue** — wombat, trike; teaches the loop (gentle, 3★ easy).
2. **Nervous Passenger** — timid rabbit, trike; reckless driving loses it (fail),
   careful delivers (3★). Makes the bail stake obvious.
3. **Which Road?** — wombat + rabbit, jeep; the safe-vs-rough route choice.
4. **Awkward Companions** — fox + rabbit, jeep; divided cage + gloves teach
   compatibility/handling (the brief now explains each item's purpose).
5. **Heavy Rescue** — tortoise + wombat, truck; size 5 won't fit the jeep (cap 4),
   so the truck earns its place. Sturdy load, rough 1.0: reckless 2★, careful 3★.

- [x] Each mission introduces only one major new idea.
- [x] Each mission has a distinct visual/terrain identity (length/rough/freq/phase).
- [x] Each mission ends with a reason to retry or continue — verified by driving:
      M2 reckless fails; M5 reckless 2★; the result screen names the fix.
- [x] Cut/park missions that just repeat a manifest with larger numbers (the
      original 12 are archived, not deleted).

Note: milestone 4 (memorable per-animal identities) is now addressed directly —
each brief row leads with the animal's personality phrase. Human playtest still
needed to confirm the arc reads unaided and testers can describe the animals.

### 6. Make vehicle progression solve visible problems

**Problem:** Vehicles are assigned by level, and the current stats do not make a
larger vehicle a visibly gentler or more appropriate ride.

Player-facing vehicle qualities should be limited and legible:

- **Capacity** — what it can carry.
- **Ride** — how strongly terrain jolts reach passengers.
- **Agility / route suitability** — where it can travel effectively.

- [ ] Add a meaningful ride/suspension quality that changes passenger comfort.
- [ ] Make the cargo trike bumpy but agile and suitable for light loads.
- [ ] Make the jeep flexible and average.
- [ ] Make the truck smoother and capable of heavy/fragile loads, but less agile
      or otherwise costly.
- [ ] Introduce vehicle selection only when at least two unlocked vehicles are
      valid and produce a genuine trade-off.
- [ ] Explain a new vehicle as a solution to a problem the player has already felt.

**Acceptance test:** A player says why they chose a vehicle in terms of the load
or route, not simply because it is the newest or biggest.

### 7. Make progression communicate curiosity — DONE (2026-07-18)

Each level now carries a one-line `hook` in `Levels.DATA`. The level-select grid
shows it under the padlock on locked missions (so the next mission teases its new
wrinkle instead of a bare "🔒 Locked"), and the result screen's "next" teaser
uses the same concise hook rather than dumping the full brief.

- [x] Replace bare locked-level presentation with teasers for the next new problem
      or character — locked buttons now read "🔒 <title> / <hook>".
- [x] Preview upcoming animals, routes, or vehicles without exposing every rule —
      hooks name the wrinkle (route choice, incompatible pair, the truck) only.
- [x] Make the next unlock concrete: what becomes possible, easier, or different?
- [x] Ensure a one-star completion can unlock progress, while the result screen
      makes replay for mastery attractive rather than compulsory — unlock needs
      one star; the result screen offers Retry for three stars alongside Continue.

The progression loop should read as:

> I survived this rescue → I understand how to improve it → the next rescue adds
> an interesting wrinkle.

### 8. Verify food and vet stops read as lifelines — DONE (2026-07-18)

Food and vet nodes restore per-animal comfort; the stops now read as felt
lifelines both in the moment and on the result screen.

- [x] Place a food or vet stop immediately after a deliberately rough stretch in
      the route-choice test mission — L3's rough shortcut now carries a food stop
      at 0.5. A driver who rushes the timid rabbit into panic can reach the feed
      in time to steady it, then ease off and still deliver it; flat-out driving
      still bails it first, careful play never needs it. Verified by sweeping
      careful / reactive / reckless play on the shipped route.
- [x] Strengthen the on-pass cue — passing a stop now perks the whole crew up for
      ~1.8s (delighted faces + a green "Phew!" shout) on top of the targeted
      message; the food crate / vet nurse / sanctuary building make each stop
      legible at a glance (see the visuals commit).
- [x] Make the result screen mention when a stop saved an animal from bailing —
      an animal a stop pulls back from the brink, if it then arrives, is credited
      ("🥕 A rest stop steadied X just before they bolted").
- [x] Remove or redesign any route stop that players pass without noticing or
      understanding — stops are now real scenery (veg crate, vet nurse tending an
      animal, sanctuary building), not bare signs.

### 9. Add scenery only where it improves readability or delight — DONE (2026-07-18)

Code-drawn scenery pass in main.gd (`_draw_sky`/`_draw_clouds`/`_draw_hills`/
`_draw_ground_props` + prop helpers). No art pipeline.

- [x] Reusable parallax set: sky gradient, drifting clouds, a second hill band
      behind the existing one, and deterministic roadside props (trees, bushes,
      rocks, grass tufts) rooted on the terrain and drawn in world scale.
- [~] Distinct visual identities: partly — the prop *mix* is driven by track
      roughness (lush→rocky), so gentle and rough routes read differently. Per-
      mission palettes/landmarks are still open if wanted.
- [x] Telegraph terrain/route character: prop mix tracks `track_rough`, so Level
      3's safe road (lush) vs rough shortcut (rockier) look different. Contrast is
      subtle in the active campaign (roughest active track is 1.0); more pronounced
      on the archived rough levels.
- [x] No large art pipeline — all shapes are code-drawn and deterministic.

Deliberately no birds (owner parked "birds flying through the sky" under
Explicitly not next). Verified by rendering a gentle vs a rough route.

### 10. Restore fuel only after route choice gives it a purpose

Fuel remains disabled behind `FUEL_ENABLED`.

- [ ] Keep fuel off while every route automatically passes the fuel stop.
- [ ] Restore fuel only when the player can knowingly choose a route, load, or
      vehicle that changes range risk.
- [ ] Ensure fuel and comfort create different decisions:
  - weight and distance affect fuel/range;
  - terrain and driving affect comfort.
- [ ] Remove fuel permanently if route and load decisions do not make it legible or
      fun in external play.

## Recommended implementation sprint

The next playable build should contain only:

1. [x] automatic handling of mandatory prep (auto-loaded brief);
2. [x] a clear result/replay/continue screen;
3. [x] one meaningful safe-versus-rough route choice (Level 3);
4. [x] one five-mission test path built around distinct situations;
5. [x] minimum supporting scenery — a code-drawn parallax/props pass so the close
   camera no longer shows a barren world (see milestone 9).

Then test with 3–5 unfamiliar players before expanding further. Use the results
to revise the build, then run the full 10-player Gate 5 test.

## Owner idea backlog — 2026-07-18 (park, do not build yet)

Captured mid-session while thinking; not scheduled. Several reinforce open
milestones (noted inline). Revisit after the 3–5 player test.

- **Vehicles must be readily identifiable.** They currently read as too similar.
  Distinct silhouette/colour per vehicle, the way the animals got distinct
  silhouettes. Directly serves milestone 6 (legible vehicle qualities) — a player
  can't reason "which vehicle for this load" if they can't tell them apart.
- **Replace the trike with a tuk-tuk.** More characterful and instantly readable
  as the small starter vehicle; helps the identifiability point above.
- **Show the player as the driver.** A simple, androgynous / gender-neutral human
  character in the cab. Adds life and a point of identification; pairs with the
  barren-landscape/juiciness work (milestone 9). NOTE: a reusable gender-neutral
  figure now exists — `_draw_person()` in main.gd, first used for the vet nurse —
  so drawing a driver in the cab can reuse it.
- **Terrain obstacles (e.g. rocks).** Hazards some vehicles must take with care —
  a felt difference in how each vehicle handles rough ground. Ties to milestone 6
  (a "ride/agility" difference between vehicles) and gives driving skill more to
  do than manage speed.
- **Obstacle animals (e.g. a rhino).** A hazard that tips a small/light vehicle
  over, letting the passengers escape — unharmed, but the level fails. A new,
  legible fail source tied to vehicle choice (a bigger/heavier vehicle resists
  it), reinforcing why the load wants the right vehicle. Keep the tone playful and
  the escape harmless, per the design rules.
- **Rename the home-screen title.** DONE (2026-07-18) — the game is now titled
  **Wildlife Rescue** (owner's choice). The codename and the "Driving Toy"
  shorthand are gone from every player-facing surface: the in-level banner
  (`main.tscn`), the level-select header (`level_select.gd`), and the window/app
  name (`project.godot`).

## Explicitly not next

Do not build these until the milestone above earns them:

- additional animals, vehicles, equipment, or levels;
- currency, shops, upgrade trees, or a large progression economy;
- procedural level generation;
- commercial artwork or a formal animation pipeline;
- native app-store release work;
- advertising, purchases, analytics, accounts, or notifications;
- water slosh simulation;
- free-roaming animal AI or manual capture actions;
- birds flying through the sky during the journey;
- multiplayer, social systems, or live events.
