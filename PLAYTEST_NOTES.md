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
