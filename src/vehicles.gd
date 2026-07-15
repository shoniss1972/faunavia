class_name Vehicles
extends RefCounted

# The three vehicles that anchor progression. Each bundles handling stats, fuel
# behaviour, and a few draw dimensions so the driving scene can render and tune
# any vehicle from data alone.
#   capacity      — animal size slots the vehicle can hold (before a trailer)
#   max_speed     — top speed
#   acceleration  — how fast it reaches top speed
#   start_fuel    — fuel at the start of a run (0..100)
#   fuel_per_px   — fuel burned per pixel at zero load
#   load_ref      — cargo weight (kg) that counts as a full handling load
#   colour        — body colour
#   body_w/body_h — body box size in local pixels
#   wheel_r       — wheel radius
#   wheel_dx      — half the distance between the two wheels
const DATA := {
	"bicycle": {
		"name": "Cargo Trike", "capacity": 2,
		"max_speed": 205.0, "acceleration": 185.0,
		"start_fuel": 52.0, "fuel_per_px": 0.011, "load_ref": 24.0,
		"colour": "#5a7d8c", "body_w": 64.0, "body_h": 22.0,
		"wheel_r": 13.0, "wheel_dx": 27.0,
	},
	"jeep": {
		"name": "Jeep", "capacity": 4,
		"max_speed": 260.0, "acceleration": 150.0,
		"start_fuel": 60.0, "fuel_per_px": 0.012, "load_ref": 44.0,
		"colour": "#d9824b", "body_w": 96.0, "body_h": 32.0,
		"wheel_r": 16.0, "wheel_dx": 30.0,
	},
	"truck": {
		"name": "Truck", "capacity": 7,
		"max_speed": 300.0, "acceleration": 112.0,
		"start_fuel": 88.0, "fuel_per_px": 0.015, "load_ref": 95.0,
		"colour": "#8a6d4a", "body_w": 144.0, "body_h": 42.0,
		"wheel_r": 19.0, "wheel_dx": 46.0,
	},
}


static func get_data(id: String) -> Dictionary:
	return DATA.get(id, DATA["jeep"])


static func display_name(id: String) -> String:
	return get_data(id).get("name", id)
