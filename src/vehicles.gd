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
#   ride          — how much of each terrain jolt reaches the passengers. <1 is a
#                   gentler ride (the truck soaks up bumps), >1 is harsher (the
#                   trike rattles). This is the vehicle's legible comfort quality
#                   (milestone 6): a bigger vehicle is a genuinely calmer ride, so
#                   a fragile or timid load has a reason to want one.
#   ride_label    — one player-facing word for that quality, shown in the brief
#   colour        — body colour
#   body_w/body_h — body box size in local pixels
#   wheel_r       — wheel radius
#   wheel_dx      — half the distance between the two wheels
const DATA := {
	"bicycle": {
		"name": "Tuk-Tuk", "capacity": 2, "shape": "tuktuk",
		"max_speed": 205.0, "acceleration": 185.0,
		"start_fuel": 100.0, "fuel_per_px": 0.0055, "load_ref": 24.0,
		"ride": 1.18, "ride_label": "bumpy",
		"colour": "#3f9d8c", "body_w": 64.0, "body_h": 22.0,
		"wheel_r": 13.0, "wheel_dx": 27.0,
	},
	"jeep": {
		"name": "Jeep", "capacity": 4, "shape": "jeep",
		"max_speed": 260.0, "acceleration": 150.0,
		"start_fuel": 100.0, "fuel_per_px": 0.006, "load_ref": 44.0,
		"ride": 1.0, "ride_label": "steady",
		"colour": "#d9824b", "body_w": 96.0, "body_h": 32.0,
		"wheel_r": 16.0, "wheel_dx": 30.0,
	},
	"truck": {
		"name": "Truck", "capacity": 7, "shape": "truck",
		"max_speed": 300.0, "acceleration": 112.0,
		"start_fuel": 100.0, "fuel_per_px": 0.007, "load_ref": 95.0,
		"ride": 0.78, "ride_label": "smooth",
		"colour": "#8a6d4a", "body_w": 144.0, "body_h": 42.0,
		"wheel_r": 19.0, "wheel_dx": 46.0,
	},
}


static func get_data(id: String) -> Dictionary:
	return DATA.get(id, DATA["jeep"])


static func display_name(id: String) -> String:
	return get_data(id).get("name", id)
