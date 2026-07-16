# Faunavia — Animal Art Brief (for Gemini image generation)

Goal: replace the flat code-drawn critters with six visually distinct animal
sprites that read instantly as different creatures at small size on a phone.
The tester's #1 complaint was "the animals all look the same" — silhouette and
character are what we're buying here, not realism.

---

## 1. Non-negotiable technical specs

Give Gemini these constraints on every generation. Getting them consistent
across all six is more important than any single image looking great.

- **Background: solid flat magenta `#FF00FF`.** **Do not ask for a transparent
  background** — see the warning below. We key the magenta out ourselves. The
  background must be one uniform colour edge to edge: no gradient, no vignette,
  no texture, no drop shadow, and **no checkerboard pattern**.
- **Canvas:** **square, 1024 × 1024**. We downscale in-engine; generating big
  keeps edges crisp when the sprite is only ~90 px tall on screen.
- **Subject placement:** the animal **centred**, filling ~80% of the frame.
  **The animal must not touch or run off any edge** — a clear magenta margin all
  round is what lets the background key cleanly.
- **Unbroken outline.** Every animal fully enclosed by its thin darker outline,
  with no gaps where the background colour meets the fill directly.
- **One subject only.** No accessories, no vehicle, no props, no text/labels,
  no signature or watermark.

> **Why not transparent:** we tried. Gemini cannot emit a real alpha channel —
> asked for "transparent background" it renders a *picture of* a transparency
> checkerboard, fully opaque, because that is what cutouts look like in its
> training data. The first sheet came back 100% opaque with painted grey squares
> and was unusable. Magenta is chosen because it appears nowhere in the palette
> in §5; white would collide with the goat's white fur, the fox's cream muzzle,
> and the rabbit's sand coat.
- **Even lighting, flat colour.** Soft, mostly-flat shading with a single gentle
  light from top-left. Avoid dramatic shadows, gradients-heavy realism, or busy
  texture — it won't survive downscaling and clashes with the flat 2D game.

## 2. View & pose (this is what makes them swap in cleanly)

The game is a **side-scrolling drive**; animals ride as passengers poking out of
the cab/cargo bed, looking out toward the player.

- **Pose:** a **head-and-shoulders "bust", facing the camera in gentle 3/4 view**
  (looking slightly to the *right*, the direction of travel). Not a full body,
  not a side profile.
- **Consistent framing:** eyeline at roughly the same height in every image;
  head roughly the same size across species (so a rabbit and a wombat read as
  different shapes, not just different zoom levels).
- **Upright and centred**, no tilt.

## 3. Art style (paste this block verbatim into every prompt)

> Cute, friendly mobile-game mascot style. Bold clean shapes, soft rounded
> forms, smooth flat cel-shading with a subtle soft edge, thin darker outline.
> Expressive cartoon face with large friendly eyes. Storybook-charming, not
> realistic, not photographic, not 3D-render glossy. Warm, slightly muted
> natural palette. Consistent character-design language across a set.

Keeping this identical on all six (and all moods) is the single biggest lever
for a cohesive set.

## 4. Mood variants — DECIDED: 3 expressions per animal, 18 sprites

The game's whole hook is that animals **react to how you drive** — they cycle
through **content → annoyed → delighted**. A static face per animal would lose
the expressiveness that is the point of the game, so we are generating each
animal three times, identical in every way *except the face*:

- **Content / neutral** — calm, pleasant, eyes open, small closed smile.
- **Annoyed** — grumpy, furrowed brow, flattened ears, slightly squinting,
  small frown. (Used when the ride gets rough.)
- **Delighted** — joyful, big open grin, sparkly wide eyes, ears perked.
  (Used when the ride thrills them.)

Same pose, same body, same colours, same framing — only the expression changes,
so they swap frame-to-frame in place. This keeps the core mechanic intact and
makes it *more* legible than the current code faces, which was the tester's
"driving doesn't seem to make any difference" complaint.

**6 animals × 3 moods = 18 sprites.** Generate in two passes: the six content
faces first (§8 step 1), then each animal's annoyed and delighted variants using
its own content image as the reference (§8 step 2). The content pass alone is a
shippable checkpoint if you want to prove the pipeline before committing to all
18 — it already kills the "all look the same" complaint.

## 5. Palette — match these to the in-game UI

Each animal already has a colour used on its prep-screen swatch and cab. Ask
Gemini to key the animal's main colour to these so the sprite matches the UI:

