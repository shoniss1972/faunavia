class_name Animals
extends RefCounted

# The six rescue animals. Kept as plain data so levels, the prep screen, and the
# driving scene all read the same traits without duplicating them.
#   size         — cargo slots the animal occupies against vehicle capacity
#   weight       — contributes to the vehicle's handling load (kg)
#   temperament  — flavour word shown in prep
#   personality  — the animal's one memorable gameplay rule, in plain words. This
#                  is how a trait reads to the player: it hints at how forgiving
#                  the animal is on a rough ride without exposing raw sensitivity
#                  numbers (see TODO milestone 4). Keep each to a short phrase.
#   colour       — fur/feather colour drawn in the cab
#   incompatible — ids this animal cannot ride beside without a divided cage
#   requires     — equipment ids that must be aboard to carry this animal
#   disturbed_by — ids whose mere presence aboard frets this animal (the `social`
#                  comfort input): a soft, drive-around problem, not a hard block
#                  like `incompatible`. A divided cage cancels it (see main.gd).
#   comfort      — per-input comfort SENSITIVITY, the data behind the drive's
#                  comfort model (main.gd). Each key is a distinct source of unease
#                  and its value multiplies how fast that source drains this animal
#                  (0 or absent = immune). This is what lets each new species drive
#                  differently without species-name branches in main.gd:
#                    jolt    — sharp terrain bumps (the classic bump-tolerance axis)
#                    speed   — sustained high speed (a Red Panda clings on)
#                    accel   — abrupt starts/stops (a Kiwi hates sudden inputs)
#                    airtime — tilt / launches / hard landings (a top-heavy Flamingo)
#                    social  — a loud or disliked neighbour (see relationships, TBD)
#                  The current six read the ride through `jolt` only, so they behave
#                  exactly as before; the other inputs arrive with the animals that
#                  use them.
const DATA := {
	"wombat": {
		"name": "Wombat", "size": 2, "weight": 26.0, "temperament": "placid",
		"personality": "shrugs off the roughest ride",
		"colour": "#7d6f63", "incompatible": [], "requires": [],
		"comfort": {"jolt": 0.55},
	},
	"rabbit": {
		"name": "Rabbit", "size": 1, "weight": 3.0, "temperament": "timid",
		"personality": "panics on bumps — drive it gently",
		"colour": "#cbb89d", "incompatible": ["fox", "parrot"], "requires": [],
		"comfort": {"jolt": 1.7},
	},
	"fox": {
		"name": "Fox", "size": 2, "weight": 7.0, "temperament": "sly",
		"personality": "a sly escape artist; handle with gloves",
		"colour": "#c8743a", "incompatible": ["rabbit"], "requires": ["gloves"],
		"comfort": {"jolt": 1.0},
	},
	"tortoise": {
		"name": "Tortoise", "size": 3, "weight": 40.0, "temperament": "slow",
		"personality": "heavy but unflappable; needs a ramp",
		"colour": "#6f7d52", "incompatible": [], "requires": ["ramp"],
		"comfort": {"jolt": 0.7},
	},
	"parrot": {
		"name": "Parrot", "size": 1, "weight": 1.0, "temperament": "loud",
		"personality": "loud and dramatic when jostled",
		"colour": "#3f9d5a", "incompatible": ["rabbit"], "requires": [],
		"comfort": {"jolt": 1.3},
	},
	"goat": {
		"name": "Goat", "size": 2, "weight": 14.0, "temperament": "stubborn",
		"personality": "a stubborn wanderer; keep it leashed",
		"colour": "#b0a89a", "incompatible": [], "requires": ["leash"],
		"comfort": {"jolt": 0.9},
	},
	# --- International expansion: New Zealand flagship (TODO Phase B) ---
	"kiwi": {
		"name": "Kiwi", "size": 1, "weight": 3.0, "temperament": "wary",
		"personality": "brake gently — sudden stops rattle it; hates the parrot's racket",
		"colour": "#6b5844", "incompatible": [], "requires": [],
		# Barely notices bumps (low jolt), but frets at hard braking (accel) and at
		# the parrot's presence (social) — a wholly different way to drive.
		"comfort": {"jolt": 0.2, "accel": 1.5, "social": 1.0},
		"disturbed_by": ["parrot"],
	},
	"capybara": {
		"name": "Capybara", "size": 2, "weight": 34.0, "temperament": "placid",
		"personality": "heavy and hungry, but unshakeable — a nervous neighbour settles beside it",
		"colour": "#8a6b4a", "incompatible": [], "requires": [],
		# Impossible to rattle: barely reacts to anything (tiny jolt only). Its point
		# is the "soothes" flag — a calming presence that eases every neighbour's
		# unease (see _calm_factor). Heavy, so it drives fuel use up: a benefit that
		# costs range, not capacity.
		"comfort": {"jolt": 0.15},
		"soothes": true,
	},
}


static func get_data(id: String) -> Dictionary:
	return DATA.get(id, {})


static func display_name(id: String) -> String:
	return DATA.get(id, {}).get("name", id)


static func personality(id: String) -> String:
	return DATA.get(id, {}).get("personality", "")


static func comfort_sens(id: String, input: String) -> float:
	# How fast `input` (jolt/speed/accel/airtime/social) drains this animal's comfort.
	# 0 (or absent) means immune to that source — the drive multiplies each frame's
	# stress by this, so a species declares its whole ride personality here.
	return float(DATA.get(id, {}).get("comfort", {}).get(input, 0.0))
