extends Button

# A code-drawn speaker toggle, so it renders identically everywhere (emoji glyphs
# are missing from the export font and show blank on iOS/web). It extends Button so
# tap handling uses the engine's proven path — a raw Control with _gui_input did
# not register the tap on iOS web. Draws sound waves when on, a red cross when muted.

var muted := false


func _ready() -> void:
	flat = true                       # we draw our own look, no button chrome
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func(): emit_signal("toggled_mute"))


signal toggled_mute


func set_muted(m: bool) -> void:
	muted = m
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.14, 0.13, 0.5), true)
	var ink := Color(0.93, 0.95, 0.91, 0.9)
	var c := size * 0.5
	var bx := c.x - 9.0
	# Speaker: a small magnet box and a cone opening to the right.
	draw_rect(Rect2(bx - 4.0, c.y - 4.0, 5.0, 8.0), ink, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(bx + 1.0, c.y - 4.0), Vector2(bx + 9.0, c.y - 11.0),
		Vector2(bx + 9.0, c.y + 11.0), Vector2(bx + 1.0, c.y + 4.0)]), ink)
	if muted:
		draw_line(Vector2(bx + 13.0, c.y - 9.0), Vector2(bx + 24.0, c.y + 9.0), Color("#e0552e"), 3.0)
		draw_line(Vector2(bx + 24.0, c.y - 9.0), Vector2(bx + 13.0, c.y + 9.0), Color("#e0552e"), 3.0)
	else:
		draw_arc(Vector2(bx + 9.0, c.y), 7.0, -0.7, 0.7, 8, ink, 2.0)
		draw_arc(Vector2(bx + 9.0, c.y), 12.0, -0.7, 0.7, 10, ink, 2.0)
