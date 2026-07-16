extends Control

# Mission preparation screen. The player loads the required animals, adds any
# gear, and departs once the arrangement is valid — capacity respected,
# incompatible animals separated by a cage, sly animals handled with gloves.

const TEXT_DARK := Color("#2c3327")
const OK_GREEN := Color("#2f7d4f")
const WARN_RED := Color("#b4472e")

var level := {}
var capacity := 0
var trailer_attached := false
var loaded := {}       # animal_id -> bool
var equipped := {}     # equipment_id -> bool

var capacity_label: Label
var status_label: Label
var depart_button: Button


func _ready() -> void:
	level = Levels.get_level(GameState.current_level)
	_build_prep()
	_refresh()


func _make_root_column() -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
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
	trailer_attached = false
	for id in level["deliver"]:
		loaded[id] = false
	for eq in level["equipment"]:
		equipped[eq] = false

	var veh: Dictionary = Vehicles.get_data(level["vehicle"])
	capacity = int(veh["capacity"])

	# Row heights scale down as a level gets busier, so even the fullest loadout
	# (five animals + equipment + trailer) fits on one screen without scrolling.
	var rows: int = level["deliver"].size() + level["equipment"].size() + (1 if level.get("trailer", false) else 0)
	var animal_h := 84 if rows <= 4 else (72 if rows <= 6 else 60)
	var gear_h := 76 if rows <= 4 else (64 if rows <= 6 else 54)

	var column := _make_root_column()
	_add_label(column, level["title"], 28)
	_add_label(column, level["brief"], 17)
	_add_label(column, "Vehicle: %s  ·  %d slots  ·  top speed %d" % [veh["name"], capacity, int(veh["max_speed"])], 17)
	capacity_label = _add_label(column, "", 20)

	_add_label(column, "— LOAD THE ANIMALS —", 16)
	for id in level["deliver"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var swatch := ColorRect.new()
		swatch.color = Color(Animals.get_data(id).get("colour", "#7d6f63"))
		swatch.custom_minimum_size = Vector2(52, animal_h)
		row.add_child(swatch)
		var btn := Button.new()
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(0, animal_h)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 19)
		btn.text = _animal_button_text(id, false)
		btn.toggled.connect(_on_animal_toggled.bind(id, btn))
		row.add_child(btn)
		column.add_child(row)

	if not level["equipment"].is_empty() or level.get("trailer", false):
		_add_label(column, "— PACK GEAR —", 16)
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 8)
		column.add_child(grid)
		for eq in level["equipment"]:
			var btn := Button.new()
			btn.toggle_mode = true
			btn.custom_minimum_size = Vector2(0, gear_h)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.add_theme_font_size_override("font_size", 19)
			btn.text = _equip_button_text(eq, false)
			btn.toggled.connect(_on_equip_toggled.bind(eq, btn))
			grid.add_child(btn)
		if level.get("trailer", false):
			var tbtn := Button.new()
			tbtn.toggle_mode = true
			tbtn.custom_minimum_size = Vector2(0, gear_h)
			tbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tbtn.add_theme_font_size_override("font_size", 19)
			tbtn.text = _trailer_button_text(false)
			tbtn.toggled.connect(_on_trailer_toggled.bind(tbtn))
			grid.add_child(tbtn)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	status_label = _add_label(column, "", 19)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	column.add_child(buttons)

	var back_button := Button.new()
	back_button.custom_minimum_size = Vector2(0, 96)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.text = "← Levels"
	back_button.pressed.connect(_on_back)
	buttons.add_child(back_button)

	depart_button = Button.new()
	depart_button.custom_minimum_size = Vector2(0, 96)
	depart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	depart_button.add_theme_font_size_override("font_size", 28)
	depart_button.text = "DEPART"
	depart_button.pressed.connect(_on_depart)
	buttons.add_child(depart_button)


func _animal_button_text(id: String, is_loaded: bool) -> String:
	var data: Dictionary = Animals.get_data(id)
	var mark := "[✓] " if is_loaded else "[  ] "
	return "%s%s  ·  size %d, %dkg, %s" % [
		mark, data["name"], data["size"], int(data["weight"]), data["temperament"]]


func _equip_button_text(eq: String, is_on: bool) -> String:
	var mark := "[✓] " if is_on else "[  ] "
	return "%s%s" % [mark, Levels.equipment_name(eq)]


func _trailer_button_text(is_on: bool) -> String:
	var mark := "[✓] " if is_on else "[  ] "
	return "%sTrailer  ·  +%d slots" % [mark, GameState.TRAILER_CAPACITY]


func _on_animal_toggled(pressed: bool, id: String, btn: Button) -> void:
	loaded[id] = pressed
	btn.text = _animal_button_text(id, pressed)
	_refresh()


func _on_equip_toggled(pressed: bool, eq: String, btn: Button) -> void:
	equipped[eq] = pressed
	btn.text = _equip_button_text(eq, pressed)
	_refresh()


func _on_trailer_toggled(pressed: bool, btn: Button) -> void:
	trailer_attached = pressed
	btn.text = _trailer_button_text(pressed)
	_refresh()


func _effective_capacity() -> int:
	return capacity + (GameState.TRAILER_CAPACITY if trailer_attached else 0)


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
	if size > _effective_capacity():
		return {"ok": false, "reason": "Over capacity: %d / %d — try a trailer." % [size, _effective_capacity()]}

	for id in animals:
		for other in Animals.get_data(id).get("incompatible", []):
			if loaded.get(other, false) and not equipped.get("divided_cage", false):
				return {"ok": false, "reason": "%s and %s will squabble — add a divided cage." % [
					Animals.display_name(id), Animals.display_name(other)]}

	for id in animals:
		for req in Animals.get_data(id).get("requires", []):
			if not equipped.get(req, false):
				return {"ok": false, "reason": "The %s needs %s aboard." % [
					Animals.display_name(id), Levels.equipment_name(req)]}

	return {"ok": true, "reason": "Ready to depart!"}


func _refresh() -> void:
	var size := 0
	var weight := 0
	for id in _loaded_animals():
		size += int(Animals.get_data(id)["size"])
		weight += int(Animals.get_data(id)["weight"])
	capacity_label.text = "Load: %d / %d slots  ·  %d kg cargo" % [size, _effective_capacity(), weight]

	var result := _validate()
	status_label.text = result["reason"]
	status_label.add_theme_color_override("font_color", OK_GREEN if result["ok"] else WARN_RED)
	depart_button.disabled = not result["ok"]


func _on_depart() -> void:
	GameState.set_loadout(_loaded_animals(), _equipped_gear(), trailer_attached)
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://src/level_select.tscn")
