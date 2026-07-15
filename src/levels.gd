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
const DATA := [
	{
		"title": "Level 1 — First Rescue",
		"vehicle": "bicycle", "deliver": ["wombat"], "equipment": [],
		"brief": "Take the wombat to the sanctuary on the cargo trike.",
	},
	{
		"title": "Level 2 — Handle With Care",
		"vehicle": "bicycle", "deliver": ["fox"], "equipment": ["gloves"],
		"brief": "The fox is sly. Bring gloves before you load it.",
	},
	{
		"title": "Level 3 — Two Aboard",
		"vehicle": "jeep", "deliver": ["wombat", "rabbit"], "equipment": [],
		"brief": "The jeep can carry the wombat and rabbit together.",
	},
	{
		"title": "Level 4 — Keep the Peace",
		"vehicle": "jeep", "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"brief": "Fox and rabbit together needs a divided cage — and the fox needs gloves.",
	},
	{
		"title": "Level 5 — Slow and Steady",
		"vehicle": "jeep", "deliver": ["tortoise"], "equipment": ["ramp"],
		"brief": "The tortoise can't clamber up — pack a loading ramp.",
	},
	{
		"title": "Level 6 — Odd Couple",
		"vehicle": "jeep", "deliver": ["goat", "parrot"], "equipment": ["leash"],
		"brief": "The goat wanders off without a leash. The parrot just tags along.",
	},
	{
		"title": "Level 7 — Loud and Timid",
		"vehicle": "jeep", "deliver": ["parrot", "rabbit"],
		"equipment": ["divided_cage"],
		"brief": "The parrot's racket rattles the timid rabbit — separate them.",
	},
	{
		"title": "Level 8 — Mixed Cargo",
		"vehicle": "truck", "deliver": ["wombat", "goat", "fox"],
		"equipment": ["gloves", "leash"],
		"brief": "Three aboard the truck, two of them needing gear.",
	},
	{
		"title": "Level 9 — Trike Overflow",
		"vehicle": "bicycle", "deliver": ["wombat", "goat"],
		"equipment": ["leash"], "trailer": true,
		"brief": "Two won't fit on the trike alone — hitch a trailer.",
	},
	{
		"title": "Level 10 — The Long Haul",
		"vehicle": "truck", "deliver": ["tortoise", "wombat", "fox"],
		"equipment": ["ramp", "gloves"],
		"route": [
			{"type": "fuel", "x": 900.0},
			{"type": "vet", "x": 1450.0},
			{"type": "sanctuary", "x": 2050.0},
		],
		"brief": "A full truck and a vet stop on the way. Keep them calm.",
	},
	{
		"title": "Level 11 — Trailer Team",
		"vehicle": "jeep", "deliver": ["tortoise", "goat", "parrot"],
		"equipment": ["ramp", "leash"], "trailer": true,
		"brief": "Too much for the jeep alone — trailer up and pack the gear.",
	},
	{
		"title": "Level 12 — Grand Convoy",
		"vehicle": "truck", "deliver": ["wombat", "fox", "tortoise", "goat", "parrot"],
		"equipment": ["gloves", "ramp", "leash"], "trailer": true,
		"route": [
			{"type": "fuel", "x": 850.0},
			{"type": "food", "x": 1300.0},
			{"type": "vet", "x": 1700.0},
			{"type": "sanctuary", "x": 2050.0},
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