| Animal   | Main colour | Hex       | Temperament | Personality to show |
|----------|-------------|-----------|-------------|---------------------|
| Wombat   | muted brown | `#7d6f63` | placid      | sleepy, unbothered, chunky |
| Rabbit   | warm sand   | `#cbb89d` | timid       | nervous, wide-eyed, delicate |
| Fox      | burnt orange| `#c8743a` | sly         | clever, smug, mischievous |
| Tortoise | olive green | `#6f7d52` | slow        | serene, ancient, wrinkly |
| Parrot   | bright green| `#3f9d5a` | loud        | brash, showy, chatty |
| Goat     | pale grey   | `#b0a89a` | stubborn    | grumpy, headstrong, defiant |

## 6. Per-animal silhouette notes (what makes each unmistakable)

The distinguishing feature must be obvious in **silhouette** — that's what the
tester was missing.

- **Wombat** — broad, round, low head; short rounded ears; wide flat nose; stocky
  and heavy-looking. Reads as "chunky brown potato with a face." Muted brown `#7d6f63`.
- **Rabbit** — small round head with **two tall upright ears** (the signature);
  tiny twitchy nose, big timid eyes. Warm sand `#cbb89d`.
- **Fox** — **large pointed triangular ears**, narrow snout, pale muzzle/chest,
  a hint of a sly grin. Burnt orange `#c8743a` with cream cheeks.
- **Tortoise** — wrinkly green head on a long-ish neck emerging from a **domed
  patterned shell** at the shoulders (shell is the tell); heavy-lidded calm eyes.
  Olive `#6f7d52`.
- **Parrot** — rounded bird head with a **hooked beak** and a small **head crest**;
  bright plumage, maybe a cheek patch. Vivid green `#3f9d5a` with an accent colour.
- **Goat** — **curved horns** and **floppy side ears**, rectangular pupils, a tuft
  of chin fur; a stubborn set to the mouth. Pale grey `#b0a89a`.

## 7. Copy-paste prompt template

Fill in the two bracketed spots per generation. Keep everything else identical.
Attach the approved style-reference image to every generation (§8).

> A single [ANIMAL DESCRIPTION FROM §6], head-and-shoulders bust, facing the
> camera in a gentle 3/4 view looking slightly to the right, centred and upright,
> filling about 80% of a square frame with clear empty margin on all four sides —
> the animal must not touch or be cropped by any edge. Expression: [content and
> calm with a small closed smile / annoyed and grumpy with furrowed brow and
> flattened ears / delighted with a big open grin and sparkling wide eyes].
> Cute, friendly mobile-game mascot style. Bold clean shapes, soft rounded forms,
> smooth flat cel-shading with a subtle soft edge, thin darker outline fully
> enclosing the character. Large friendly cartoon eyes. Storybook-charming, not
> realistic, not photographic, not a glossy 3D render. Warm, slightly muted
> natural palette.
> The background must be solid flat pure magenta #FF00FF, completely uniform
> across the entire frame, with no gradient, no vignette, no texture, no shadow,
> and no checkerboard or transparency pattern of any kind. Nothing in the
> character may be magenta or pink. No props, no text, no watermark. 1024x1024.

## 8. Consistency workflow (do this, it matters)

Generative models drift in style between prompts. To fight that:

1. **Generate the six "content" faces first, ideally in one session** so the
   style carries. If Gemini supports it, ask for a **"character lineup / sprite
   sheet of all six animals in the same style, evenly spaced on a transparent
   background,"** then split them — that forces one coherent style. Otherwise
   generate the strongest one first and **use it as a style/reference image** for
   the other five ("in the exact same art style as this reference").
2. **Then** generate the annoyed and delighted variants **using each animal's own
   content image as the reference** ("same character, same style, same colours,
   change only the facial expression to …"). This keeps the three moods of one
   animal identical apart from the face.
3. Reject any that don't match framing/scale — a mismatched one will visibly jump
   when it swaps in. Consistency beats individual polish.

## 9. How these land in the game (so you know what to ask for)

- Files go in `assets/animals/` as `wombat_content.png`, `wombat_annoyed.png`,
  `wombat_delighted.png`, and the same three for rabbit, fox, tortoise, parrot,
  and goat — 18 files, lowercase animal name, exact mood suffix.
- Godot imports PNGs as textures automatically; I'll set filtering on (smooth
  downscale) and swap the `_draw_critter` code for a `draw_texture_rect`, picking
  the mood file from the current comfort state.
- Transparent background is essential — anything baked behind the animal will
  show as a box in the cab.
- If a sprite comes out facing left, I can flip it in-engine, so don't sweat the
  occasional wrong-way result — but consistent right-facing is cleaner.

---

**The ask to Gemini:** 18 sprites — 6 animals × 3 moods (§4) — using the §3
style block, the §7 template, and the §8 two-pass reference workflow, all
transparent 1024². The six content faces are the first pass and a valid
checkpoint; the annoyed/delighted passes are what restore the reaction hook.
