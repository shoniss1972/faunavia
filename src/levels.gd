class_name Levels
extends RefCounted

# The active campaign is a focused FIVE-mission test path (Gate 5 revision). Each
# mission asks one distinct question, has its own terrain identity, and motivates
# the next vehicle by the load it carries:
#   1 First Rescue      — teach the loop: coax aboard, drive, arrive (wombat, trike)
#   2 Nervous Passenger — rough driving has a consequence (timid rabbit bails)
#   3 Which Road?       — a real route choice (safe detour vs rough shortcut)
#   4 Awkward Companions— compatibility + handling (fox + rabbit: cage + gloves)
#   5 Heavy Rescue      — a load the jeep can't carry, so the truck earns its place
#
# Level fields:
#   vehicle   — which vehicle runs this level; its capacity holds the cargo
#   deliver   — animal ids that must be aboard (auto-loaded on the prep brief)
#   equipment — gear the load requires (auto-included; the brief explains why)
#   hook      — a one-line teaser of this mission's new wrinkle, shown on the
#               locked button in level select and in the result screen's "next"
#               teaser. Hint the new problem/character; don't spell out the rules.
#   routes    — optional [safe, rough] choice surfaced in prep (see prep.gd)
# Track fields shape the drive so no two missions feel the same:
#   length — finish distance      rough — hill height (hillier punishes speed)
#   freq   — hill spacing         phase — shifts where hills fall
#   route  — optional stop list as fractions of length (default: fuel, food, end)
const DATA := [
	{
		"title": "Level 1 — First Rescue",
		"vehicle": "bicycle", "deliver": ["wombat"], "equipment": [],
		"length": 1500.0, "rough": 0.5, "freq": 1.0, "phase": 0.0,
		"hook": "Learn the ropes with a placid wombat.",
		"brief": "Meet the wombat — placid and unbothered. Coax it aboard the cargo trike and roll gently to the sanctuary.",
	},
	{
		"title": "Level 2 — Nervous Passenger",
		"vehicle": "bicycle", "deliver": ["rabbit"], "equipment": [],
		"length": 1700.0, "rough": 0.85, "freq": 1.05, "phase": 300.0,
		"hook": "A timid rabbit that bolts on rough ground.",
		"brief": "The rabbit is timid — every jolt frightens it. Take the bumps slowly, or it may lose its nerve and leap off before you arrive.",
	},
	{
		"title": "Level 3 — Which Road?",
		"vehicle": "jeep", "deliver": ["wombat", "rabbit"], "equipment": [],
		"length": 1900.0, "rough": 0.8, "freq": 1.05, "phase": 120.0,
		"hook": "Your first real choice: safe road or rough shortcut.",
		"brief": "Two roads to the sanctuary. The rabbit is timid — pick the route that suits your passengers.",
		# A real choice: the gentle road is slow but kind and has a feeding stop;
		# the shortcut is quick but rough, and a nervous animal may not survive it
		# unless you crawl. Whichever is picked feeds the drive via loadout_route.
		"routes": [
			{
				"label": "Safe road",
				"desc": "Longer but forgiving — an early feeding stop keeps nervous animals aboard. Drive it smoothly for all three stars.",
				"length": 2400.0, "rough": 0.6, "freq": 1.0, "phase": 120.0,
				"route": [
					{"type": "food", "at": 0.3},
					{"type": "sanctuary", "at": 1.0},
				],
			},
			{
				"label": "Rough shortcut",
				"desc": "Half the distance, sharp hills, no stops. Quicker if you're deft — but a timid animal bails if you rush it.",
				"length": 1450.0, "rough": 1.0, "freq": 1.1, "phase": 300.0,
				"route": [
					{"type": "sanctuary", "at": 1.0},
				],
			},
		],
	},
	{
		"title": "Level 4 — Awkward Companions",
		"vehicle": "jeep", "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"length": 1950.0, "rough": 0.85, "freq": 0.95, "phase": 500.0,
		"hook": "A fox and rabbit who can't share a cage.",
		"brief": "The fox eyes the rabbit like lunch. A divided cage keeps the peace — and the sly fox needs gloves before you handle it.",
	},
	{
		"title": "Level 5 — Heavy Rescue",
		"vehicle": "truck", "deliver": ["tortoise", "wombat"], "equipment": ["ramp"],
		"length": 2600.0, "rough": 1.0, "freq": 0.95, "phase": 700.0,
		"route": [
			{"type": "vet", "at": 0.5},
			{"type": "sanctuary", "at": 1.0},
		],
		"hook": "Too heavy for the jeep — the truck earns its place.",
		"brief": "The tortoise and wombat together are too heavy for the jeep — only the truck will do. Pack a ramp so the tortoise can climb aboard, and settle in for the long haul.",
	},
]

