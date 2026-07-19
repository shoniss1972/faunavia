# Faunavia Prototype TODO

## Product direction — current truth (2026-07-19)

Faunavia / **Wildlife Rescue** is a functioning mobile-first vertical slice. The
next phase is an **approved campaign expansion**: a longer, more international game
whose animals feel like characters rather than cargo.

> **Choose a sensible rescue plan, then drive well enough that every opinionated
> animal stays aboard.**

Every addition must strengthen at least one of:

1. **Plan** — make a real choice before or during the rescue.
2. **Drive** — read terrain and control the vehicle with intent.
3. **Animals** — understand, remember and care about distinct passengers.
4. **Reward** — know what happened, why it mattered and what comes next.
5. **World** — make each rescue feel like a place and a small story.

No meter, stop, item, screen, trait or animation without a visible player-facing
job. Expansion is approved, but “more” is not enough: each animal and mission must
add a genuinely different wrinkle.

---

## Current prototype state

Implemented on `main`:

- 12 long missions with terrain variation inside each level and route stops that
  scale with distance.
- Tuk-tuk, jeep and truck with distinct silhouettes and ride quality, plus a trailer
  and visible player driver.
- Six animal species with size, weight, temperament, equipment requirements,
  compatibility rules, distinctive sprites and three moods.
- Per-animal comfort; rough driving can make an individual animal bail harmlessly,
  costing delivery credit and stars.
- Fuel affected by distance, load and speed, with visible pumps and dashboard dials.
- Food and vet stops that visibly restore the crew.
- Rocks that visibly jolt or launch the rig when hit too fast.
- Auto-loaded briefs, route choice where relevant, results/retry/continue, stars,
  sequential unlocks and saved progress.
- Per-animal calls, ambient chatter and mouth movement, vehicle audio, music and
  route/result cues.
- Portrait touch/keyboard controls and HTML5 export.

### Current roster

- **Wombat:** shrugs off the roughest ride.
- **Rabbit:** panics on bumps — drive it gently.
- **Fox:** sly escape artist; needs gloves and separation from Rabbit.
- **Tortoise:** heavy but unflappable; needs a ramp.
- **Parrot:** loud and dramatic; unsettles nervous companions.
- **Goat:** stubborn wanderer; must be leashed.

### Current design concern

The roster is geographically unbalanced and the gameplay vocabulary still clusters
around bump tolerance, mandatory equipment and incompatibility. Levels 8–12 also
trend toward larger remixes of existing loads. The expansion must introduce new
ways to drive, new passenger relationships and missions with a beginning, middle
and end — not simply longer roads and bigger manifests.

---

## Work already in progress: longer game

Claude is extending level length and expanding the campaign from 12 to approximately
24 missions.

- [ ] Confirm the final target is 24 missions and update stars, unlocks, level-select
      layout and save migration.
- [ ] Ensure increased length creates acts within a mission rather than empty travel.
- [ ] Give every expanded mission a midpoint change: pickup, route branch, terrain or
      weather shift, passenger interaction, optional rescue or vehicle consequence.
- [ ] Keep fuel/food/vet spacing appropriate to actual route distance.
- [ ] Prevent terrain, rock and landmark patterns from visibly repeating.
- [ ] Re-run careful / moderate / reckless validation across all missions and routes.
- [ ] Require every mission to have a one-sentence identity beyond “longer” or “more
      animals.”

**Acceptance test:** a player can describe what was different about each of the last
three missions played.

### External phone validation remains mandatory

- [ ] Verify touch, audio unlock, mute, icons and performance on iPhone and Android.
- [ ] Run a 3–5 person unfamiliar-player test on the expanded build.
- [ ] Observe without explaining controls, traits, scoring or progression.
- [ ] Record completion, retries, confusion, smiles, remembered animals and requests
      to continue.
- [ ] Revise, then run the full 10-player Gate 5 test.

A successful tester can explain why an animal became upset, identify what to change
for another star, distinguish animals by personality and voluntarily retry or
continue.

