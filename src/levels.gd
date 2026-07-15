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
		"title": "Level 2 — Two Aboard",
		"vehicle": "jeep", "deliver": ["wombat", "rabbit"], "equipment": [],
		"brief": "The jeep can carry the wombat and rabbit together.",
	},
	{
		"title": "Level 3 — Handle With Care",
		"vehicle": "bicycle", "deliver": ["fox"], "equipment": ["gloves"],
		"brief": "The fox is sly. Bring gloves before you load it.",
	},
	{
		"title": "Level 4 — Keep the Peace",
		"vehicle": "jeep", "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"brief": "Fox and rabbit together needs a divided cage — and the fox still needs gloves.",
	},
	{
		"title": "Level 5 — Full Load",
		"vehicle": "truck", "deliver": ["wombat", "rabbit", "fox"],
		"equipment": ["divided_cage", "gloves"], "trailer": true,
		"brief": "The truck hauls all three at once. Pack the right gear.",
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
