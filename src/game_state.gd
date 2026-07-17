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
const SAVE_PATH := "user://faunavia_save.cfg"

var current_level := 0
var loadout_animals: Array[String] = []
var loadout_equipment: Array[String] = []
var loadout_trailer := false
# The route chosen in prep on levels that offer a choice; empty for single-route
# levels (the drive then falls back to the level's own terrain fields).
var loadout_route: Dictionary = {}

# Best stars earned per level (0 = not yet completed). Persisted between runs.
var stars: Array = []
var last_earned := -1              # stars from the most recent delivery, for a toast
# Full detail of the most recent run, for the result screen. Rebuilt each
# delivery; not persisted. Shape: {level, earned, total, delivered,
# passengers:[{id,name,arrived,rattled}]}.
var last_result: Dictionary = {}


func _ready() -> void:
	if loadout_animals.is_empty():
		loadout_animals = ["wombat"]
	_load()


func _ensure_stars() -> void:
	while stars.size() < Levels.count():
		stars.append(0)


func is_unlocked(index: int) -> bool:
	# The first level is always open; each later level unlocks once the previous
	# one has been delivered (at least one star).
	if index <= 0:
		return true
	return index < stars.size() and stars[index - 1] >= 1


func record_result(index: int, earned: int, detail: Dictionary = {}) -> void:
	_ensure_stars()
	last_earned = earned
	last_result = detail
	if index >= 0 and index < stars.size():
		stars[index] = maxi(stars[index], earned)
	_save()


func total_stars() -> int:
	# Count only the active campaign; a save from a longer campaign may hold extra
	# trailing entries that should not inflate the "X / max" readout.
	_ensure_stars()
	var t := 0
	for i in Levels.count():
		t += int(stars[i])
	return t


func all_complete() -> bool:
	_ensure_stars()
	for i in Levels.count():
		if int(stars[i]) < 1:
			return false
	return true


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "stars", stars)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		var saved = cfg.get_value("progress", "stars", [])
		stars = (saved as Array).duplicate() if saved is Array else []
	_ensure_stars()


func set_loadout(animals: Array[String], equipment: Array[String], trailer := false) -> void:
	loadout_animals = animals.duplicate()
	loadout_equipment = equipment.duplicate()
	loadout_trailer = trailer


func set_route(route: Dictionary) -> void:
	# Empty clears any route chosen for a previous level.
	loadout_route = route.duplicate(true)


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


func reset_progress() -> void:
	current_level = 0
	loadout_animals = ["wombat"]
	loadout_equipment = []
	loadout_trailer = false
	last_earned = -1
	stars = []
	_ensure_stars()
	_save()
