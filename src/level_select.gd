extends Control

# Level select. Shows every mission with the stars earned, locks levels until the
# previous one is delivered, and is the game's entry point and hub between runs.

const TEXT_DARK := Color("#2c3327")
const STAR_GOLD := Color("#e8b84a")
const LOCK_GREY := Color("#8a8f84")


func _ready() -> void:
	_build()


func _add_label(parent: Node, text: String, size: int, colour := TEXT_DARK) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", colour)
	parent.add_child(label)
	return label


func _build() -> void:
	# A fixed grid that fits every level on one screen — no scrolling, which is
	# unreliable over buttons on mobile web (iOS in particular).
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	_add_label(column, "Wildlife Rescue", 30)
	_add_label(column, "★ %d / %d    ·    deliver · keep them calm · thrill them" % [
		GameState.total_stars(), Levels.count() * 3], 17, STAR_GOLD)

	if GameState.last_earned >= 0:
		_add_label(column, "Last rescue: %s earned!" % _stars_str(GameState.last_earned), 18, STAR_GOLD)
		GameState.last_earned = -1

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	column.add_child(grid)

	for i in Levels.count():
		var unlocked := GameState.is_unlocked(i)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 128)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_font_size_override("font_size", 19)
		btn.disabled = not unlocked
		var lvl: Dictionary = Levels.get_level(i)
		if unlocked:
			btn.text = "%s\n%s" % [lvl["title"], _stars_str(int(GameState.stars[i]))]
			btn.pressed.connect(_on_level_chosen.bind(i))
		else:
			# A locked level teases its new wrinkle instead of a bare padlock, so the
			# player has a reason to want the next mission (milestone 7).
			var hook: String = lvl.get("hook", "")
			btn.text = "🔒 %s\n%s" % [lvl["title"], hook] if hook != "" else "%s\n🔒 Locked" % lvl["title"]
		grid.add_child(btn)

	var reset := Button.new()
	reset.custom_minimum_size = Vector2(0, 60)
	reset.add_theme_font_size_override("font_size", 16)
	reset.text = "Reset progress"
	reset.pressed.connect(_on_reset)
	column.add_child(reset)


func _stars_str(n: int) -> String:
	return "★".repeat(n) + "☆".repeat(3 - n)


func _on_level_chosen(index: int) -> void:
	GameState.current_level = index
	get_tree().change_scene_to_file("res://src/prep.tscn")


func _on_reset() -> void:
	GameState.reset_progress()
	get_tree().reload_current_scene()
