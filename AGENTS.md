# Faunavia Development Instructions

## Product goal

Prove the smallest enjoyable version of a mobile wildlife rescue logistics game. Optimise for playable learning, not architecture completeness.

## Technical direction

- Godot standard edition, not .NET.
- GDScript only unless explicitly changed by the owner.
- 2D portrait-first mobile design.
- Keep scenes and scripts small, readable, and data-driven only where it immediately reduces duplication.
- Prefer built-in Godot capabilities over plugins and external frameworks.

## Non-negotiable design rules

- Puzzle first; simulation second.
- No visible injury, suffering, predation, or death.
- Animals communicate negative states through humour, refusal, annoyance, or comic disapproval.
- Do not add multiplayer, accounts, advertisements, purchases, analytics, live operations, or backend services during prototyping.
- Do not add open-world exploration, free-roaming animal AI, realistic capture mechanics, liquid simulation, or elaborate procedural generation.
- Do not build custom editors, pipelines, frameworks, or abstraction layers before a concrete second use exists.

## Prototype order

1. One vehicle moves over a short route and consumes fuel.
2. One animal can be loaded and adds weight.
3. Rough travel affects animal comfort and triggers a comic reaction.
4. Incompatible animals cannot depart together without separation.
5. Equipment and vehicle choices determine whether a mission can be completed.
6. Complete a level, award stars, and unlock the next mission.
7. Test on a phone before expanding content.

## Definition of done for a change

- The project opens without import errors.
- The main scene runs.
- The changed mechanic can be demonstrated in under two minutes.
- No unrelated systems were added.
- Any new tuning value is exposed clearly in the editor or a small resource/data file.
- Relevant TODO items and playtest notes are updated.

## Coding approach

- Use typed GDScript where it improves clarity.
- Prefer composition and signals over deep inheritance.
- Name nodes, scenes, and scripts by gameplay responsibility.
- Keep deterministic rules separate from visual reactions where practical.
- Add automated tests only for stable rule logic that is easy to test; do not build a test framework before such logic exists.

## Scope challenge

Before adding any feature, ask:

1. Does this help prove the core loop?
2. Can it be represented more simply?
3. Can it wait until after external playtesting?

If the answer to the first question is no, defer it.
