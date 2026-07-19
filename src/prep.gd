extends Control

# Mission brief. Every current level has exactly one valid loadout — the required
# animals, the gear their traits demand, and a trailer when they overflow the
# vehicle — so there is no real choice to make. Rather than force the player to
# click that one answer back to the game (validation, not gameplay), we auto-load
# the manifest and show it as a brief. The brief is a *picture*: the actual rig the
# player is about to drive (rig_view.gd), the passengers aboard it, each named with
# the one personality quirk that tells you how to drive for it. Raw slots/kg are
# gone — they meant nothing to a player; the vehicle choice and the trailer are the
# capacity story, told by the image. A genuine prep *choice* returns only when a
# level offers two valid plans with a real trade-off (the route chooser below).

const TEXT_DARK := Color("#2c3327")
const MUTED := Color("#6b7363")
const OK_GREEN := Color("#2f7d4f")
const CHIP_BG := Color("#e7e3d2")
const GEAR_BG := Color("#d9d3bd")

var level := {}
var animals: Array[String] = []
var equipment: Array[String] = []
var trailer := false

# Route choice (only on levels that offer one; see levels.gd "routes").
var route_options: Array = []
var chosen_route := 0
var route_buttons: Array[Button] = []


func _ready() -> void:
	level = Levels.get_level(GameState.current_level)
	animals.assign(level["deliver"])
	equipment.assign(level["equipment"])
	trailer = level.get("trailer", false)
	route_options = level.get("routes", [])
	_build_brief()


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

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 26)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	_add_label(column, level["title"], 27)
	_add_label(column, level["brief"], 16, MUTED)
	_add_label(column, "%s  ·  %s ride" % [veh["name"], veh.get("ride_label", "steady")], 15, MUTED)

	# The hero: the actual rig, loaded, on the road. Absorbs the vertical slack so it
	# reads big — the picture is the point.
	var rig: Control = preload("res://src/rig_view.gd").new()
	rig.setup(level["vehicle"], animals, equipment, trailer)
	rig.custom_minimum_size = Vector2(0, 360)
	column.add_child(rig)

	# Who's aboard — a portrait thumbnail, the name, and the single quirk that tells
	# you how to drive for it. This replaces the old size/kg manifest rows.
	for id in animals:
		column.add_child(_passenger_chip(id))

	# What's packed — compact chips, no explanatory paragraphs. The personalities
	# above already say why each item rides along.
	if not equipment.is_empty() or trailer:
		var gear := HFlowContainer.new()
		gear.add_theme_constant_override("h_separation", 8)
		gear.add_theme_constant_override("v_separation", 6)
		column.add_child(gear)
		for eq in equipment:
			gear.add_child(_gear_chip(Levels.equipment_name(eq)))
		if trailer:
			gear.add_child(_gear_chip("Trailer"))

	if not route_options.is_empty():
		_build_route_chooser(column)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	column.add_child(buttons)

	var back_button := Button.new()
	back_button.custom_minimum_size = Vector2(0, 92)
	back_button.add_theme_font_size_override("font_size", 22)
	back_button.text = "< Levels"
	back_button.pressed.connect(_on_back)
	buttons.add_child(back_button)

	var depart_button := Button.new()
	depart_button.custom_minimum_size = Vector2(0, 92)
	depart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	depart_button.add_theme_font_size_override("font_size", 28)
	depart_button.text = "DEPART"
	depart_button.pressed.connect(_on_depart)
	buttons.add_child(depart_button)


func _passenger_chip(id: String) -> Control:
	var data: Dictionary = Animals.get_data(id)
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = CHIP_BG
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 8
	sb.content_margin_right = 12
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	var portrait := TextureRect.new()
	var path := "res://assets/animals/%s_content.png" % id
	if ResourceLoader.exists(path):
		portrait.texture = load(path)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(46, 46)
	row.add_child(portrait)

	var text := VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text)
	_add_label(text, data["name"], 18, TEXT_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	_add_label(text, Animals.personality(id), 14, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	return panel


func _gear_chip(name: String) -> Control:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = GEAR_BG
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", sb)
	var label := Label.new()
	label.text = name
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", TEXT_DARK)
	panel.add_child(label)
	return panel


func _build_route_chooser(column: Node) -> void:
	# The one place prep is a real decision: two valid routes with a trade-off the
	# player weighs against the passengers shown above (a timid animal favours the
	# gentle road; a confident driver can gamble on the shortcut).
	_add_label(column, "— CHOOSE THE ROUTE —", 15, MUTED)
	var group := ButtonGroup.new()
	route_buttons.clear()
	for i in route_options.size():
		var btn := Button.new()
		btn.toggle_mode = true
		btn.button_group = group
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 84)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 16)
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
		var mark := "(o)  " if i == chosen_route else "( )  "
		route_buttons[i].text = "%s%s — %s" % [mark, opt["label"], opt["desc"]]


func _on_depart() -> void:
	Audio.play("tap", -8.0)
	GameState.set_loadout(animals, equipment, trailer)
	GameState.set_route(route_options[chosen_route] if not route_options.is_empty() else {})
	get_tree().change_scene_to_file("res://src/main.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://src/level_select.tscn")
