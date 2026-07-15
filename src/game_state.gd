extends Node

# Autoloaded singleton. Carries the current level and the loadout chosen on the
# prep screen into the driving scene, and tracks how far the player has reached.

const EQUIPMENT_WEIGHT := {
	"divided_cage": 8.0,
	"gloves": 0.0,
	"ramp": 6.0,
	"leash": 0.0,
}
const TRAILER_CAPACITY := 3        # extra slots a trailer adds
const TRAILER_WEIGHT := 12.0       # the trailer's own handling weight

var current_level := 0
var loadout_animals: Array[String] = []
var loadout_equipment: Array[String] = []
var loadout_trailer := false
var campaign_done := false


func _ready() -> void:
	# A sensible default so the driving scene is runnable on its own before a
	# mission has been prepared (e.g. opened directly in the editor).
	if loadout_animals.is_empty():
		loadout_animals = ["wombat"]


func set_loadout(animals: Array[String], equipment: Array[String], trailer := false) -> void:
	loadout_animals = animals.duplicate()
	loadout_equipment = equipment.duplicate()
	loadout_trailer = trailer


func current_vehicle() -> String:
	return Levels.get_level(current_level).get("vehicle", "jeep")


func total_weight() -> float:
	var w := 0.0
	for id in loadout_animals:
		w += float(Animals.get_data(id).get("weight", 0.0))
	for eq in loadout_equipment:
		w += EQUIPMENT_WEIGHT.get(eq, 0.0)
	if loadout_trailer:
		w += TRAILER_WEIGHT
	return w


func load_factor() -> float:
	# 0 = empty, 1 = at the current vehicle's reference load. A truck shrugs off a
	# load that would overwhelm the trike, because its reference is much higher.
	var load_ref: float = Vehicles.get_data(current_vehicle()).get("load_ref", 42.0)
	return clampf(total_weight() / load_ref, 0.0, 1.0)


func has_more_levels() -> bool:
	return current_level + 1 < Levels.count()


func advance_level() -> void:
	if has_more_levels():
		current_level += 1


func restart() -> void:
	current_level = 0
	loadout_animals = ["wombat"]
	loadout_equipment = []
	loadout_trailer = false
	campaign_done = false
