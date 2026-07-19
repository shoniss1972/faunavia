# New Animal — Image Brief (reusable scaffold)

Fill in §1, then paste §3's three prompts (one per mood) into Claude with the
reference image attached. Everything outside the brackets stays identical every
time — consistency across the set matters more than any single image.

---

## 1. Fill this in per animal

| Field | Value |
|---|---|
| **Animal id** (lowercase, matches `Animals.DATA`) | `________` |
| **Display name** | ________ |
| **Main colour hex** (also used for the prep swatch / cab) | `#______` |
| **Temperament word** | ________ |
| **Personality to show in the face** | ________ |
| **Silhouette signature** (the ONE feature that reads at 90 px) | ________ |
| **Accent details** (max 2 — markings, crest, shell, horns…) | ________ |

> **Silhouette rule:** the signature feature must be identifiable in a black
> cutout. Ears, beak, shell, horns, crest — shape, not colour or texture. This
> was the original tester's #1 complaint; it is what we're buying.

### Worked example (kiwi — already in `Animals.DATA`)

| Field | Value |
|---|---|
| Animal id | `kiwi` |
| Display name | Kiwi |
| Main colour hex | `#6b5844` |
| Temperament | wary |
| Personality | watchful, easily startled, endearing |
| Silhouette signature | long thin slightly-curved beak on a round, neckless, tail-less body |
| Accent details | shaggy hair-like feather texture; tiny vestigial no-wings |

## 2. Non-negotiable technical specs (do not edit)

- **Background: solid flat magenta `#FF00FF`**, uniform edge to edge. Never ask
  for transparency — models paint an opaque checkerboard. We key magenta out.
  Nothing on the animal may be magenta or pink.
- **Canvas:** square **1024 × 1024** (downscaled in-engine; big keeps edges crisp).
- **Pose:** **head-dominant** — the head fills most of the frame with only a hint
  of shoulders/chest below (like the existing wombat and parrot sprites), facing
  the camera in a gentle **3/4 view looking slightly right** (direction of travel).
  The head, not the body, is the subject. Not a full torso, not full body, not
  profile.
- **Placement:** centred, ~80% of frame, clear magenta margin on all four sides —
  must not touch or crop at any edge.
- **Outline:** thin darker outline fully enclosing the character, no gaps.
- **One subject only:** no props, vehicle, text, watermark, or shadow.
- **Delighted needs an OPEN mouth.** The engine reuses the *delighted* sprite as
  the talking frame — it flashes to it while the animal calls out, to fake mouth
  movement. A closed-mouth happy face makes talking read as nothing, so the
  delighted mouth must be clearly open (see §3).
- **Framing consistency:** eyeline height and head size matching the existing
  set — species differ by *shape*, not zoom level. Keep the head large; do not
  zoom out to show a torso.

## 3. The three prompts (fill brackets, paste one per mood)

Attach the animal's own **content** image as reference when generating the
annoyed/delighted variants ("same character, same style, change only the face").
For the content pass, attach an existing animal sprite as the style reference.

> A single [SILHOUETTE SIGNATURE + ACCENT DETAILS description], main colour
> [#HEX], head-and-shoulders bust, facing the camera in a gentle 3/4 view looking
> slightly to the right, centred and upright, filling about 80% of a square frame
> with clear empty margin on all four sides — the animal must not touch or be
> cropped by any edge. Expression: **[pick one]**
> - *content:* calm and pleasant, eyes open, small closed smile
> - *annoyed:* grumpy, furrowed brow, flattened ears (or equivalent), slight frown
> - *delighted:* joyful, **mouth clearly open** in a big grin (this frame doubles
>   as the talking animation), sparkling wide eyes, features perked
>
> Cute, friendly mobile-game mascot style. Bold clean shapes, soft rounded forms,
> smooth flat cel-shading with a subtle soft edge, thin darker outline fully
> enclosing the character. Large friendly cartoon eyes. Storybook-charming, not
> realistic, not photographic, not a glossy 3D render. Warm, slightly muted
> natural palette. Personality to convey: [PERSONALITY].
> The background must be solid flat pure magenta #FF00FF, completely uniform
> across the entire frame — no gradient, vignette, texture, shadow, or
> checkerboard/transparency pattern. Nothing on the character may be magenta or
> pink. No props, no text, no watermark. 1024x1024.

## 4. Acceptance checklist (reject and regenerate on any miss)

- [ ] Signature feature obvious in silhouette at thumbnail size
- [ ] Head size and eyeline match the existing six animals (head large, not zoomed
      out to a torso)
- [ ] Delighted mood has a clearly OPEN mouth (it doubles as the talking frame)
- [ ] All three moods identical except the face
- [ ] Clean uniform magenta, keyable, no colour bleed into the outline
- [ ] Style indistinguishable from the existing set side by side

## 5. Delivery

Key out the magenta, export PNG with real alpha, and save as:

```
assets/animals/<id>_content.png
assets/animals/<id>_annoyed.png
assets/animals/<id>_delighted.png
```

Then add the sprite placement entry (`scale` + `offset`) to `CRITTER_ART` in
`src/main.gd` — tune so the HEAD reads the same size as the others in the cab.

> **Import first, then export.** After dropping the PNGs in, open the project in
> the Godot editor once so it generates the `.png.import` files *before* you
> web-export. A headless export of files the editor has never imported ships
> without them (blank sprites) — same gotcha as the audio files.
