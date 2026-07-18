extends Control

# Mission brief. Every current level has exactly one valid loadout — the required
# animals, the gear their traits demand, and a trailer when they overflow the
# vehicle — so there is no real choice to make. Rather than force the player to
# click that one answer back to the game (validation, not gameplay), we auto-load
# the manifest and show it as a brief: who rides, what is packed and why, then
# DEPART. A genuine prep *choice* returns only when a level offers two valid plans
# with a real trade-off (see TODO milestone 1).

const TEXT_DARK := Color("#2c3327")
const MUTED := Color("#6b7363")
const OK_GREEN := Color("#2f7d4f")

var level := {}
var animals: Array[String] = []
var equipment: Array[String] = []
var trailer := false
var capacity := 0

# Route choice (only on levels that offer one; see levels.gd "routes").
var route_options: Array = []
var chosen_route := 0
var route_buttons: Array[Button] = []


func _ready() -> void:
	level = Levels.get_level(GameState.current_level)
	_solve_loadout()
	_build_brief()


func _solve_loadout() -> void:
	# The manifest is fixed: carry everything the mission asks for, pack every
	# listed gear (each is required by an animal's trait or the compat rule), and
	# hitch the trailer when the level flags it.
	animals.assign(level["deliver"])
	equipment.assign(level["equipment"])
	trailer = level.get("trailer", false)
	capacity = int(Vehicles.get_data(level["vehicle"])["capacity"])
	route_options = level.get("routes", [])


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


func _add_label(parent: Node, text: String, size: int, colour := TEXT_DARK, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", colour)
	parent.add_child(label)
	return label


func _build_brief() -> void:
	var veh: Dictionary = Vehicles.get_data(level["vehicle"])
	var eff_cap := capacity + (GameState.TRAILER_CAPACITY if trailer else 0)

	var size := 0
	var weight := 0
	for id in animals:
		size += int(Animals.get_data(id)["size"])
		weight += int(Animals.get_data(id)["weight"])

	# Rows shrink as the manifest grows so even the fullest brief fits without
	# scrolling (scroll-over-buttons is unreliable on mobile web).
	var rows := animals.size() + equipment.size() + (1 if trailer else 0)
	var row_h := 64 if rows <= 4 else (54 if rows <= 6 else 46)

	var column := _make_root_column()
	_add_label(column, level["title"], 28)
	_add_label(column, level["brief"], 17, MUTED)
	_add_label(column, "%s  ·  %d slots  ·  %s ride" % [veh["name"], eff_cap, veh.get("ride_label", "steady")], 16, MUTED)

	_add_label(column, "— ABOARD —", 16, MUTED)
	for id in animals:
		_add_manifest_row(column, Color(Animals.get_data(id).get("colour", "#7d6f63")), _animal_line(id), row_h)

	if not equipment.is_empty() or trailer:
		_add_label(column, "— PACKED —", 16, MUTED)
		for eq in equipment:
			_add_manifest_row(column, Color("#8a8f84"), _gear_line(eq), row_h)
		if trailer:
			_add_manifest_row(column, Color("#8a8f84"),
				"Trailer  ·  +%d slots — the load won't fit without it." % GameState.TRAILER_CAPACITY, row_h)

	if not route_options.is_empty():
		_build_route_chooser(column)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	_add_label(column, "Load: %d / %d slots  ·  %d kg cargo" % [size, eff_cap, weight], 18, OK_GREEN)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	column.add_child(buttons)

	var back_button := Button.new()
	back_button.custom_minimum_size = Vector2(0, 96)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.text = "← Levels"
	back_button.pressed.connect(_on_back)
	buttons.add_child(back_button)

	var depart_button := Button.new()
	depart_button.custom_minimum_size = Vector2(0, 96)
	depart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	depart_button.add_theme_font_size_override("font_size", 28)
	depart_button.text = "DEPART"
	depart_button.pressed.connect(_on_depart)
	buttons.add_child(depart_button)


func _build_route_chooser(column: Node) -> void:
	# The one place prep is a real decision: two valid routes with a trade-off the
	# player weighs against the passengers shown above (a timid animal favours the
	# gentle road; a confident driver can gamble on the shortcut).
	_add_label(column, "— CHOOSE THE ROUTE —", 16, MUTED)
	var group := ButtonGroup.new()
	route_buttons.clear()
	for i in route_options.size():
		var btn := Button.new()
		btn.toggle_mode = true
		btn.button_group = group
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 92)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 17)
		btn.toggled.connect(_on_route_toggled.bind(i))
		column.add_child(btn)
		route_buttons.append(btn)
	route_buttons[chosen_route].button_pressed = true
	_refresh_route_buttons()


func _on_route_toggled(pressed: bool, index: int) -> void:
	if pressed:
		Audio.play("tap", -12.0)
		chosen_route = index
		_refresh_route_buttons()


func _refresh_route_buttons() -> void:
	for i in route_buttons.size():
		var opt: Dictionary = route_options[i]
		var mark := "●  " if i == chosen_route else "○  "
		route_buttons[i].text = "%s%s — %s" % [mark, opt["label"], opt["desc"]]


func _add_manifest_row(parent: Node, swatch_colour: Color, text: String, height: int) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.custom_minimum_size = Vector2(0, height)
	var swatch := ColorRect.new()
	swatch.color = swatch_colour
	swatch.custom_minimum_size = Vector2(48, height)
	row.add_child(swatch)
	var label := _add_label(row, text, 18, TEXT_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(row)


func _animal_line(id: String) -> String:
	# Lead with the memorable trait (milestone 4): the personality phrase tells the
	# player how to treat this passenger; size/weight stay for capacity and handling.
	var data: Dictionary = Animals.get_data(id)
	return "%s  ·  %s\nsize %d, %dkg" % [data["name"], Animals.personality(id), data["size"], int(data["weight"])]


func _gear_line(eq: String) -> String:
	return "%s — %s" % [Levels.equipment_name(eq), _gear_reason(eq)]


func _gear_reason(eq: String) -> String:
	# Explain why each item rides along, drawn from the same traits that made it
	# mandatory — so the brief teaches the animal quirks the old checklist hid.
	if eq == "divided_cage":
		for id in animals:
			for other in Animals.get_data(id).get("incompatible", []):
				if other in animals:
					return "keeps %s and %s from squabbling." % [
						Animals.display_name(id), Animals.display_name(other)]
		return "keeps quarrelsome passengers apart."
	for id in animals:
		if eq in Animals.get_data(id).get("requires", []):
			match eq:
				"gloves": return "the %s is sly and needs careful handling." % Animals.display_name(id)
				"ramp": return "the %s can't clamber aboard on its own." % Animals.display_name(id)
				"leash": return "the %s wanders off without it." % Animals.display_name(id)
	return "needed for this rescue."


func _on_depart() -> void:
	Audio.play("tap", -8.0)
	GameState.set_loadout(animals, equipment, trailer)
	GameState.set_route(route_options[chosen_route] if not route_options.is_empty() else {})
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://src/level_select.tscn")
