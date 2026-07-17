# Playtest Notes

Use one section per test session. Record behaviour rather than trying to defend or explain the game.

## Session template

### Build / date

- Build or commit:
- Date:
- Device:
- Tester familiarity with mobile games:

### Observation

- Did the tester understand the objective without explanation?
- What was the first point of confusion?
- Did the controls behave as expected?
- Which animal reaction was noticed or understood?
- Did preparation feel like a puzzle or administration?
- Did the tester retry after failure or a low score?
- Did the tester ask to unlock another vehicle or play another level?
- Where did attention or enjoyment drop?

### Evidence

- Levels attempted:
- Levels completed:
- Voluntary retries:
- Session duration:
- Direct quotes:

### Decision

- Keep:
- Change:
- Remove:
- New idea to park, not build yet:

---

## Gate 2 internal playthroughs — 2026-07-15

- Build / commit: Gate 2 slice (weight, comfort moods, loading gag) on `main`.
- Device: macOS, Godot 4.7.1, 360x640 portrait.
- Tester: automated internal harness driving five fixed strategies. Not a human
  playtest — that is Gate 5. Purpose: confirm the passenger loop produces a
  readable, varied comfort response before showing anyone.

Passenger: Wombat, mass 0.5. Metrics are % of the run spent in each mood.

| # | Strategy | Finish | Time | Fuel end | Min comfort | Content | Annoyed | Delighted |
|---|----------|--------|------|----------|-------------|---------|---------|-----------|
| 1 | Hold DRIVE (flat out)        | yes | 8.6s  | 55% | 0  | 27% | 44% | 29% |
| 2 | Ease off on jolts            | yes | 9.4s  | 83% | 0  | 27% | 45% | 29% |
| 3 | Burst (0.8s on / 0.6s off)   | yes | 10.0s | 75% | 0  | 33% | 39% | 28% |
| 4 | Crawl (keep speed under 120) | yes | 16.7s | 75% | 61 | 47% | 0%  | 53% |
| 5 | Brake above 150              | yes | 8.6s  | 55% | 0  | 27% | 44% | 29% |

### Observation

- All three reactions occur naturally. Content, annoyed, and delighted each
  showed up within a single run at speed, and the emotes ("Oof!", "Wheee!")
  and face changes read clearly at portrait size.
- The intended tradeoff is present and legible: driving gently (crawl) removed
  annoyance entirely and maximised delight; charging full-speed produced an
  exciting but jostling ride that swung through all three moods.
- Dominant comfort lever is sustained speed, not moment-to-moment input.
  Easing off on jolts (2) and braking on peaks (5) barely changed the mood mix
  versus holding full throttle (1). The animal reacts to how fast you take the
  rough ground, more than to fine throttle control.
- Fuel is not yet a real constraint: even flat-out finished with 55% left
  (62% start + 55% pickup). No run came close to stranding.
- Loading gag works: the run holds at speed 0 until the wombat clambers in with
  its grumble lines, then driving unlocks.

### Decision

- Keep: passenger + weight + comfort moods + loading gag. The expressive animal
  does add a readable speed-vs-comfort tension, so Gate 2's question reads as a
  tentative yes — pending a real human playtest at Gate 5.
- Change (tuning, done this session): first comfort tuning pinned comfort to 0
  at any real speed (annoyed 50-58% everywhere, delighted unreachable). Retuned
  jolt threshold 42→58, loss 0.85→0.7, recovery 15→18, delight gate 85→80 to
  open the gradient above.
- Change (future): let easing/braking matter more, so careful driving is
  rewarded moment-to-moment, not just via average speed.
- Remove: nothing.
- Park, not build yet: fuel as a genuine constraint (lower start / raise drain);
  per-section terrain roughness; a sound or shake on hard jolts.

---

## Polish pass (Gates 1-3) — 2026-07-15

Not a new playtest; addressed findings and parked items recorded above.

- Fuel is now a real constraint (closes the "fuel finished with 55% to spare"
  finding). Replaced per-second drain with a distance × weight range model so
  the two tensions stay orthogonal and intuitive: speed jostles the animals
  (comfort), weight drinks fuel (range). Measured via harness: a light load
  finishes with ~28% margin; a full three-animal load reaches the mid-route
  pickup on ~9% and finishes on ~7%, so the pickup is essential and a heavy
  load that misses it strands. This ties the Gate 3 loadout choice directly to
  the Gate 1 driving risk.
- Prep screen made less form-like: colour swatches matching each animal's cab
  colour, cargo shown as slots + kg, and a hint that heavier cargo needs the
  pickup — surfacing the loadout/fuel link before departure.
- Driving HUD: fuel readout warns amber under 30% and red under 15%.

Still parked: reward moment-to-moment easing/braking in comfort; per-section
terrain roughness; jolt sound/shake. These want a human playtest (Gate 5) to
justify before building.

---

## Gate 5 — first external test (itch.io web build) — 2026-07-16

First real human playtest, on an itch.io HTML5 build. This is the honest check
several automated "validations" could not give — and it pushed back hard.

### Observation (tester feedback)

- Got bored: levels are very short and the drive is exactly the same every time.
  (The track — terrain shape and length — is identical across all 12 levels;
  only the prep loadout changes.)
- Fuel doesn't read as a mechanic: it starts at a part tank, never runs out, and
  the fuel stop sits on the only road so it can't be skipped — so its purpose is
  unclear. (Our 24-33% margins mean the player never actually strands.)
- The animals all look the same — only fur colour differs; the head shape is
  identical, so they don't register as different creatures.
