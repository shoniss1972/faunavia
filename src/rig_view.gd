extends Control

# A static "diorama" of a loaded rig — the vehicle drawn with its real passenger
# portraits aboard, on a little strip of ground. It reuses the driving scene's
# body-space geometry (Vehicles/Animals data, the same seat solve and superstructure
# shapes) so the brief shows the player the exact rig they're about to drive, rather
# than a text manifest. The prep screen builds one of these; other menus can too.
#
# Everything is drawn in a single "body space" transform (1 unit = `_scale` px,
# origin at the vehicle's body centre) so the shape code below is a near-copy of
# main.gd's _veh_* / seating math — keep the two in step when either changes.

const CAB_X := 0.25
const SEAT_BACK := 0.44
const SOLO_HEAD := 0.40
const HEAD_W_PER_RADIUS := 3.5
const HEAD_SPACING := 0.75
const MIN_HEAD := 5.0
const MAX_HEAD := 11.0

# Per-animal sprite placement, mirrored from main.gd's CRITTER_ART so portraits sit
# the same way here as they do in the cab.
const CRITTER_ART := {
	"wombat": {"scale": 3.2, "offset": Vector2(0.0, -0.15)},
	"rabbit": {"scale": 3.6, "offset": Vector2(0.0, -0.6)},
	"fox": {"scale": 3.3, "offset": Vector2(0.0, -0.35)},
	"tortoise": {"scale": 3.2, "offset": Vector2(-0.1, 0.05)},
	"parrot": {"scale": 3.3, "offset": Vector2(-0.05, -0.3)},
	"goat": {"scale": 3.7, "offset": Vector2(-0.05, -0.5)},
}
const CRITTER_ART_DIR := "res://assets/animals/"

var vehicle_id := "jeep"
var passengers: Array[String] = []
var equipment: Array[String] = []
var trailer := false

var _veh := {}
var _tex_cache := {}


func setup(vehicle: String, animals: Array, gear: Array, has_trailer: bool) -> void:
	vehicle_id = vehicle
	passengers.assign(animals)
	equipment.assign(gear)
	trailer = has_trailer
	_veh = Vehicles.get_data(vehicle_id)
	queue_redraw()


func _seat_front() -> float:
	return float(_veh.get("seat_front", CAB_X))


func _crew_head_radius(bw: float, bh: float, n: int) -> float:
	var bed := bw * (SEAT_BACK + _seat_front())
	var head_w := bed / (1.0 + HEAD_SPACING * float(n - 1))
	return clampf(minf(bh * SOLO_HEAD, head_w / HEAD_W_PER_RADIUS), MIN_HEAD, MAX_HEAD)


func _seating_split() -> Array:
	# Fill the vehicle's own slots, overflow to the trailer — same split as the drive.
	var bed: Array[int] = []
	var trailer_ids: Array[int] = []
	var veh_cap := int(_veh.get("capacity", 2))
	var used := 0
	for i in passengers.size():
		var s := int(Animals.get_data(passengers[i]).get("size", 1))
		if trailer and used + s > veh_cap:
			trailer_ids.append(i)
		else:
			used += s
			bed.append(i)
	return [bed, trailer_ids]


func _texture(id: String, mood: String) -> Texture2D:
	var key := id + "_" + mood
	if _tex_cache.has(key):
		return _tex_cache[key]
	var path := CRITTER_ART_DIR + key + ".png"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_tex_cache[key] = tex
	return tex