---

# Approved expansion: international animal campaign

## Expansion goal

Add **six animals from different regions**, taking the roster from six to 12 and the
campaign from 12 to about 24 missions.

The expansion must:

- include a distinctive **New Zealand kiwi**;
- make the cast visibly international;
- give every new animal a different driving or planning rule;
- introduce each animal in one focused mission, then use it in a second interaction
  mission;
- give each two-level chapter recognisable environmental graphics;
- create a collection reward through a **Sanctuary Book**, without currency, shops
  or an upgrade economy.

### Australia balance decision

- Keep Wombat as the current Australian representative.
- **Park Kangaroo.** It would reinforce the Australia-heavy roster and risks
  duplicating jumping/bump mechanics.
- Reconsider it only after the international six are working and tested.

---

## New animal roster

### 1. Kiwi — New Zealand flagship

**Personality:** “A suspicious night owl — no sudden starts, stops or noisy
neighbours.”

**Rule:** comfort reacts to abrupt acceleration and braking rather than ordinary
bumps. Kiwi is strongly disturbed by Parrot unless separated.

- [ ] Add smooth-input comfort logic and clear live feedback.
- [ ] Consider a capacity-costing covered carrier only if it creates two valid plans.
- [ ] Art: long-beak silhouette; suspicious side-eye; peck idle; puffed annoyed pose;
      happy peck; accusatory walk-off bail.
- [ ] Boarding gag: refuses twice, then boards as though it was its own idea.

### 2. Capybara — South America

**Personality:** “Heavy, hungry and impossible to rattle — everyone calms down
beside it.”

**Rule:** increases weight/fuel use but reduces comfort loss for one nervous neighbour.
It is a beneficial passenger, not another liability.

- [ ] Add a limited calming/adjacency effect that assists but does not grant immunity.
- [ ] Art: chewing idle, slow blink, relaxed expressions and comic indifference.
- [ ] Relationship: Rabbit gradually copies Capybara’s calm posture.

### 3. Meerkat — Southern Africa

**Personality:** “A tiny back-seat driver that spots trouble before you do.”

**Rule:** points out approaching rocks, ridges or rough sections. Slowing in response
delights it; repeatedly ignoring warnings annoys it.

- [ ] Add sparse, useful advance warnings without another meter.
- [ ] Art: upright scan, frantic point, proud salute and chatter.
- [ ] Relationship: warns everyone while Wombat sleeps through it.

### 4. Red Panda — Himalayan Asia

**Personality:** “Adorable until the speed climbs — then it clings on for dear life.”

**Rule:** tolerates uneven ground at moderate speed but panics above a sustained speed
threshold, distinct from Rabbit’s bump sensitivity.

- [ ] Add readable sustained-speed comfort logic without forcing a crawl.
- [ ] Art: grooming idle, rail-cling, flattened ears and relieved release.
- [ ] Pair with Wombat to make their opposite reactions obvious and funny.

### 5. Raccoon — North America

**Personality:** “A shameless snack thief with busy paws and no regrets.”

**Rule:** changes food stops. It steals an outsized share unless supplies are secured
or deliberately allocated.

- [ ] Prototype one simple choice: secure supplies before departure or decide which
      passenger gets a limited food boost.
- [ ] Do not add an inventory-management system.
- [ ] Art: rummaging idle, guilty freeze and conspicuous delighted munching.
- [ ] Relationship: tries to steal Goat’s feed; Goat blocks the lid.

### 6. Flamingo — Caribbean / Africa

**Personality:** “Elegant, vain and catastrophically top-heavy.”

**Rule:** sensitive to tilt, airtime and hard landings rather than normal cruising.
May require an open/tall vehicle, but only add gear if there are multiple valid plans.

- [ ] Add tilt/airtime/landing comfort input.
- [ ] Make rocks and sharp crests its primary threat.
- [ ] Art: tall silhouette, poised idle, neck wobble, ruffled feathers and restored
      one-legged elegance.
