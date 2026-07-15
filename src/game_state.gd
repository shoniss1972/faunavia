extends Node

# Autoloaded singleton. Carries the current level and the loadout chosen on the
# prep screen into the driving scene, and tracks how far the player has reached.

# Weight (animals + gear) that counts as a fully-laden vehicle, mapped to a 0..1
# handling load. Tuned so the wombat alone is a noticeable but manageable load.
const LOAD_REFERENCE := 42.0
const EQUIPMENT_WEIGHT := {
	"divided_cage": 8.0,
	"gloves": 0.0,
}

var current_level := 0
var loadout_animals: Array[String] = []
var loadout_equipment: Array[String] = []
var campaign_done := false


func _ready() -> void:
	# A sensible default so the driving scene is runnable on its own before a
	# mission has been prepared (e.g. opened directly in the editor).
	if loadout_animals.is_empty():
		loadout_animals = ["wombat"]


func set_loadout(animals: Array[String], equipment: Array[String]) -> void:
	loadout_animals = animals.duplicate()
	loadout_equipment = equipment.duplicate()


func total_weight() -> float:
	var w := 0.0
	for id in loadout_animals:
		w += float(Animals.get_data(id).get("weight", 0.0))
	for eq in loadout_equipment:
		w += EQUIPMENT_WEIGHT.get(eq, 0.0)
	return w


func load_factor() -> float:
	# 0 = empty, 1 = at the reference load. Clamped so overload still tops out.
	return clampf(total_weight() / LOAD_REFERENCE, 0.0, 1.0)


func has_more_levels() -> bool:
	return current_level + 1 < Levels.count()


func advance_level() -> void:
	if has_more_levels():
		current_level += 1


func restart() -> void:
	current_level = 0
	loadout_animals = ["wombat"]
	loadout_equipment = []
	campaign_done = false
