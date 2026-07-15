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
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	_add_label(column, "FAUNAVIA", 38)
	_add_label(column, "Wildlife Rescue — pick a mission", 20)
	_add_label(column, "★ %d / %d stars" % [GameState.total_stars(), Levels.count() * 3], 22, STAR_GOLD)

	if GameState.last_earned >= 0:
		_add_label(column, "Last rescue: %s earned!" % _stars_str(GameState.last_earned), 20, STAR_GOLD)
		GameState.last_earned = -1

	if GameState.all_complete():
		_add_label(column, "Every animal rescued — replay any level for three stars!", 19)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)

	for i in Levels.count():
		var unlocked := GameState.is_unlocked(i)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 92)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 22)
		btn.disabled = not unlocked
		var lvl: Dictionary = Levels.get_level(i)
		if unlocked:
			btn.text = "%s\n%s" % [lvl["title"], _stars_str(int(GameState.stars[i]))]
			btn.pressed.connect(_on_level_chosen.bind(i))
		else:
			btn.text = "%s\n🔒 Locked" % lvl["title"]
		list.add_child(btn)

	var reset := Button.new()
	reset.custom_minimum_size = Vector2(0, 70)
	reset.add_theme_font_size_override("font_size", 18)
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