func _draw() -> void:
	if _veh.is_empty():
		_veh = Vehicles.get_data(vehicle_id)

	var bw: float = _veh.get("body_w", 96.0)
	var bh: float = _veh.get("body_h", 32.0)
	var wr: float = _veh.get("wheel_r", 16.0)

	# Body-space extents, so the whole rig (plus trailer) is scaled to fit the panel.
	var left_u := -(bw * 0.5 + 68.0) if trailer else -(bw * 0.5 + 6.0)
	var right_u := bw * 0.5 + 16.0
	var top_u := (4.0 - bh) - 32.0
	var bot_u := 4.0 + wr * 1.7
	var span_w := right_u - left_u
	var span_h := bot_u - top_u

	# Fit with margins; a touch of headroom for the mood emote / ground.
	var s := minf((size.x * 0.92) / span_w, (size.y * 0.86) / span_h)
	# Centre the rig's bounding box in the panel.
	var mid_u := Vector2((left_u + right_u) * 0.5, (top_u + bot_u) * 0.5)
	var origin := size * 0.5 - mid_u * s

	# A flat contact shadow just below the tyres so the rig sits on the card rather
	# than floating — no hard ground band (it read as a stray rectangle on the panel).
	var ground_y := origin.y + (4.0 + wr * 0.9) * s
	var shadow_w := (right_u - left_u) * 0.42 * s
	draw_set_transform(Vector2(origin.x, ground_y + wr * 0.12 * s), 0.0, Vector2(1.0, 0.15))
	draw_circle(Vector2.ZERO, shadow_w, Color(0, 0, 0, 0.15))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if trailer:
		_draw_trailer(origin, s, bw, wr)

	draw_set_transform(origin, 0.0, Vector2(s, s))
	_draw_rig_body(bw, bh, wr)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_rig_body(bw: float, bh: float, wr: float) -> void:
	var body_col := Color(_veh.get("colour", "#d9824b"))
	var body_top := 4.0 - bh
	var shape := String(_veh.get("shape", "jeep"))
	var wdx: float = _veh.get("wheel_dx", 30.0)
	var wheel_cy := 4.0 + wr * 0.55
	var front_wr := wr * 0.82 if shape == "tuktuk" else wr

	# Wheels.
	draw_circle(Vector2(-wdx, wheel_cy), wr, Color("#30352f"))
	draw_circle(Vector2(wdx, wheel_cy), front_wr, Color("#30352f"))
	draw_circle(Vector2(-wdx, wheel_cy), wr * 0.44, Color("#b8b6a8"))
	draw_circle(Vector2(wdx, wheel_cy), front_wr * 0.44, Color("#b8b6a8"))

	# Body box + superstructure behind the crew, then the crew, then the front.
	draw_rect(Rect2(-bw * 0.5, body_top, bw, bh), body_col, true)
	match shape:
		"tuktuk":
			_tuktuk_canopy(bw, bh, body_top, body_col)
		"jeep":
			_jeep_rollbar(bw, bh, body_top, body_col)
	_draw_bed_passengers(bw, bh, body_top)
	match shape:
		"tuktuk":
			_tuktuk_front(bw, bh, body_top, body_col)
		"truck":
			_truck_front(bw, bh, body_top, body_col)
		_:
			_jeep_front(bw, bh, body_top, body_col)


func _draw_bed_passengers(bw: float, bh: float, body_top: float) -> void:
	var bed: Array = _seating_split()[0]
	var m := bed.size()
	if m == 0:
		return
	if passengers.size() == 1:
		var solo_x := (-bw * SEAT_BACK + bw * _seat_front()) * 0.5
		_draw_portrait(Vector2(solo_x, body_top - 11.0), minf(bh * SOLO_HEAD, MAX_HEAD), passengers[bed[0]])
		return
	var r := _crew_head_radius(bw, bh, m)
	var half := r * HEAD_W_PER_RADIUS * 0.5
	var left := -bw * SEAT_BACK + half
	var right := bw * _seat_front() - half
	if right < left:
		left = (left + right) * 0.5
		right = left
	for k in m:
		var fx := (left + right) * 0.5 if m == 1 else lerpf(left, right, float(k) / float(m - 1))
		_draw_portrait(Vector2(fx, body_top - 6.0), r, passengers[bed[k]])


func _draw_portrait(center: Vector2, radius: float, id: String) -> void:
	var tex := _texture(id, "content")
	if tex == null:
		draw_circle(center, radius, Color(Animals.get_data(id).get("colour", "#7d6f63")))
		return
	var art: Dictionary = CRITTER_ART.get(id, {})
	var h := radius * float(art.get("scale", 3.0))
	var w := h * float(tex.get_width()) / float(tex.get_height())
	var pos := center + Vector2(art.get("offset", Vector2.ZERO)) * radius - Vector2(w, h) * 0.5
	draw_texture_rect(tex, Rect2(pos, Vector2(w, h)), false)


