extends Control

# Result screen, shown after every rescue. It replaces the silent jump back to
# the level select: it states the star rating in plain language, shows who
# arrived and who bailed, gives one improvement hint aimed at what actually went
# wrong this run, and offers Retry or a forward step (next mission / levels) with
# a teaser for what comes next. Reads GameState.last_result (see main.gd).

const TEXT_DARK := Color("#2c3327")
const MUTED := Color("#6b7363")
const OK_GREEN := Color("#2f7d4f")
const WARN_AMBER := Color("#b8862e")
const BAD_RED := Color("#b4472e")
const STAR_GOLD := Color("#e8b84a")
const HINT_BG := Color("#e3ead9")

var result: Dictionary = {}
var level_index := 0


func _ready() -> void:
	result = GameState.last_result
	level_index = int(result.get("level", GameState.current_level))
	# This screen supersedes the level-select "Last rescue" toast.
	GameState.last_earned = -1
	_build()


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


func _build() -> void:
	var earned := int(result.get("earned", 0))
	var passengers: Array = result.get("passengers", [])
	# An empty arrival — nobody delivered — is a failed rescue, not a low score.
	# It never advances (even if the level was already unlocked): the only way on
	# is to retry and deliver at least one animal.
	var failed := int(result.get("delivered", 0)) <= 0

	var column := _make_root_column()

	_add_label(column, Levels.get_level(level_index).get("title", "Rescue"), 20, MUTED)
	_add_label(column, "★".repeat(earned) + "☆".repeat(3 - earned), 52, STAR_GOLD)
	_add_label(column, _headline(earned, failed), 26, BAD_RED if failed else TEXT_DARK)

	_add_label(column, "— WHO ARRIVED —", 15, MUTED)
	for p in passengers:
		_add_roster_row(column, p)

	var spacer_a := Control.new()
	spacer_a.custom_minimum_size = Vector2(0, 6)
	column.add_child(spacer_a)

	# Improvement hint, in a soft panel so it reads as the takeaway, not chrome.
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = HINT_BG
	style.set_corner_radius_all(10)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	column.add_child(panel)
	_add_label(panel, _hint(earned, passengers), 18)

	# Credit a lifeline stop when one pulled an arriving animal back from the brink.
	var saved_note := _saved_note()
	if saved_note != "":
		_add_label(column, saved_note, 16, OK_GREEN)

	var teaser := "Deliver at least one animal to move on." if failed else _teaser()
	if teaser != "":
		_add_label(column, teaser, 16, MUTED)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	column.add_child(buttons)

	if failed:
		# A failed rescue offers no way forward — retry is the primary action.
		var to_levels := Button.new()
		to_levels.custom_minimum_size = Vector2(0, 96)
		to_levels.add_theme_font_size_override("font_size", 22)
		to_levels.text = "← Levels"
		to_levels.pressed.connect(_on_levels)
		buttons.add_child(to_levels)

		var retry_primary := Button.new()
		retry_primary.custom_minimum_size = Vector2(0, 96)
		retry_primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		retry_primary.add_theme_font_size_override("font_size", 26)
		retry_primary.text = "↺ Retry"
		retry_primary.pressed.connect(_on_retry)
		buttons.add_child(retry_primary)
		return

	var retry := Button.new()
	retry.custom_minimum_size = Vector2(0, 96)
	retry.add_theme_font_size_override("font_size", 22)
	retry.text = "↺ Retry"
	retry.pressed.connect(_on_retry)
	buttons.add_child(retry)

	var forward := Button.new()
	forward.custom_minimum_size = Vector2(0, 96)
	forward.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	forward.add_theme_font_size_override("font_size", 26)
	if _next_available():
		forward.text = "Next Mission →"
		forward.pressed.connect(_on_next)
	else:
		forward.text = "← Levels"
		forward.pressed.connect(_on_levels)
	buttons.add_child(forward)


func _add_roster_row(parent: Node, p: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.custom_minimum_size = Vector2(0, 44)
	var swatch := ColorRect.new()
	swatch.color = Color(Animals.get_data(p.get("id", "")).get("colour", "#7d6f63"))
	swatch.custom_minimum_size = Vector2(40, 40)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(swatch)

	var status := ""
	var colour := OK_GREEN
	if not p.get("arrived", true):
		status = "jumped off"
		colour = BAD_RED
	elif p.get("rattled", false):
		status = "arrived rattled"
		colour = WARN_AMBER
	else:
		status = "arrived calm"
		colour = OK_GREEN

	var name_label := _add_label(row, p.get("name", "?"), 18, TEXT_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var status_label := _add_label(row, status, 17, colour, HORIZONTAL_ALIGNMENT_RIGHT)
	status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(row)


func _headline(earned: int, failed: bool) -> String:
	if failed:
		return "Rescue failed."
	match earned:
		3: return "Perfect rescue!"
		2: return "Everyone arrived."
		1: return "Arrived short."
		_: return "Empty arrival."


func _hint(earned: int, passengers: Array) -> String:
	if earned == 3:
		return "Flawless — every passenger stayed calm the whole way. Nothing to improve."
	if earned == 0:
		return "The whole crew bailed on the rough ride. Brake before crests and take the bumps slowly to keep them aboard."
	if earned == 1:
		var bailed: Array[String] = []
		for p in passengers:
			if not p.get("arrived", true):
				bailed.append(p.get("name", "?"))
		return "%s jumped off when the ride got too rough. Watch for the \"About to jump!\" warning and ease off over bumps to keep everyone aboard." % _name_list(bailed)
	# earned == 2
	var rattled: Array[String] = []
	for p in passengers:
		if p.get("rattled", false):
			rattled.append(p.get("name", "?"))
	return "Everyone made it, but %s got rattled on the rough ground. Ease off before sharp crests to earn the third star." % _name_list(rattled)


func _saved_note() -> String:
	var saved: Array = result.get("saved_by_stop", [])
	if saved.is_empty():
		return ""
	return "🥕 A rest stop steadied %s just before they bolted." % _name_list(saved)


func _teaser() -> String:
	var next_index := level_index + 1
	if next_index >= Levels.count():
		return "That was the final rescue — the whole convoy is home."
	var next: Dictionary = Levels.get_level(next_index)
	var hook: String = next.get("hook", next.get("brief", ""))
	if GameState.is_unlocked(next_index):
		return "Next — %s: %s" % [next["title"], hook]
	return "Earn at least one star to unlock %s — %s" % [next["title"], hook]


func _next_available() -> bool:
	var next_index := level_index + 1
	return next_index < Levels.count() and GameState.is_unlocked(next_index)


func _on_retry() -> void:
	GameState.current_level = level_index
	get_tree().change_scene_to_file("res://src/prep.tscn")


func _on_next() -> void:
	GameState.current_level = level_index + 1
	get_tree().change_scene_to_file("res://src/prep.tscn")


func _on_levels() -> void:
	get_tree().change_scene_to_file("res://src/level_select.tscn")


func _name_list(names: Array) -> String:
	if names.is_empty():
		return "someone"
	if names.size() == 1:
		return names[0]
	if names.size() == 2:
		return "%s and %s" % [names[0], names[1]]
	return "%s and %s" % [", ".join(names.slice(0, names.size() - 1)), names[-1]]