- [ ] Ensure it does not obscure the rest of the crew at phone size.

---

## Mandatory personality contract

An animal is not complete when it merely has a colour and sensitivity multiplier.
Every existing and future animal must ship with:

1. One gameplay sentence a player can remember.
2. One unmistakable phone-size silhouette.
3. Content, annoyed and delighted portraits.
4. One idle tic.
5. One short boarding gag.
6. One unique response tied to its actual gameplay rule.
7. One happy behaviour, not merely a happy face.
8. One harmless bail/refusal action.
9. One recognisable, gain-balanced voice/call.
10. At least one relationship with another species.

### Existing-animal enhancement pass

- [ ] Wombat slumps or sleeps during a smooth ride.
- [ ] Rabbit ears become a visible early comfort signal.
- [ ] Fox watches and tests the latch.
- [ ] Tortoise retracts after a hard hit, then slowly emerges.
- [ ] Parrot rarely imitates vehicle or animal sounds.
- [ ] Goat braces its horns and stubbornly faces the wrong way.

**Acceptance test:** after a short session, a tester can describe at least six
animals differently without rereading the briefs.

---

## Additional animal graphics and animation

### Required assets per new animal

- [ ] Content, annoyed and delighted portraits.
- [ ] Dedicated mouth-open/talking frame or reusable mouth overlay, so an annoyed
      animal does not briefly look delighted while speaking.
- [ ] One signature-action frame/overlay: Kiwi peck, Capybara chew, Meerkat point,
      Red Panda cling, Raccoon rummage, Flamingo wobble.
- [ ] Bail/refusal frame where the base portrait cannot sell the gag.
- [ ] Matching small portrait/icon for briefs and Sanctuary Book.

### Art and implementation rules

- [ ] Preserve the friendly storybook mobile-mascot style.
- [ ] Prioritise silhouette over texture or realism.
- [ ] Keep framing, eyeline, lighting and scale consistent across moods.
- [ ] Validate every asset at actual in-vehicle phone size.
- [ ] Update `docs/ART_BRIEF.md` for the six new species and action frames.
- [ ] Add an asset-completeness check for every animal ID.
- [ ] Add per-passenger idle/action timers independent of mood and talking.
- [ ] Prevent several large passenger actions firing simultaneously.
- [ ] Keep animation lightweight for mobile web.

---

## Regional chapter graphics

Each animal pair gets a recognisable palette, landmark and prop set. Use the current
code-drawn scenery system first; do not jump to a large background-art pipeline.

- [ ] **Kiwi / New Zealand:** dawn or twilight native bush, ferns, wet road sheen,
      low mist, conservation signs and sanctuary hut.
- [ ] **Capybara / wetlands:** reeds, lagoons, broad-leaf plants, muddy banks and
      distant waterbirds.
- [ ] **Meerkat / dry scrub:** grasses, termite mounds, acacias, warm rocks and long
      horizons.
- [ ] **Red Panda / mountain forest:** mist, pines/rhododendron, ridges and restrained
      colour accents; avoid sacred imagery as generic decoration.
- [ ] **Raccoon / woodland:** campsites, bins, picnic tables, cabins and evening woods.
- [ ] **Flamingo / salt flats:** lagoons, pale flats, coastal wind, grasses and distant
      flocks.

For every chapter:

- [ ] Add at least one large memorable landmark.
- [ ] Use scenery to telegraph terrain/events, not only decorate.
- [ ] Vary foreground and background so long routes do not look tiled.
- [ ] Add chapter-specific arrival dressing while retaining a shared sanctuary identity.
- [ ] Keep cultural references broad, respectful and non-stereotyped.

---

## Longer-level structure

Simply doubling distance is not enough. Every expanded level must change state.

### Mid-route pickups

- [ ] Add rescue points where the vehicle stops and an animal boards midway.
- [ ] Let selected missions begin with one passenger and add another after the first
      route act.
