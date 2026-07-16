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
