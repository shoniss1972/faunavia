extends Control

# A code-drawn row of stars (earned filled, the rest outlined), so ratings render
# identically everywhere — the ★/☆ glyphs are missing from the export font and
# show blank on iOS/web.

var earned := 0
var total := 3
var star_r := 20.0
var gold := Color("#e8b84a")
var empty := Color(0.55, 0.55, 0.55, 0.5)


func setup(e: int, t: int, r: float, gold_col := Color("#e8b84a")) -> void:
	earned = e
	total = t
	star_r = r
	gold = gold_col
	custom_minimum_size = Vector2(float(t) * r * 2.35, r * 2.2)
	queue_redraw()


func _draw() -> void:
	var gap := star_r * 2.35
	var y := size.y * 0.5
	var x0 := (size.x - float(total) * gap) * 0.5 + gap * 0.5
	for i in range(total):
		var c := Vector2(x0 + float(i) * gap, y)
		var pts := _star_pts(c, star_r, star_r * 0.42)
		if i < earned:
			draw_colored_polygon(pts, gold)
		else:
			var outline := pts.duplicate()
			outline.append(pts[0])
			draw_polyline(outline, empty, 2.0)


func _star_pts(c: Vector2, ro: float, ri: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(10):
		var ang := -PI / 2.0 + float(i) * PI / 5.0
		var r := ro if i % 2 == 0 else ri
		pts.append(c + Vector2(cos(ang), sin(ang)) * r)
	return pts
