class_name Levels
extends RefCounted

# Five short missions that escalate the prep puzzle. The gear lessons are
# ordered so each constraint is introduced alone before it is combined:
#   1. one placid animal — reteaches the loop with the new prep step
#   2. two compatible animals — introduces capacity and arrangement
#   3. lone fox — first equipment gate; the sly fox needs gloves
#   4. fox + rabbit — incompatibility; needs a divided cage (and still gloves)
#   5. all three — combines capacity, the cage, and gloves
#
#   vehicle   — which vehicle runs this level; its capacity holds the cargo
#   deliver   — animal ids that must be aboard to depart (the mission cargo)
#   equipment — gear the player may add in prep (each id is a toggle)
# Track fields shape the drive so no two levels feel the same:
#   length — finish distance (short early levels, long hauls later)
#   rough  — hill height multiplier (flat vs hilly; hillier punishes speed)
#   freq   — hill spacing multiplier
#   phase  — shifts where the hills fall, so each route looks distinct
#   route  — optional stop list as fractions of length (default: fuel, food, end)
const DATA := [
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