- [ ] Make added weight, compatibility, fuel use and relationships immediately visible.
- [ ] Support occasional optional detour pickups for a bonus star or alternate result.
- [ ] Keep pickups short and characterful; do not add manual capture gameplay.
- [ ] Update results to credit optional rescues and explain missed ones.

Other valid midpoint changes include a real route branch, weather/visibility change,
rough-terrain phase, consequential stop, trailer/load change, relationship event or
vehicle-choice consequence.

**Acceptance test:** no expanded mission is the same handling problem for twice as
long.

---

## Proposed levels 13–24

Exact numbering can change for difficulty, but keep the two-level character arcs.

13. **Night Shift — Kiwi:** smooth starts/stops on a damp NZ bush road.
14. **Keep It Down — Kiwi + Parrot:** relationship-led quiet/chaos route problem.
15. **Calm Company — Capybara:** heavy, fuel-hungry and serenely unbothered.
16. **Borrowed Nerves — Capybara + Rabbit:** comfort benefit versus range cost.
17. **Look Out! — Meerkat:** learn that pointing predicts real obstacles.
18. **Back-seat Driver — Meerkat + trailer crew:** warnings matter with a slow rig.
19. **Not So Fast — Red Panda:** sustained-speed control on a mountain road.
20. **One of Us Is Fine — Red Panda + Wombat:** opposite reactions to one journey.
21. **Hands Off the Snacks — Raccoon:** food-stop choice and visible mischief.
22. **Picnic Trouble — Raccoon + Goat/Rabbit:** another passenger needs the food.
23. **High Maintenance — Flamingo:** avoid tilt, airtime and hard landings.
24. **International Rescue — finale:** choose a compatible crew from more candidates
    than capacity; include multiple valid plans, a multi-act route and an optional
    rescue. Do not repeat Level 12’s “carry everyone” structure.

---

## Sanctuary Book

The Sanctuary Book is the collection and character-progression layer. It should make
unlocking animals rewarding without shops, chores or an economy.

### Core feature

- [ ] Add a Sanctuary Book button from home/level select.
- [ ] Show one card/page per species, initially silhouetted or partly hidden.
- [ ] Unlock the full entry on first successful delivery.
- [ ] Show portrait, name, broad region, personality/rule, favourite companion, pet
      hate/incompatibility, required gear, best mission result, delivery count and
      tap-to-hear call.
- [ ] Add a small signature idle/action on the selected page where feasible.
- [ ] Preview the next locked animal without revealing its full rule.
- [ ] Show a simple completion count such as `8 / 12 animals settled`.

### Reward integration

- [ ] Result screen links to a newly unlocked/updated book entry.
- [ ] Three stars may unlock a non-mechanical flourish: alternate quote, sticker,
      pose or page badge.
- [ ] Completing both missions for an animal unlocks its relationship note or special
      animation.
- [ ] Completing all 12 animals unlocks a finale page/celebration.
- [ ] Add a lightly populated sanctuary background using existing sprites; this is
      presentation, not free-roaming AI or sanctuary management.

**Acceptance test:** a tester voluntarily opens the book, taps calls and names an
animal they want to unlock next.

---

## Animal relationships and micro-events

- [ ] Add a data-driven relationship table: calms, annoys, competes, copies, warns,
      ignores.
- [ ] Trigger short micro-events only when relevant passengers are together.
- [ ] Prevent overlaps and avoid constant chatter.
- [ ] Use results text only when a relationship materially affected the outcome.
- [ ] Target moments include Kiwi glaring at Parrot, Capybara calming Rabbit, Meerkat
      warning sleeping Wombat, Raccoon reaching for Goat’s feed and Flamingo blocking
      Fox’s view.

---

## Audio expansion

- [ ] Add a distinct call for each new animal and normalise per-animal gain.
- [ ] Add one signature happy/annoyed variation where useful.
- [ ] Add light chapter ambience without masking engine, fuel and comfort cues.
- [ ] Preserve the one-voice-at-a-time rule or deliberately duck other audio.
- [ ] Test all audio on iOS Safari with first-gesture unlock and silent-mode handling.

