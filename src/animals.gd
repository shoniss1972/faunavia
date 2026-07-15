class_name Animals
extends RefCounted

# The three starter animals. Kept as plain data so levels, the prep screen,
# and the driving scene all read the same traits without duplicating them.
#   size        — cargo slots the animal occupies against vehicle capacity
#   weight      — contributes to the vehicle's handling load
#   temperament — flavour, and drives the equipment rule (sly animals need gloves)
#   colour      — fur colour drawn in the cab
#   incompatible — ids this animal cannot ride beside without a divided cage
#   needs_gloves — must have gloves equipment aboard to be carried
const DATA := {
	"wombat": {
		"name": "Wombat", "size": 2, "weight": 26.0, "temperament": "placid",
		"colour": "#7d6f63", "incompatible": [], "needs_gloves": false,
	},
	"rabbit": {
		"name": "Rabbit", "size": 1, "weight": 3.0, "temperament": "timid",
		"colour": "#cbb89d", "incompatible": ["fox"], "needs_gloves": false,
	},
	"fox": {
		"name": "Fox", "size": 2, "weight": 7.0, "temperament": "sly",
		"colour": "#c8743a", "incompatible": ["rabbit"], "needs_gloves": true,
	},
}


static func get_data(id: String) -> Dictionary:
	return DATA.get(id, {})


static func display_name(id: String) -> String:
	return DATA.get(id, {}).get("name", id)
