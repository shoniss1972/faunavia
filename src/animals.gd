class_name Animals
extends RefCounted

# The six rescue animals. Kept as plain data so levels, the prep screen, and the
# driving scene all read the same traits without duplicating them.
#   size         — cargo slots the animal occupies against vehicle capacity
#   weight       — contributes to the vehicle's handling load (kg)
#   temperament  — flavour word shown in prep
#   colour       — fur/feather colour drawn in the cab
#   incompatible — ids this animal cannot ride beside without a divided cage
#   requires     — equipment ids that must be aboard to carry this animal
const DATA := {
	"wombat": {
		"name": "Wombat", "size": 2, "weight": 26.0, "temperament": "placid",
		"colour": "#7d6f63", "incompatible": [], "requires": [],
	},
	"rabbit": {
		"name": "Rabbit", "size": 1, "weight": 3.0, "temperament": "timid",
		"colour": "#cbb89d", "incompatible": ["fox", "parrot"], "requires": [],
	},
	"fox": {
		"name": "Fox", "size": 2, "weight": 7.0, "temperament": "sly",
		"colour": "#c8743a", "incompatible": ["rabbit"], "requires": ["gloves"],
	},
	"tortoise": {
		"name": "Tortoise", "size": 3, "weight": 40.0, "temperament": "slow",
		"colour": "#6f7d52", "incompatible": [], "requires": ["ramp"],
	},
	"parrot": {
		"name": "Parrot", "size": 1, "weight": 1.0, "temperament": "loud",
		"colour": "#3f9d5a", "incompatible": ["rabbit"], "requires": [],
	},
	"goat": {
		"name": "Goat", "size": 2, "weight": 14.0, "temperament": "stubborn",
		"colour": "#b0a89a", "incompatible": [], "requires": ["leash"],
	},
}


static func get_data(id: String) -> Dictionary:
	return DATA.get(id, {})


static func display_name(id: String) -> String:
	return DATA.get(id, {}).get("name", id)
