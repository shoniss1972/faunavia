# Faunavia TODO additions — 2026-07-20

These items are approved additions to the main product TODO and should be incorporated into the relevant implementation phases.

## Level 13 — Kiwi night drive

- [ ] Make Level 13 a genuine night mission rather than a darkened daytime palette.
- [ ] Use the jeep for the mission and render a moving headlight cone that reveals the playable road and approaching hazards.
- [ ] Add a star-filled sky, dark native-bush silhouettes, ferns, wet-road reflections and roadside reflectors.
- [ ] Keep hazards readable on a phone without making the whole environment uniformly bright.
- [ ] Let Level 14 move toward pre-dawn or twilight so the two-level Kiwi chapter visibly progresses.
- [ ] Test that the headlights reinforce atmosphere and road-reading rather than obscuring terrain cues.

**Acceptance test:** Level 13 is immediately recognisable as a nocturnal New Zealand rescue and remains fully playable on a phone at normal brightness.

## Tortoise sprite continuity fix

- [ ] Replace the inconsistent Tortoise mood sprites.
- [ ] Ensure content, annoyed, delighted, talking and action frames all use the same shell colour, markings, proportions, lighting, framing and angle.
- [ ] Review all existing animal mood sets for similar identity drift.

**Acceptance test:** changing mood reads as one Tortoise changing expression, not different tortoises swapping into the vehicle.

## Campaign navigation and level-select redesign

A flat grid of approximately 24 equal-looking level buttons will become crowded and make the campaign feel like a menu rather than an international rescue journey. Keep replay access, but make forward progress the default.

- [ ] Put a dominant **Continue** action on the home screen that opens the next unlocked mission or current mission brief.
- [ ] Replace the expanding level-button grid with a chapter-based journey map grouped around each two-level animal/region arc.
- [ ] Show the current chapter prominently.
- [ ] Collapse completed chapters into compact destinations that can still be opened for replay and star improvement.
- [ ] Show locked future regions as restrained teaser markers without revealing their full animal rule.
- [ ] Preserve clear access to previous missions, stars and best results without making replay the primary path.
- [ ] Validate the design at 24 missions on real phone screens; do not merely move the old scrolling or tap-target problem into a new layout.
- [ ] Update save/unlock navigation so **Continue** always resolves safely after retries, replaying old levels and save migration.

**Acceptance test:** an unfamiliar player can immediately continue the campaign, explain where they are in the journey and find an older mission to replay without scanning 24 equal-looking buttons.

## Sanctuary arrival celebration

The arrival should become the emotional payoff for each rescue and visibly demonstrate that the sanctuary is growing because of the player.

- [ ] After a successful delivery, open the sanctuary gates and show a short arrival sequence before or alongside the results screen.
- [ ] Add a friendly vet who welcomes or checks in the newly delivered animal; keep the tone warm and celebratory rather than clinical.
- [ ] Give the arriving animal its own brief personality beat before the group celebration—for example, Kiwi pecks suspiciously, Tortoise slowly emerges and Capybara sways contentedly.
- [ ] Let a rotating subset of previously rescued animals dance, bounce, cheer or perform their signature happy action.
- [ ] Increase the visible sanctuary population as more species are delivered so progression is reflected in the world, not only in stars and menus.
- [ ] Use the full rescued roster for major chapter completions and the Level 24 finale, with staging that remains readable on a phone.
- [ ] Make repeated celebrations brief and skippable after first viewing while preserving the first-delivery version as a meaningful reward.
- [ ] Add a short celebratory music sting, selected animal calls and a vet reaction without creating overlapping audio clutter.
- [ ] Connect the sequence to the Sanctuary Book: highlight the new or updated entry after the celebration.
- [ ] Keep this as authored presentation, not free-roaming animal AI or sanctuary-management gameplay.

**Acceptance test:** players understand that each rescue permanently adds life and personality to the sanctuary and look forward to seeing the next animal arrive.

## Implementation-order changes

- [ ] Treat the Tortoise sprite replacement as an immediate visual-continuity bug, not a late polish item.
- [ ] Include the night environment and working jeep headlights in the complete Kiwi/Levels 13–14 vertical slice.
- [ ] Replace the flat level grid before the campaign reaches 24 visible missions.
- [ ] Include the first vet welcome and sanctuary arrival celebration in the initial Sanctuary Book/Kiwi slice, then generalise it for later animals.