- Driving style "doesn't seem to make any difference to anything." The whole
  comfort/mood premise (Gate 2) is not landing in the moment for a real player,
  even though the star system rewards it after the fact.
- Bug: the finish sign reads "Sanctua" — "SANCTUARY" is truncated by the marker
  width.

### Decision

- Keep: the prep/logistics puzzle and progression scaffolding seem fine; the
  complaints are about the DRIVE being same-y and its stakes being invisible.
- Change (triage):
  1. Sanctua truncation — trivial marker-width fix. [done]
  2. Animals look the same — give each a distinct silhouette (ears, shell, beak,
     horns), not just colour.
  3. Fuel STAYS (owner decision). It reads as pointless today because the fuel
     stop sits on the only road and can't be missed. The intended fix is
     branching routes: a shortcut/alternate path that skips the fuel stop, so
     taking it becomes a real fuel gamble. Flagged as a major revision — the
     target for fuel depth, not built yet. Per-track variety below is the first
     step toward it. TEMPORARILY DISABLED behind `FUEL_ENABLED` in main.gd while
     other issues are fixed — flip it back to true to restore the whole mechanic.
  4. Driving doesn't matter — make comfort consequential and legible in the
     moment (live mood read, real stakes), not just a post-hoc star. Still open.
  5. Levels short and identical — vary the track per level (length, hills,
     roughness). Owner priority. Biggest boredom lever; also gives driving skill
     and fuel real teeth. BUILDING NOW, alongside distinct animal silhouettes.
- Remove: nothing.

---

## Gate 5 — owner replay after art + camera pass — 2026-07-18

Owner played several times after the animal sprites, the 2x zoom camera, and the
crew-seating fixes landed. The art complaint (#2) is closed — the animals read as
distinct creatures and the expressions are liked. What surfaced next is deeper
and more coherent than the first round.

### Observation (owner)

- Prep screen has no purpose. You must click every animal and item aboard to
  advance, but there is no decision in it and it is not fun — it is a checklist
  gate, not a puzzle.
- Food and vet route signs seem meaningless. You pass them and nothing you can
  perceive happens.
- Landscape is barren — now that the camera is close, the empty world shows.
  Wants environmental features.
- Vehicle progression (bicycle → jeep → truck) does not make sense or relate to
  the animal load. Getting the next vehicle is not motivated by a pressure the
  load creates.
- Expressions are cool, but there is no penalty for rough driving that makes the
  animals "oof" — the reaction has no consequence.

### Reading — one root cause under four of the five

Every observation except the barren landscape is the same disease: **a system
exists but has no stake.** Comfort is the hub they all hang off, and comfort
currently costs the player nothing.

- Rough driving drains comfort → but draining comfort does nothing, so the "oof"
  is decoration. (The direct complaint.)
- Food/vet signs restore or repair comfort → but you cannot feel a restore of a
  thing that has no stake, so they read as meaningless.
- Prep is assembling a loadout → but no loadout choice trades off against a
  pressure you feel on the drive, so it is a checklist, not a decision.
- Vehicle progression → not tied to the load, because the load's only felt cost
  (jostling fragile animals) has no consequence to design a smoother ride
  against.

So there is ONE keystone: **give comfort a real, in-the-moment stake.** Make
rough driving cost something the player sees accrue or lose live — a payout that
drains, a patience meter that can end the run, an animal that bails at zero.
Doing that lights up four observations at once: the oof gets teeth (#5), the
food/vet signs become a lifeline worth reaching (#2 signs), prep becomes a real
decision — which animals tolerate this route, is it worth the calming feed (#1),
and vehicle choice gains meaning as smoother carriage for a fragile load (#4).

This also REVISES the first round's "keep prep as-is" call: real play says prep
is administrative, exactly the Gate 3 question ("fun, not administrative?")
answered honestly. Prep is not wrong — it is unmotivated, and the same keystone
motivates it.

The barren landscape (#3) is the one separate item: pure juiciness/scenery, not
a stakes problem. Cheap to improve, independent of the above.

### Decision

- Next keystone: comfort stakes (see TODO). Everything else is downstream of it —
  resist polishing prep, signs, or vehicles until the drive has a consequence to
  hang them on.
- Landscape features: parked as independent polish; do after or alongside, not
  instead.
- Remove: nothing yet — but if the keystone does not rescue prep, cutting the
  click-aboard step to an auto-load is on the table.

### Keystone form — DECIDED 2026-07-18

The stake for rough driving: **an animal bails at zero comfort.** Chosen over a
soft draining reward and over a hard run-fail. It is the most legible answer to
"driving doesn't matter" — the animal acts on its feelings by leaving — and it
turns the expressions already built into the warning system (annoyed face is the
telegraph, zero is the bail).

Resolution when you arrive short — **soft:** the animal leaps off and trots back
down the road, the run continues, you still complete the level, but that animal
scores nothing. Losing its stars usually drops you under the next unlock, so the
sting is real and may prompt a replay, but there is no hard RUN FAILED wall. This
keeps the cozy tone.

This pulls per-animal comfort in as a PREREQUISITE, not a separate task: one
shared comfort value cannot support "an animal bails" (all would leave at once).
So the reaction-variance item and the bail stake are one build — comfort per
animal keyed to temperament (timid rabbit frets and bails long before the placid
wombat is bothered), with the bail firing when any single animal reaches zero.

Knock-on wins this unlocks, to verify after: food/vet signs become a lifeline
(reach one to pull an animal back from the brink), and prep becomes a real
decision (which animals tolerate this route, is the calming feed worth a slot).
