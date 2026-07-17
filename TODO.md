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
- [ ] Make the next mission and vehicle desirable rather than merely unlocked.
- [ ] Show the player what new problem, character, route, or capability is coming.

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

### 4. Give every animal one memorable gameplay identity

Animals already differ in data. The next task is to make players anticipate them
as characters rather than learn invisible multipliers.

Target identities:

- **Wombat:** forgiving, placid, ideal for learning.
- **Rabbit:** highly sensitive to bumps; panics early.
- **Fox:** manageable alone but creates handling and compatibility problems.
- **Tortoise:** very heavy but emotionally unflappable.
- **Parrot:** dramatic and lively; can unsettle a nervous companion.
- **Goat:** stubborn, heavy, and difficult to handle without the right capability.

- [ ] Make each identity visible in mission text, expression, behaviour, or a
      concise trait badge.
- [ ] Avoid exposing raw sensitivity multipliers to the player.
- [ ] Remove or merge traits that players cannot remember or use when deciding.
- [ ] Verify that a tester can describe at least three animals differently after a
      short session.

### 5. Rebuild the test campaign around five memorable missions

Keep the twelve existing levels available for development, but do not use level
count as evidence that the prototype works. Create a five-mission test path where
each mission has a distinct question.

Suggested test sequence:

1. **First Rescue** — Wombat teaches drive, comfort, and arrival.
2. **Nervous Passenger** — Rabbit makes the rough-driving consequence obvious.
3. **Which Road?** — safe detour versus rough shortcut.
4. **Unhappy Travelling Companions** — a real compatibility/separation choice.
5. **Heavy Rescue** — the load creates a visible reason for a different vehicle.

- [ ] Each mission introduces only one major new idea.
- [ ] Each mission has a distinct visual/terrain identity.
- [ ] Each mission ends with a clear reason to retry or continue.
- [ ] Cut, merge, or park missions that merely repeat a manifest with larger
      numbers.

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

### 7. Make progression communicate curiosity

- [ ] Replace bare locked-level presentation with teasers for the next new problem
      or character.
- [ ] Preview upcoming animals, routes, or vehicles without exposing every rule.
- [ ] Make the next unlock concrete: what becomes possible, easier, or different?
- [ ] Ensure a one-star completion can unlock progress, while the result screen
      makes replay for mastery attractive rather than compulsory.

The progression loop should read as:

> I survived this rescue → I understand how to improve it → the next rescue adds
> an interesting wrinkle.

### 8. Verify food and vet stops read as lifelines

Food and vet nodes now restore per-animal comfort, but the mechanic still needs a
real-play read.

- [ ] Place a food or vet stop immediately after a deliberately rough stretch in
      the route-choice test mission.
- [ ] Strengthen the on-pass cue: expression change, short animation, sound, or
      clearly targeted message.
- [ ] Make the result screen mention when a stop saved an animal from bailing.
- [ ] Remove or redesign any route stop that players pass without noticing or
      understanding.

### 9. Add scenery only where it improves readability or delight

The close camera exposes the barren world. Add environmental character, but do
not let scenery displace the gameplay work above.

- [ ] Add a small reusable set of parallax features, foreground props, and roadside
      details.
- [ ] Give the five test missions distinct visual identities.
- [ ] Use scenery to telegraph terrain and route character where possible.
- [ ] Avoid a large art pipeline until the core test succeeds.

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

1. automatic handling of mandatory prep;
2. a clear result/replay/continue screen;
3. one meaningful safe-versus-rough route choice;
4. one five-mission test path built around distinct situations;
5. only the minimum supporting UI and scenery needed to test those changes.

Then test with 3–5 unfamiliar players before expanding further. Use the results
to revise the build, then run the full 10-player Gate 5 test.

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
- multiplayer, social systems, or live events.