func _draw_trailer(origin: Vector2, s: float, bw: float, wr: float) -> void:
	var tx := -(bw * 0.5 + 42.0)
	# Hitch bar from the trailer up to the rig's rear (drawn in body space).
	draw_set_transform(origin, 0.0, Vector2(s, s))
	draw_line(Vector2(tx + 26.0, -12.0), Vector2(-bw * 0.5, -2.0), Color("#4a4f45"), 3.0)
	# Trailer wheel + box.
	var wheel_cy := 4.0 + wr * 0.55
	draw_circle(Vector2(tx, wheel_cy), 12.0, Color("#30352f"))
	draw_circle(Vector2(tx, wheel_cy), 5.0, Color("#b8b6a8"))
	draw_rect(Rect2(tx - 26.0, -26.0, 52.0, 26.0), Color("#9a8b76"), true)
	# Overflow passengers seated on the box rim.
	var t_ids: Array = _seating_split()[1]
	var tm := t_ids.size()
	if tm > 0:
		var inner := 44.0
		var head_w := inner / (1.0 + HEAD_SPACING * float(tm - 1))
		var tr := clampf(head_w / HEAD_W_PER_RADIUS, MIN_HEAD, MAX_HEAD)
		var thalf := tr * HEAD_W_PER_RADIUS * 0.5
		var tleft := -inner * 0.5 + thalf
		var tright := inner * 0.5 - thalf
		if tright < tleft:
			tleft = 0.0
			tright = 0.0
		for k in tm:
			var fx := (tleft + tright) * 0.5 if tm == 1 else lerpf(tleft, tright, float(k) / float(tm - 1))
			_draw_portrait(Vector2(tx + fx, -22.0), tr, passengers[t_ids[k]])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---- Vehicle superstructure (mirrors main.gd's _veh_* draws) --------------------

func _driver(seat_x: float, head_y: float, sc := 1.0) -> void:
	var skin := Color("#e3c29e")
	var shirt := Color("#455f9c")
	draw_rect(Rect2(seat_x - 5.0 * sc, head_y + 3.0 * sc, 10.0 * sc, 11.0 * sc), shirt, true)
	draw_line(Vector2(seat_x + 3.0 * sc, head_y + 6.0 * sc), Vector2(seat_x + 9.0 * sc, head_y + 8.0 * sc), skin, 2.4 * sc)
	draw_circle(Vector2(seat_x, head_y), 5.0 * sc, skin)
	draw_arc(Vector2(seat_x, head_y - 0.5 * sc), 5.2 * sc, PI, TAU, 10, Color("#4b3a2a"), 2.6 * sc)


func _tuktuk_canopy(bw: float, bh: float, body_top: float, col: Color) -> void:
	var canopy := Color("#e0a23e")
	draw_line(Vector2(-bw * 0.42, body_top - 2.0), Vector2(-bw * 0.42, body_top - 22.0), col.darkened(0.2), 2.5)
	draw_line(Vector2(bw * 0.46, body_top - 2.0), Vector2(bw * 0.46, body_top - 22.0), col.darkened(0.2), 2.5)
	draw_rect(Rect2(-bw * 0.48, body_top - 25.0, bw * 0.98, 6.0), canopy, true)
	draw_circle(Vector2(-bw * 0.48, body_top - 22.0), 3.0, canopy)
	draw_circle(Vector2(bw * 0.50, body_top - 22.0), 3.0, canopy)


func _tuktuk_front(bw: float, bh: float, body_top: float, col: Color) -> void:
	draw_rect(Rect2(bw * 0.12, body_top - 16.0, bw * 0.40, bh + 16.0), col, true)
	draw_circle(Vector2(bw * 0.50, body_top - 4.0), bh * 0.52 + 6.0, col)
	draw_rect(Rect2(bw * 0.20, body_top - 12.0, bw * 0.26, 13.0), Color("#bfe6df"), true)
	draw_circle(Vector2(bw * 0.54, body_top + bh * 0.4), 2.6, Color("#f2e28a"))
	_driver(bw * 0.26, body_top - 9.0, 1.35)


func _jeep_rollbar(bw: float, bh: float, body_top: float, col: Color) -> void:
	var frame := col.darkened(0.35)
	draw_line(Vector2(-bw * 0.30, body_top), Vector2(-bw * 0.30, body_top - 18.0), frame, 3.0)
	draw_line(Vector2(-bw * 0.30, body_top - 18.0), Vector2(bw * 0.02, body_top - 18.0), frame, 3.0)
	draw_line(Vector2(bw * 0.02, body_top - 18.0), Vector2(bw * 0.02, body_top), frame, 3.0)


func _jeep_front(bw: float, bh: float, body_top: float, col: Color) -> void:
	var frame := col.darkened(0.35)
	draw_line(Vector2(bw * 0.28, body_top), Vector2(bw * 0.14, body_top - 20.0), frame, 3.0)
	draw_rect(Rect2(bw * 0.02, body_top - 20.0, bw * 0.14, 4.0), frame, true)
	draw_rect(Rect2(-bw * 0.5, body_top + bh * 0.55, bw, bh * 0.5), col.darkened(0.18), true)
	draw_circle(Vector2(bw * 0.47, body_top + bh * 0.35), 3.2, Color("#f2e28a"))
	_driver(bw * 0.28, body_top - 11.0, 1.4)


func _truck_front(bw: float, bh: float, body_top: float, col: Color) -> void:
	var cab := col.darkened(0.12)
	draw_rect(Rect2(bw * 0.18, body_top - 30.0, bw * 0.30, bh + 30.0), cab, true)
	draw_rect(Rect2(bw * 0.22, body_top - 26.0, bw * 0.20, 17.0), Color("#bfe6df"), true)
	draw_rect(Rect2(bw * 0.46, body_top + bh * 0.5, bw * 0.06, bh * 0.6), Color("#40352c"), true)
	draw_circle(Vector2(bw * 0.5, body_top + bh * 0.3), 3.0, Color("#f2e28a"))
	_driver(bw * 0.30, body_top - 22.0, 1.5)