# The original twelve-level set, kept for development and reference — NOT the
# active campaign. The five-mission path above is what external testers play; do
# not use raw level count as evidence the prototype works (see TODO milestone 5).
const ARCHIVED_LEVELS := [
	{
		"title": "Level 1 — First Rescue",
		"vehicle": "bicycle", "deliver": ["wombat"], "equipment": [],
		"length": 1650.0, "rough": 0.5, "freq": 1.0, "phase": 0.0,
		"brief": "Take the wombat to the sanctuary on the cargo trike.",
	},
	{
		"title": "Level 2 — Handle With Care",
		"vehicle": "bicycle", "deliver": ["fox"], "equipment": ["gloves"],
		"length": 1750.0, "rough": 0.6, "freq": 1.0, "phase": 300.0,
		"brief": "The fox is sly. Bring gloves before you load it.",
	},
	{
		"title": "Level 3 — Two Aboard",
		"vehicle": "jeep", "deliver": ["wombat", "rabbit"], "equipment": [],
		"length": 1900.0, "rough": 0.8, "freq": 1.05, "phase": 120.0,
		"brief": "The jeep can carry the wombat and rabbit together.",
	},
	{
		"title": "Level 4 — Keep the Peace",
		"vehicle": "jeep", "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"length": 1950.0, "rough": 0.9, "freq": 0.95, "phase": 500.0,
		"brief": "Fox and rabbit together needs a divided cage — and the fox needs gloves.",
	},
	{
		"title": "Level 5 — Slow and Steady",
		"vehicle": "jeep", "deliver": ["tortoise"], "equipment": ["ramp"],
		"length": 2100.0, "rough": 0.6, "freq": 1.1, "phase": 800.0,
		"brief": "The tortoise can't clamber up — pack a loading ramp.",
	},
	{
		"title": "Level 6 — Odd Couple",
		"vehicle": "jeep", "deliver": ["goat", "parrot"], "equipment": ["leash"],
		"length": 2000.0, "rough": 1.0, "freq": 1.15, "phase": 250.0,
		"brief": "The goat wanders off without a leash. The parrot just tags along.",
	},
	{
		"title": "Level 7 — Loud and Timid",
		"vehicle": "jeep", "deliver": ["parrot", "rabbit"],
		"equipment": ["divided_cage"],
		"length": 1900.0, "rough": 1.1, "freq": 1.0, "phase": 640.0,
		"brief": "The parrot's racket rattles the timid rabbit — separate them.",
	},
	{
		"title": "Level 8 — Mixed Cargo",
		"vehicle": "truck", "deliver": ["wombat", "goat", "fox"],
		"equipment": ["gloves", "leash"],
		"length": 2300.0, "rough": 1.0, "freq": 0.9, "phase": 400.0,
		"brief": "Three aboard the truck, two of them needing gear.",
	},
	{
		"title": "Level 9 — Trike Overflow",
		"vehicle": "bicycle", "deliver": ["wombat", "goat"],
		"equipment": ["leash"], "trailer": true,
		"length": 2100.0, "rough": 1.25, "freq": 1.2, "phase": 150.0,
		"brief": "Two won't fit on the trike alone — hitch a trailer.",
	},
	{
		"title": "Level 10 — The Long Haul",
		"vehicle": "truck", "deliver": ["tortoise", "wombat", "fox"],
		"equipment": ["ramp", "gloves"],
		"length": 2700.0, "rough": 1.0, "freq": 0.95, "phase": 700.0,
		"route": [
			{"type": "fuel", "at": 0.30},
			{"type": "vet", "at": 0.55},
			{"type": "fuel", "at": 0.75},
			{"type": "sanctuary", "at": 1.0},
		],
		"brief": "A long haul — two fuel stops and a vet. Keep them calm.",
	},
	{
		"title": "Level 11 — Trailer Team",
		"vehicle": "jeep", "deliver": ["tortoise", "goat", "parrot"],
		"equipment": ["ramp", "leash"], "trailer": true,
		"length": 2200.0, "rough": 1.2, "freq": 1.1, "phase": 300.0,
		"brief": "Too much for the jeep alone — trailer up and pack the gear.",
	},
	{
		"title": "Level 12 — Grand Convoy",
		"vehicle": "truck", "deliver": ["wombat", "fox", "tortoise", "goat", "parrot"],
		"equipment": ["gloves", "ramp", "leash"], "trailer": true,
		"length": 2900.0, "rough": 1.35, "freq": 1.05, "phase": 900.0,
		"route": [
			{"type": "fuel", "at": 0.28},
			{"type": "food", "at": 0.48},
			{"type": "fuel", "at": 0.68},
			{"type": "vet", "at": 0.85},
			{"type": "sanctuary", "at": 1.0},
		],
		"brief": "Five animals, truck and trailer, every kind of gear. The big one.",
	},
]

const EQUIPMENT_NAMES := {
	"divided_cage": "Divided Cage",
	"gloves": "Gloves",
	"ramp": "Loading Ramp",
	"leash": "Leash",
}


static func count() -> int:
	return DATA.size()


static func get_level(index: int) -> Dictionary:
	if index < 0 or index >= DATA.size():
		return {}
	return DATA[index]


static func equipment_name(id: String) -> String:
	return EQUIPMENT_NAMES.get(id, id)
