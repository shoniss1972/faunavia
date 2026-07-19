# New Animal — Voice Brief for ElevenLabs (reusable scaffold)

One short call per animal. The game auto-discovers `res://audio/voice_<id>.wav`
(`audio.gd`) and plays it on load-in, on a bail, and as one-at-a-time ambient
chatter — **no code change needed** beyond dropping the file in.

---

## 1. Fill this in per animal

| Field | Value |
|---|---|
| **Animal id** (must match `Animals.DATA`) | `________` |
| **Temperament / personality** | ________ |
| **Real-world sound to base it on** | ________ |
| **Comedy angle** (how the call plays it up) | ________ |

### Worked example (kiwi)

| Field | Value |
|---|---|
| Animal id | `kiwi` |
| Temperament | wary — hates sudden stops, frets near the parrot |
| Real-world sound | shrill rising whistle (male kiwi call) |
| Comedy angle | a startled little "who, me?" whistle, more nervous than shrill |

## 2. Prompt template (fill brackets, paste into ElevenLabs Sound Effects)

> Cute storybook cartoon animal voice, warm and comedic, never distressed or
> harsh. A single short [REAL-WORLD SOUND] from a [ANIMAL + PERSONALITY
> description], played as [COMEDY ANGLE]. One call only, clean, close-mic'd,
> minimal reverb.

- **Duration setting:** 0.4–0.6 s.
- Generate **4 variants**, audition, keep the best.
- The call plays repeatedly during a run (ambient chatter) — before accepting,
  loop your pick ~10 times; anything faintly grating gets worse in-game.
- It also plays on a **bail**, so it must not sound hurt or frightened —
  indignant, startled, or dramatic reads fine; distress does not.

## 3. Delivery specs

- **Format:** WAV (PCM 16-bit) preferred; MP3 acceptable, re-exported via
  Audacity.
- **Channels / rate:** mono, 44.1 kHz.
- **Level:** normalize peak to about **−4 dBFS** (match the existing voices; if
  it still sits loud/quiet in-game, add a per-animal dB trim in `VOICE_GAIN` in
  `src/audio.gd` rather than re-exporting).
- **Trim:** cut leading silence so it fires tight on the event.
- **Filename:** exactly `voice_<id>.wav` → `res://audio/` (e.g.
  `audio/voice_kiwi.wav`).
- **Import first, then export.** After dropping the WAV in, open the project in the
  Godot editor once so it generates the `.wav.import` file *before* you web-export.
  A headless export of a file the editor has never imported ships silently without
  it (no call plays) — same gotcha as the sprite PNGs.

## 4. Acceptance checklist

- [ ] Instantly tells this animal apart from the other voices with eyes closed
- [ ] Personality audible (timid / stubborn / dramatic…), matching the sprite
- [ ] Survives 10 repeats without grating
- [ ] No distress reading when heard at the moment of a bail
- [ ] Mono, tight start, level sits with the existing voice pack