---

## Data and architecture

- [ ] Give `Animals.DATA` behaviour IDs/fields; avoid species-name conditionals spread
      through `main.gd`.
- [ ] Separate comfort inputs where required: terrain jolt, sustained speed,
      acceleration/braking spike, tilt/airtime and social noise.
- [ ] Add safe positive effects such as Capybara calming without stacking exploits.
- [ ] Add relationship, chapter and pickup/event data to levels.
- [ ] Make prep, HUD, results and Sanctuary Book read the same personality data.
- [ ] Migrate saves safely to 24 levels, 12 animals and book unlocks.
- [ ] Validate missing sprites, voices, behaviour handlers, props and references.
- [ ] Keep player-facing text descriptive; never expose raw sensitivity multipliers.

---

## Implementation order

### Phase A — long-route foundation

1. [ ] Complete length/terrain work underway.
2. [ ] Expand level-select/save/star systems to 24 safely.
3. [ ] Add generic midpoint pickup/event support.
4. [ ] Validate fuel, comfort and stop spacing.

### Phase B — one complete expansion slice

5. [ ] Build Kiwi mechanics, full graphics and call.
6. [ ] Build NZ chapter palette/props.
7. [ ] Build Levels 13–14 and Kiwi + Parrot interaction.
8. [ ] Add first Sanctuary Book version with the existing six plus Kiwi.
9. [ ] Phone-test before producing the remaining five art sets.

### Phase C — remaining animal pairs

10. [ ] Capybara + Levels 15–16.
11. [ ] Meerkat + Levels 17–18.
12. [ ] Red Panda + Levels 19–20.
13. [ ] Raccoon + Levels 21–22.
14. [ ] Flamingo + Levels 23–24.
15. [ ] Build each chapter’s graphics, landmark, action and audio alongside its
       mechanics; do not batch all art before gameplay is proven.

### Phase D — cohesion and validation

16. [ ] Existing-six personality animation pass.
17. [ ] Relationship micro-events across old and new animals.
18. [ ] Complete Sanctuary Book rewards/populated presentation.
19. [ ] Rebalance difficulty, stars, mission order and unlock teasers.
20. [ ] Full 24-level automated validation and real-device regression.
21. [ ] 3–5 player revision test, then 10-player Gate 5 test.

---

## Expansion success criteria

- Every new animal changes how the player drives, plans or reads the route.
- Kiwi feels like a flagship character, not a regional checkbox.
- Players remember animals by behaviour and personality.
- Long missions contain changing situations rather than padded distance.
- Regional graphics make chapters recognisable at a glance.
- Sanctuary Book creates curiosity and affection without chores.
- Level 24 asks for judgement and crew selection, not maximum capacity.
- Performance and readability remain strong on real phones.

---

## Explicitly not part of this expansion

- Currency, shops, loot, consumable economies or upgrade trees.
- Daily tasks, timers, feeding chores or sanctuary-management simulation.
- Procedural levels, free-roaming animal AI or manual capture.
- Injury, suffering, predation or death; failure remains humorous and harmless.
- Multiplayer, social systems, live events, ads, purchases or accounts.
- Native app-store work until the expanded prototype is proven.
- A large skeletal-animation or commercial-art pipeline before lightweight action
  frames are validated.
- Kangaroo until the international roster is tested.

---

## Standing design rules

- Never ask the player to click the only correct answer.
- Prefer one memorable rule per animal over many numerical differences.
- Every mission introduces, combines or tests a distinct idea.
- Every long level changes state at least once.
- Every vehicle, item or stop solves a problem the player has felt.
- Consequences stay playful: annoyance, refusal, bailing, lost stars and missed
  opportunities — never visible harm.
- Build one animal/chapter pair completely before scaling the art pipeline.
- Test unfamiliar players before assuming designer intent is legible.
