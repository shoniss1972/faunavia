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
#   capacity  — total animal size the vehicle can hold
#   deliver   — animal ids that must be aboard to depart (the mission cargo)
#   equipment — gear the player may add in prep (each id is a toggle)
const DATA := [
	{
		"title": "Level 1 — First Rescue",
		"capacity": 3, "deliver": ["wombat"], "equipment": [],
		"brief": "Take the wombat to the sanctuary.",
	},
	{
		"title": "Level 2 — Two Aboard",
		"capacity": 3, "deliver": ["wombat", "rabbit"], "equipment": [],
		"brief": "The wombat and rabbit both need a lift.",
	},
	{
		"title": "Level 3 — Handle With Care",
		"capacity": 2, "deliver": ["fox"], "equipment": ["gloves"],
		"brief": "The fox is sly. Bring gloves before you load it.",
	},
	{
		"title": "Level 4 — Keep the Peace",
		"capacity": 4, "deliver": ["fox", "rabbit"],
		"equipment": ["divided_cage", "gloves"],
		"brief": "Fox and rabbit together needs a divided cage — and the fox still needs gloves.",
	},
	{
		"title": "Level 5 — Full Load",
		"capacity": 5, "deliver": ["wombat", "rabbit", "fox"],
		"equipment": ["divided_cage", "gloves"],
		"brief": "All three, all at once. Pack the right gear.",
	},
]

const EQUIPMENT_NAMES := {
	"divided_cage": "Divided Cage",
	"gloves": "Gloves",
}


static func count() -> int:
	return DATA.size()


static func get_level(index: int) -> Dictionary:
	if index < 0 or index >= DATA.size():
		return {}
	return DATA[index]


static func equipment_name(id: String) -> String:
	return EQUIPMENT_NAMES.get(id, id)
