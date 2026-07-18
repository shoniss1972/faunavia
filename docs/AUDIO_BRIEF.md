# Wildlife Rescue — Audio Brief

Prompts and specs for replacing the placeholder **procedural** sounds
(`src/audio.gd`) with warmer, less-synthetic clips. Each entry maps to one clip
key the game already plays; keep the filenames so a drop-in loader can find them.

## Tools that fit

- **One-shot SFX + short loops:** ElevenLabs Sound Effects (text prompt, up to
  ~22 s, good for foley and stingers).
- **Music bed:** Suno, Udio, or Stable Audio (text prompt, ask for a loop).
- **Engines specifically:** real recordings from **freesound.org** (CC0) usually
  beat generated ones — search "tuk-tuk idle loop", "jeep engine steady",
  "small diesel truck idle". Generated engines tend to sound synthy.

## The house style (prepend to every prompt)

> Warm, cozy, storybook children's-book tone for a gentle animal-rescue driving
> game. Hand-crafted and organic — soft acoustic/foley textures, never harsh,
> electronic, or menacing. Cartoonish and friendly. Consequences are playful, not
> distressing. Mono, clean, minimal reverb.

## Delivery specs (so they import cleanly)

- **Format:** WAV (PCM 16-bit) or OGG Vorbis — Godot imports both. OGG for the
  long music loop (smaller); WAV is fine for short SFX.
- **Channels / rate:** mono, 44.1 kHz.
- **Levels:** normalize SFX peaks to about −4 dBFS; keep the music bed quieter
  (around −16 LUFS) so it sits under everything.
- **Trim:** cut leading silence on one-shots so they fire tight on the event.
- **Loops (engines + music):** must be **seamless** — edit on zero-crossings or
  add a short crossfade so there's no click at the loop point.
- **Filenames:** exactly the clip keys below + extension, e.g. `bail.wav`,
  `engine_tuktuk.wav`, `music.ogg`. Put them in `res://audio/`.

---

## One-shot SFX

| clip key | length | prompt |
|---|---|---|
| `jolt` | 0.2–0.4 s | A soft cartoon suspension bump: a light springy creak plus a muffled thud as a little vehicle rolls over a bump. Harmless, low, quick. |
| `bail` | 0.3–0.5 s | A cute comedic "boing": a small animal springing off a vehicle and landing with a soft plop. Springy twang, playful, gentle — not distressing. |
| `warn` | 0.2–0.3 s | A soft worried "uh-oh" — a quick, cute two-note chirp warning that a nervous animal is about to panic. Concerned but friendly, never alarming or harsh. (Plays repeatedly, so keep it short and non-grating.) |
| `munch` | 0.3–0.5 s | Happy animal eating: two or three quick crunchy nibbles of a carrot and lettuce. Wholesome foley, close-mic'd. |
| `vet` | 0.4–0.6 s | A soft reassuring "all better" chime: a warm two-note glockenspiel or bell, caring and calm. |
| `rescue` | 0.5–0.8 s | A bright cheerful little flourish: a quick rising three-note marimba/glockenspiel run — relief and delight when an animal is saved just in time. Storybook. |
| `sanctuary` | 0.8–1.2 s | A warm arrival stinger: a gentle major chord swell on soft strings and celesta with a light shaker — a cozy "you made it home" feeling. |
| `load` | 0.3–0.5 s | A cute content little grumble/chirrup as an animal clambers aboard and settles in. Playful, wholesome. |
| `tap` | 0.05–0.1 s | A soft warm wooden UI click, like a small wooden toggle. Subtle. |
| `star` | 0.2–0.3 s | A bright cheerful reward "ping" — a clean glockenspiel/bell sparkle for earning a star. |

## Engine loops (seamless, steady RPM)

The game **pitch-shifts these with speed**, so record/generate at a **steady
mid RPM** (not revving) — the code raises the pitch as the vehicle speeds up. Keep
each 2–3 s and seamless.

| clip key | prompt |
|---|---|
| `engine_tuktuk` | A small three-wheeled tuk-tuk / auto-rickshaw engine puttering at a steady idle: light, buzzy, tinny two-stroke "putt-putt", friendly not annoying. Seamless loop, steady RPM, no horn. |
| `engine_jeep` | An old open-top 4×4 jeep petrol engine at a steady cruising RPM: warm mechanical chug, cozy rumble. Seamless loop, steady RPM. |
| `engine_truck` | A small delivery truck's diesel engine at a steady low RPM: deep, warm, gentle idle rumble. Seamless loop, steady RPM. |

> If the pitched extremes sound off (too deep when crawling, chipmunky at top
> speed), tell me — I'll narrow the pitch range in `audio.gd`.

## Music bed

| clip key | length | prompt |
|---|---|---|
| `music` | 20–40 s, **looping** | A gentle, warm, whimsical instrumental loop for a cozy animal-rescue driving game. Light ukulele or nylon acoustic guitar, soft glockenspiel, brushed percussion, mellow upright bass. Relaxed ~90 bpm, hopeful and unhurried, Ghibli-cozy / storybook. No vocals. Seamless loop. |

## Optional upgrade — per-animal voices

Each animal already has a one-line personality; a short call per animal (played
on load-in / mood change) would double that character. If you want them, generate
these and I'll wire per-animal playback:

- **wombat** — a low, placid grunt/huff. Unbothered.
- **rabbit** — fast, timid high squeaks. Nervy.
- **fox** — a sly little yip.
- **tortoise** — a slow, soft exhale (barely a sound).
- **parrot** — a dramatic, loud squawk.
- **goat** — a stubborn, comedic bleat.

---

## Dropping them in

Put the files in `res://audio/` with the exact clip-key filenames. I can add a
loader to `audio.gd` that prefers a file when present and falls back to the
procedural clip otherwise — so you can replace them **one at a time** and hear
each swap immediately, with nothing breaking if a file is missing.
