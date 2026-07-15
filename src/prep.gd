extends Control

# Mission preparation screen. The player loads the required animals, adds any
# gear, and departs once the arrangement is valid — capacity respected,
# incompatible animals separated by a cage, sly animals handled with gloves.

const TEXT_DARK := Color("#2c3327")
const OK_GREEN := Color("#2f7d4f")
const WARN_RED := Color("#b4472e")

var level := {}
var capacity := 0
var loaded := {}       # animal_id -> bool
var equipped := {}     # equipment_id -> bool

var capacity_label: Label
var status_label: Label
var depart_button: Button


func _ready() -> void:
	if GameState.campaign_done:
		_build_complete()
	else:
		level = Levels.get_level(GameState.current_level)
		_build_prep()
		_refresh()


func _make_root_column() -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 48)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	margin.add_child(column)
	return column


func _add_label(parent: Node, text: String, size: int, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_DARK)
	parent.add_child(label)
	return label


func _build_prep() -> void:
	loaded.clear()
	equipped.clear()
	for id in level["deliver"]:
		loaded[id] = false
	for eq in level["equipment"]:
		equipped[eq] = false

	var veh: Dictionary = Vehicles.get_data(level["vehicle"])
	capacity = int(veh["capacity"])

	var column := _make_root_column()
	_add_label(column, level["title"], 34)
	_add_label(column, level["brief"], 22)
	_add_label(column, "Vehicle: %s  ·  %d slots  ·  top speed %d" % [veh["name"], capacity, int(veh["max_speed"])], 20)
	capacity_label = _add_label(column, "", 22)
	_add_label(column, "Heavier cargo drinks more fuel — the mid-route pickup matters.", 17)

	_add_label(column, "— LOAD THE ANIMALS —", 20)
	for id in level["deliver"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		var swatch := ColorRect.new()
		swatch.color = Color(Animals.get_data(id).get("colour", "#7d6f63"))
		swatch.custom_minimum_size = Vector2(72, 96)
		row.add_child(swatch)
		var btn := Button.new()
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(0, 96)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 24)
		btn.text = _animal_button_text(id, false)
		btn.toggled.connect(_on_animal_toggled.bind(id, btn))
		row.add_child(btn)
		column.add_child(row)

	if not level["equipment"].is_empty():
		_add_label(column, "— PACK EQUIPMENT —", 20)
		for eq in level["equipment"]:
			var btn := Button.new()
			btn.toggle_mode = true
			btn.custom_minimum_size = Vector2(0, 88)
			btn.add_theme_font_size_override("font_size", 24)
			btn.text = _equip_button_text(eq, false)
			btn.toggled.connect(_on_equip_toggled.bind(eq, btn))
			column.add_child(btn)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	status_label = _add_label(column, "", 22)

	depart_button = Button.new()
	depart_button.custom_minimum_size = Vector2(0, 120)
	depart_button.add_theme_font_size_override("font_size", 30)
	depart_button.text = "DEPART"
	depart_button.pressed.connect(_on_depart)
	column.add_child(depart_button)


func _build_complete() -> void:
	var column := _make_root_column()
	var top := Control.new()
	top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(top)
	_add_label(column, "All five rescues complete!", 34)
	_add_label(column, "Every animal reached the sanctuary. The driving toy and passenger loop hold up across the whole run.", 22)
	var bottom := Control.new()
	bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(bottom)
	var again := Button.new()
	again.custom_minimum_size = Vector2(0, 120)
	again.add_theme_font_size_override("font_size", 30)
	again.text = "PLAY AGAIN"
	again.pressed.connect(_on_play_again)
	column.add_child(again)


func _animal_button_text(id: String, is_loaded: bool) -> String:
	var data: Dictionary = Animals.get_data(id)
	var mark := "[✓] " if is_loaded else "[  ] "
	return "%s%s  ·  size %d, %dkg, %s" % [
		mark, data["name"], data["size"], int(data["weight"]), data["temperament"]]


func _equip_button_text(eq: String, is_on: bool) -> String:
	var mark := "[✓] " if is_on else "[  ] "
	return "%s%s" % [mark, Levels.equipment_name(eq)]


func _on_animal_toggled(pressed: bool, id: String, btn: Button) -> void:
	loaded[id] = pressed
	btn.text = _animal_button_text(id, pressed)
	_refresh()


func _on_equip_toggled(pressed: bool, eq: String, btn: Button) -> void:
	equipped[eq] = pressed
	btn.text = _equip_button_text(eq, pressed)
	_refresh()


func _loaded_animals() -> Array[String]:
	var out: Array[String] = []
	for id in level["deliver"]:
		if loaded.get(id, false):
			out.append(id)
	return out


func _equipped_gear() -> Array[String]:
	var out: Array[String] = []
	for eq in level["equipment"]:
		if equipped.get(eq, false):
			out.append(eq)
	return out


func _validate() -> Dictionary:
	var animals := _loaded_animals()

	for id in level["deliver"]:
		if not loaded.get(id, false):
			return {"ok": false, "reason": "%s still needs loading." % Animals.display_name(id)}

	var size := 0
	for id in animals:
		size += int(Animals.get_data(id)["size"])
	if size > capacity:
		return {"ok": false, "reason": "Over capacity: %d / %d." % [size, capacity]}

	for id in animals:
		for other in Animals.get_data(id).get("incompatible", []):
			if loaded.get(other, false) and not equipped.get("divided_cage", false):
				return {"ok": false, "reason": "%s and %s will squabble — add a divided cage." % [
					Animals.display_name(id), Animals.display_name(other)]}

	for id in animals:
		if Animals.get_data(id).get("needs_gloves", false) and not equipped.get("gloves", false):
			return {"ok": false, "reason": "The %s is sly — pack gloves first." % Animals.display_name(id)}

	return {"ok": true, "reason": "Ready to depart!"}


func _refresh() -> void:
	var size := 0
	var weight := 0
	for id in _loaded_animals():
		size += int(Animals.get_data(id)["size"])
		weight += int(Animals.get_data(id)["weight"])
	capacity_label.text = "Load: %d / %d slots  ·  %d kg cargo" % [size, capacity, weight]

	var result := _validate()
	status_label.text = result["reason"]
	status_label.add_theme_color_override("font_color", OK_GREEN if result["ok"] else WARN_RED)
	depart_button.disabled = not result["ok"]


func _on_depart() -> void:
	GameState.set_loadout(_loaded_animals(), _equipped_gear())
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_play_again() -> void:
	GameState.restart()
	get_tree().change_scene_to_file("res://src/prep.tscn")
