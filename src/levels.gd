class_name Levels
extends RefCounted

# The active campaign is the full TWELVE-mission set. The first five are the
# refined Gate 5 test path (each asks one distinct question and has its own
# terrain identity); levels 6–12 grow the cast, gear, trailer, and route stops
# toward the grand convoy:
#   1 First Rescue      — teach the loop: coax aboard, drive, arrive (wombat, trike)
#   2 Nervous Passenger — rough driving has a consequence (timid rabbit bails)
#   3 Which Road?       — a real route choice (safe detour vs rough shortcut)
#   4 Awkward Companions— compatibility + handling (fox + rabbit: cage + gloves)
#   5 Heavy Rescue      — a load the jeep can't carry, so the truck earns its place
#   6–12                — new pairings, the trailer, multi-animal hauls, lifeline
#                         stops, up to the five-animal grand convoy
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
		"length": 3000, "rough": 0.5, "freq": 1.0, "phase": 0.0,
		"hook": "Learn the ropes with a placid wombat.",
		"brief": "Meet the wombat — placid and unbothered. Coax it aboard the cargo trike and roll gently to the sanctuary.",
	},
	{
		"title": "Level 2 — Nervous Passenger",
		"vehicle": "bicycle", "deliver": ["rabbit"], "equipment": [],
		"length": 3400, "rough": 1.1, "freq": 1.05, "phase": 300.0,
		"hook": "A timid rabbit that bolts on rough ground.",
		"brief": "The rabbit is timid — every jolt frightens it. Take the bumps slowly, or it may lose its nerve and leap off before you arrive.",
	},
	{
		"title": "Level 3 — Which Road?",
		"vehicle": "jeep", "deliver": ["wombat", "rabbit"], "equipment": [],
		"length": 3800, "rough": 0.8, "freq": 1.05, "phase": 120.0,
		"hook": "Your first real choice: safe road or rough shortcut.",
		"brief": "Two roads to the sanctuary. The rabbit is timid — pick the route that suits your passengers.",
		# A real choice: the gentle road is slow but kind and has a feeding stop;
		# the shortcut is quick but rough, and a nervous animal may not survive it
		# unless you crawl. Whichever is picked feeds the drive via loadout_route.
		"routes": [
			{
				"label": "Safe road",
				"desc": "Longer but forgiving — an early feeding stop keeps nervous animals aboard. Drive it smoothly for all three stars.",
				"length": 4800, "rough": 0.6, "freq": 1.0, "phase": 120.0,
				"route": [
					{"type": "food", "at": 0.3},
					{"type": "fuel", "at": 0.6},
					{"type": "sanctuary", "at": 1.0},
				],
			},
			{
				"label": "Rough shortcut",
				"desc": "Half the distance over sharp hills, with one feeding stop halfway. Quicker if you're deft — a timid animal bails if you rush it, but reach the feed in time and it steadies for the run home.",
				"length": 2900, "rough": 1.25, "freq": 1.1, "phase": 300.0,
				"route": [
					{"type": "fuel", "at": 0.28},
					{"type": "food", "at": 0.5},
					{"type": "sanctuary", "at": 1.0},
				],
			},
		],
	},
	{
		"title": "Level 4 — Awkward Companions",
		"vehicle": "jeep", "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"length": 3900, "rough": 0.85, "freq": 0.95, "phase": 500.0,
		"hook": "A fox and rabbit who can't share a cage.",
		"brief": "The fox eyes the rabbit like lunch. A divided cage keeps the peace — and the sly fox needs gloves before you handle it.",
	},
	{
		"title": "Level 5 — Heavy Rescue",
		"vehicle": "truck", "deliver": ["tortoise", "wombat"], "equipment": ["ramp"],
		"length": 5200, "rough": 1.0, "freq": 0.95, "phase": 700.0,
		"route": [
			{"type": "fuel", "at": 0.3},
			{"type": "vet", "at": 0.5},
			{"type": "fuel", "at": 0.68},
			{"type": "sanctuary", "at": 1.0},
		],
		"hook": "Too heavy for the jeep — the truck earns its place.",
		"brief": "The tortoise and wombat together are too heavy for the jeep — only the truck will do. Pack a ramp so the tortoise can climb aboard, and settle in for the long haul.",
	},
	{
		"title": "Level 6 — Odd Couple",
		"vehicle": "jeep", "deliver": ["goat", "parrot"], "equipment": ["leash"],
		"length": 4000, "rough": 1.0, "freq": 1.15, "phase": 250.0,
		"hook": "A stubborn goat and a chattering parrot share the jeep.",
		"brief": "The goat wanders off without a leash. The parrot just tags along — loud, but no trouble.",
	},
	{
		"title": "Level 7 — Loud and Timid",
		"vehicle": "jeep", "deliver": ["parrot", "rabbit"],
		"equipment": ["divided_cage"],
		"length": 3800, "rough": 1.0, "freq": 1.0, "phase": 640.0,
		"hook": "A loud parrot rattling a timid rabbit — keep them apart.",
		"brief": "The parrot's racket frightens the timid rabbit. A divided cage keeps the noise on its own side.",
	},
	{
		"title": "Level 8 — Mixed Cargo",
		"vehicle": "truck", "deliver": ["wombat", "goat", "fox"],
		"equipment": ["gloves", "leash"],
		"length": 4600, "rough": 1.0, "freq": 0.9, "phase": 400.0,
		"hook": "Three aboard the truck, two of them needing gear.",
		"brief": "Three passengers on the truck: the sly fox needs gloves, the goat needs a leash, and the wombat rides easy.",
	},
	{
		"title": "Level 9 — Trike Overflow",
		"vehicle": "bicycle", "deliver": ["wombat", "goat"],
		"equipment": ["leash"], "trailer": true,
		"length": 4200, "rough": 1.25, "freq": 1.2, "phase": 150.0,
		"hook": "Too many for the trike — hitch a trailer.",
		"brief": "The wombat and goat won't fit on the trike alone. Hitch a trailer for the overflow, and leash the goat.",
	},
	{
		"title": "Level 10 — The Long Haul",
		"vehicle": "truck", "deliver": ["tortoise", "wombat", "fox"],
		"equipment": ["ramp", "gloves"],
		"length": 5400, "rough": 1.0, "freq": 0.95, "phase": 700.0,
		"route": [
			{"type": "fuel", "at": 0.3},
			{"type": "vet", "at": 0.55},
			{"type": "fuel", "at": 0.7},
			{"type": "sanctuary", "at": 1.0},
		],
		"hook": "A long haul with a vet stop to keep the crew calm.",
		"brief": "A long, rough road with a vet stop halfway. Pack a ramp for the tortoise and gloves for the fox, and use the vet to steady anyone who frets.",
	},
	{
		"title": "Level 11 — Trailer Team",
		"vehicle": "jeep", "deliver": ["tortoise", "goat", "parrot"],
		"equipment": ["ramp", "leash"], "trailer": true,
		"length": 4400, "rough": 1.2, "freq": 1.1, "phase": 300.0,
		"hook": "Too much for the jeep alone — trailer up and gear up.",
		"brief": "Three won't fit the jeep alone — hitch a trailer. Ramp for the tortoise, leash for the goat, and the parrot rides along.",
	},
	{
		"title": "Level 12 — Grand Convoy",
		"vehicle": "truck", "deliver": ["wombat", "fox", "tortoise", "goat", "parrot"],
		"equipment": ["gloves", "ramp", "leash"], "trailer": true,
		"length": 5800, "rough": 1.35, "freq": 1.05, "phase": 900.0,
		"route": [
			{"type": "fuel", "at": 0.22},
			{"type": "food", "at": 0.4},
			{"type": "fuel", "at": 0.5},
			{"type": "fuel", "at": 0.75},
			{"type": "vet", "at": 0.88},
			{"type": "sanctuary", "at": 1.0},
		],
		"hook": "Five animals, truck and trailer — the big one.",
		"brief": "The whole menagerie: five animals, truck and trailer, every kind of gear. A feeding stop and a vet break the long, rough haul — use them.",
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
