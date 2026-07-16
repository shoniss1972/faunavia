extends Control

const TRACK_BUFFER := 160.0          # ground drawn past the sanctuary
const BRAKING := 260.0
const COAST_DRAG := 52.0
const FUEL_PICKUP_AMOUNT := 45.0
const FOOD_COMFORT := 40.0           # comfort restored at a food store
const REST_HEIGHT := 25.0

# Fuel is temporarily disabled while other things are fixed. When false: no drain,
# never runs out, no fuel readout, and fuel stops are omitted from routes. Flip to
# true to bring the whole fuel mechanic back — no other changes needed.
const FUEL_ENABLED := false

const CRITTER_ART_DIR := "res://assets/animals/"

# The world is drawn zoomed so the vehicle and its passengers read as the subject
# rather than a distant doll-house, and the camera puts the ground under the
# vehicle low in the frame so the view is spent on road, not empty sky.
#
# Zoom trades size against lookahead, and lookahead is the skill: the player must
# see a bump coming to ease off for it. At 2.0 the view is 360 world px wide, so
# with the vehicle a quarter across there is ~270 px of road ahead — comfortably
# past the Truck's ~173 px braking distance at its 300 px/s top speed, and most
# of a bump (the rough terrain term has a ~350 px wavelength). Pushing to 2.5
# drops that to ~200 px, which is inside braking distance: hills stop being
# readable. Raise this only alongside a lower CAM_ANCHOR_X.
const WORLD_ZOOM := 2.0
const CAM_ANCHOR_X := 0.26
const CAM_ANCHOR_Y := 0.58
const CAM_FOLLOW := 3.0              # how quickly the camera settles to the terrain height

# Per-animal sprite placement, tuned against the real cab render. The generated
# art is tight-cropped to each animal's own proportions — a rabbit is 40% ears, a
# wombat is nearly all head — so scaling every sprite to one height would leave
# the heads visibly different sizes. `scale` multiplies the drawn radius to set
# sprite height, chosen so the HEAD reads the same size across species; `offset`
# then shifts the sprite (in multiples of radius) so each head clears the cab
# side rather than sinking into it.
const CRITTER_ART := {
	"wombat": {"scale": 3.2, "offset": Vector2(0.0, -0.15)},
	"rabbit": {"scale": 3.6, "offset": Vector2(0.0, -0.6)},
	"fox": {"scale": 3.3, "offset": Vector2(0.0, -0.35)},
	"tortoise": {"scale": 3.2, "offset": Vector2(-0.1, 0.05)},
	"parrot": {"scale": 3.3, "offset": Vector2(-0.05, -0.3)},
	"goat": {"scale": 3.7, "offset": Vector2(-0.05, -0.5)},
}

# Route stops as fractions of the track length, so they scale with each level's
# length. Levels may override with their own list. Default: a fuel stop, a food
# store, and the sanctuary finish.
const DEFAULT_ROUTE := [
	{"type": "fuel", "at": 0.45},
	{"type": "food", "at": 0.70},
	{"type": "sanctuary", "at": 1.0},
]
const NODE_STYLE := {
	"fuel": {"label": "FUEL", "colour": "#efb64d"},
	"food": {"label": "FOOD", "colour": "#c98a3a"},
	"vet": {"label": "VET", "colour": "#5a9bd4"},
	"sanctuary": {"label": "SANCTUARY", "colour": "#6b9c72"},
}
# Passenger seating, solved from the vehicle's own body box so new vehicles need
# no new numbers. The crew is spread across SEAT_SPAN of the body width, shifted
# back from the cab, and heads are sized to fit that span (see _crew_head_radius).
const SEAT_SPAN := 0.66            # fraction of body width the crew is spread across
const SEAT_SHIFT := 0.07           # how far back from body centre the row sits
const SOLO_HEAD := 0.40            # lone passenger head radius, as a fraction of body height
const SEAT_OVERLAP := 1.35         # how much wider than its slot a head may sit
const HEAD_W_PER_RADIUS := 3.5     # nominal sprite width in units of drawn radius
const MIN_HEAD := 5.0              # never shrink a head below this, even when crowded

const SUSPENSION_STIFFNESS := 90.0
const SUSPENSION_DAMPING := 11.0

# The passengers ride from the prepared loadout. Their combined weight, as a
# 0..1 load factor from GameState, feeds handling, fuel use, and suspension sag
# so the cargo is felt, not just labelled.
const ACCEL_MASS_PENALTY := 0.45   # fraction of acceleration lost at load 1.0
const FUEL_MASS_PENALTY := 2.4     # multiplies fuel burn per pixel at load 1.0
const SAG_PER_MASS := 14.0         # extra pixels the body sags at load 1.0
const LOAD_TIME := 1.4             # seconds the reluctant crew takes to clamber aboard

# Comfort is a 0..100 mood the passenger builds from how the ride feels.
# Hard suspension jolts drain it; smooth travel restores it. The value is
# never shown as a number — it only drives the animal's face and emotes.
const COMFORT_MAX := 100.0
const COMFORT_JOLT_THRESHOLD := 58.0   # |body_vy| below this counts as a smooth ride
const COMFORT_LOSS_RATE := 0.7         # comfort lost per unit of jolt-over-threshold, per second
const COMFORT_RECOVERY := 18.0         # comfort regained per second on smooth travel
const COMFORT_ANNOYED := 40.0          # at or below this the passenger is annoyed
const COMFORT_DELIGHTED := 80.0        # at or above this, and moving well, it is delighted

@onready var fuel_label: Label = %FuelLabel
@onready var message_label: Label = %MessageLabel

var vehicle_x := 100.0
var speed := 0.0
var fuel := 100.0
var drive_pressed := false
var brake_pressed := false
var route: Array = []
var nodes_used := {}
var track_len := 2050.0
var track_rough := 1.0
var track_phase := 0.0
var track_freq := 1.0
var finished := false
var body_y := 0.0
var body_vy := 0.0
var comfort := COMFORT_MAX
var _critter_art := {}   # "<id>_<mood>" -> Texture2D, filled on first draw
var cam_y := 0.0         # smoothed terrain height the camera tracks
var _cam := Vector2.ZERO # world point at the screen's top-left, set each frame
var passenger_state := "content"
var ever_annoyed := false
var ever_delighted := false
var passengers: Array[String] = []
var load_factor := 0.5
var has_cage := false
var has_trailer := false
var vehicle_data := {}
var veh_max_speed := 260.0
var veh_accel := 150.0
var veh_start_fuel := 55.0
var veh_fuel_per_px := 0.012
var is_loaded := false
var loading := false
var load_t := 0.0
var finish_hold := 0.0
var advancing := false

const FINISH_HOLD_TIME := 2.0   # seconds to celebrate arrival before moving on


func _ready() -> void:
	set_process(true)
	_reset_run()


func _update_camera(delta: float) -> void:
	# Settle the camera onto the terrain under the vehicle. Smoothed, so cresting
	# a hill pans the view instead of snapping it — an abrupt camera would read as
	# a jolt the player did not cause, which is exactly the signal comfort uses.
	cam_y = lerpf(cam_y, terrain_y(vehicle_x), 1.0 - exp(-CAM_FOLLOW * delta))


func _process(delta: float) -> void:
	if advancing:
		return
	_update_camera(delta)
	if finished:
		_update_suspension(delta)
		finish_hold += delta
		if finish_hold >= FINISH_HOLD_TIME:
			_advance_after_delivery()
			return
		queue_redraw()
		return

	var driving := drive_pressed or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
	var braking := brake_pressed or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)

	if not is_loaded:
		_update_loading(delta, driving)
		_update_suspension(delta)
		queue_redraw()
		return

	if driving and fuel > 0.0:
		var accel := veh_accel * (1.0 - load_factor * ACCEL_MASS_PENALTY)
		speed = min(speed + accel * delta, veh_max_speed)
	elif braking:
		speed = max(speed - BRAKING * delta, 0.0)
	else:
		speed = max(speed - COAST_DRAG * delta, 0.0)

	if FUEL_ENABLED and fuel <= 0.0:
		speed = max(speed - BRAKING * delta, 0.0)
		message_label.text = "Out of fuel — coast if you can, or reset."

	# Fuel is a range meter: distance travelled burns fuel, and a heavier load
	# burns more per pixel. Speed is a comfort concern, not a fuel one.
	var dist := speed * delta
	if FUEL_ENABLED:
		fuel = max(fuel - veh_fuel_per_px * (1.0 + load_factor * FUEL_MASS_PENALTY) * dist, 0.0)
	vehicle_x = min(vehicle_x + dist, track_len + TRACK_BUFFER)

	_check_route_nodes()

	_update_suspension(delta)
	_update_comfort(delta)

	if FUEL_ENABLED:
		fuel_label.text = "Fuel: %d%%   Speed: %d" % [roundi(fuel), roundi(speed)]
		_update_fuel_colour()
	else:
		fuel_label.text = "Speed: %d" % roundi(speed)
	queue_redraw()


func _update_fuel_colour() -> void:
	# Warn as the range meter runs low, so the fuel stakes read at a glance.
	var col := Color("#e8ede4")
	if fuel <= 15.0:
		col = Color("#e06a4a")
	elif fuel <= 30.0:
		col = Color("#e8b84a")
	fuel_label.add_theme_color_override("font_color", col)


func _update_comfort(delta: float) -> void:
	# The passenger reads the ride through the suspension: sharp vertical motion
	# is a jolt that drains comfort, calm travel lets it recover. Comfort then
	# selects one of three moods the animal acts out.
	var jolt := absf(body_vy)
	if jolt > COMFORT_JOLT_THRESHOLD:
		comfort -= (jolt - COMFORT_JOLT_THRESHOLD) * COMFORT_LOSS_RATE * delta
	else:
		comfort += COMFORT_RECOVERY * delta
	comfort = clampf(comfort, 0.0, COMFORT_MAX)

	if comfort <= COMFORT_ANNOYED:
		passenger_state = "annoyed"
		ever_annoyed = true
	elif comfort >= COMFORT_DELIGHTED and speed > 120.0:
		passenger_state = "delighted"
		ever_delighted = true
	else:
		passenger_state = "content"


func _check_route_nodes() -> void:
	# Apply each route stop as the vehicle reaches it. The sanctuary ends the run;
	# fuel, food, and vet stops each top up once when passed.
	for node in route:
		var nx: float = node["x"]
		var ntype: String = node["type"]
		if ntype == "sanctuary":
			if vehicle_x >= nx and not finished:
				finished = true
				speed = 0.0
				passenger_state = "delighted"
				var tail := "Preparing next mission..." if GameState.has_more_levels() else "That was the last rescue!"
				message_label.text = "Delivered %s! %s" % [_crew_label(), tail]
			continue
		if nodes_used.has(nx) or absf(vehicle_x - nx) >= 42.0:
			continue
		nodes_used[nx] = true
		match ntype:
			"fuel":
				fuel = min(fuel + FUEL_PICKUP_AMOUNT, 100.0)
				message_label.text = "Fuel collected. Keep going!"
			"food":
				comfort = min(comfort + FOOD_COMFORT, COMFORT_MAX)
				message_label.text = "Fed the crew — spirits lift."
			"vet":
				comfort = COMFORT_MAX
				message_label.text = "Vet check — everyone's calm."


func _update_loading(delta: float, drive_requested: bool) -> void:
	# The run does not begin until the passenger is aboard. The first drive
	# request coaxes the reluctant animal, who grumbles its way in over a beat.
	if loading:
		load_t += delta
		if load_t >= LOAD_TIME:
			loading = false
			is_loaded = true
			passenger_state = "content"
			message_label.text = "%s aboard! Reach the sanctuary — mind the fuel." % _crew_label().capitalize()
	elif drive_requested:
		loading = true
		load_t = 0.0
		message_label.text = "Coaxing %s aboard..." % _crew_label()


func _crew_label() -> String:
	if passengers.size() == 1:
		return Animals.display_name(passengers[0])
	return "the crew"


func _advance_after_delivery() -> void:
	# The mission is delivered. Score the run, record it (which unlocks the next
	# level and saves), then return to the level select.
	advancing = true
	var earned := 1                        # delivered the crew
	if not ever_annoyed:
		earned += 1                        # never let a passenger get annoyed
	if ever_delighted:
		earned += 1                        # thrilled the crew with a smooth, spirited run
	GameState.record_result(GameState.current_level, earned)
	get_tree().change_scene_to_file("res://src/level_select.tscn")


func _load_line() -> String:
	# The passenger's grumbling, timed to the clamber-in animation.
	if load_t < LOAD_TIME * 0.34:
		return "Do I have to?"
	elif load_t < LOAD_TIME * 0.68:
		return "Ugh, fine..."
	return "...oof, in!"


func _update_suspension(delta: float) -> void:
	# Wheels ride the ground; the body hangs on a damped spring above them,
	# so terrain bumps and speed produce a settling bob without rigid-body physics.
	var rest_target := terrain_y(vehicle_x) - REST_HEIGHT + load_factor * SAG_PER_MASS
	var accel := (rest_target - body_y) * SUSPENSION_STIFFNESS - body_vy * SUSPENSION_DAMPING
	body_vy += accel * delta
	body_y += body_vy * delta
	body_y = clamp(body_y, terrain_y(vehicle_x) - 45.0, terrain_y(vehicle_x) - 8.0)


func terrain_y(world_x: float) -> float:
	# Per-level track: rough scales hill height, freq scales hill spacing, and
	# phase shifts where the hills fall, so each level reads as its own route.
	var t := world_x + track_phase
	return 790.0 + sin(t * 0.007 * track_freq) * 75.0 * track_rough \
		+ sin(t * 0.018 * track_freq) * 28.0 * track_rough


func _w2s(world: Vector2) -> Vector2:
	# World point to screen point through the zoom camera.
	return (world - _cam) * WORLD_ZOOM


func _draw() -> void:
	# The camera holds the vehicle at CAM_ANCHOR_X across and keeps the ground
	# beneath it at CAM_ANCHOR_Y down. cam_y is smoothed in _process so hills pan
	# the view rather than jerking it.
	var view_w := size.x / WORLD_ZOOM
	var camera_x: float = clamp(vehicle_x - view_w * CAM_ANCHOR_X, 0.0, maxf(0.0, track_len + TRACK_BUFFER - view_w))
	_cam = Vector2(camera_x, cam_y - (size.y * CAM_ANCHOR_Y) / WORLD_ZOOM)

	# Sky and distant hills. The hills are a backdrop pinned near the horizon with
	# a slow horizontal parallax, so they read as far away rather than scaling up
	# with the zoom.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#dcefd8"))
	var horizon := _w2s(Vector2(0.0, cam_y)).y
	var distant := PackedVector2Array([Vector2(0, size.y)])
	for screen_x in range(0, int(size.x) + 20, 20):
		var world_x := camera_x * 0.35 + float(screen_x) / WORLD_ZOOM
		distant.append(Vector2(screen_x, horizon - 120.0 + sin(world_x * 0.004) * 60.0))
	distant.append(Vector2(size.x, size.y))
	draw_colored_polygon(distant, Color("#a8c99b"))

	# Main terrain.
	var ground := PackedVector2Array([Vector2(0, size.y)])
	for screen_x in range(-20, int(size.x) + 40, 12):
		var world_x := camera_x + float(screen_x) / WORLD_ZOOM
		ground.append(Vector2(screen_x, _w2s(Vector2(world_x, terrain_y(world_x))).y))
	ground.append(Vector2(size.x, size.y))
	draw_colored_polygon(ground, Color("#78945e"))

	for node in route:
		var style: Dictionary = NODE_STYLE.get(node["type"], NODE_STYLE["fuel"])
		var still_visible: bool = node["type"] == "sanctuary" or not nodes_used.has(node["x"])
		_draw_marker(node["x"], style["label"], Color(style["colour"]), still_visible)
	_draw_trailer()
	_draw_vehicle()


func _draw_marker(world_x: float, label_text: String, marker_color: Color, visible_marker: bool) -> void:
	if not visible_marker:
		return
	var base := _w2s(Vector2(world_x, terrain_y(world_x)))
	if base.x < -160.0 or base.x > size.x + 160.0:
		return
	# The sign is drawn in world units through the camera transform so it grows
	# with the zoom like everything else on the ground.
	draw_set_transform(base, 0.0, Vector2(WORLD_ZOOM, WORLD_ZOOM))
	draw_line(Vector2.ZERO, Vector2(0, -110), Color("#3d4b38"), 7.0)
	# Size the sign to the label so longer names like "SANCTUARY" don't truncate.
	var font := ThemeDB.fallback_font
	var text_w := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	var sign_w := maxf(90.0, text_w + 24.0)
	draw_rect(Rect2(-sign_w * 0.5, -145, sign_w, 42), marker_color, true)
	draw_string(font, Vector2(-sign_w * 0.5 + 12.0, -117), label_text, HORIZONTAL_ALIGNMENT_CENTER, sign_w - 24.0, 15, Color("#263127"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_trailer() -> void:
	if not has_trailer:
		return
	var bw: float = vehicle_data.get("body_w", 96.0)
	var tx_world := vehicle_x - (bw * 0.5 + 42.0)
	var ground := terrain_y(tx_world)
	var slope := terrain_y(tx_world + 16.0) - terrain_y(tx_world - 16.0)
	var angle := atan2(slope, 32.0)
	var zoom := Vector2(WORLD_ZOOM, WORLD_ZOOM)

	# A short hitch bar from the trailer up to the vehicle's rear.
	draw_line(_w2s(Vector2(tx_world + 26.0, ground - 16.0)), _w2s(Vector2(vehicle_x - bw * 0.5, body_y - 6.0)), Color("#4a4f45"), 3.0 * WORLD_ZOOM)

	# Wheel on the ground, box riding above it.
	draw_set_transform(_w2s(Vector2(tx_world, ground - 10.0)), angle, zoom)
	draw_circle(Vector2(0, 0), 12, Color("#30352f"))
	draw_circle(Vector2(0, 0), 5, Color("#b8b6a8"))
	draw_set_transform(_w2s(Vector2(tx_world, ground - 24.0)), angle, zoom)
	draw_rect(Rect2(-26, -22, 52, 26), Color("#9a8b76"), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_vehicle() -> void:
	var slope := terrain_y(vehicle_x + 18.0) - terrain_y(vehicle_x - 18.0)
	var angle := atan2(slope, 36.0)
	var ground_y := terrain_y(vehicle_x)
	var zoom := Vector2(WORLD_ZOOM, WORLD_ZOOM)

	var bw: float = vehicle_data.get("body_w", 96.0)
	var bh: float = vehicle_data.get("body_h", 32.0)
	var wr: float = vehicle_data.get("wheel_r", 16.0)
	var wdx: float = vehicle_data.get("wheel_dx", 30.0)
	var body_col := Color(vehicle_data.get("colour", "#d9824b"))
	var body_top := 4.0 - bh

	# Wheels stay planted on the ground and follow the slope.
	draw_set_transform(_w2s(Vector2(vehicle_x, ground_y - wr * 0.7)), angle, zoom)
	draw_circle(Vector2(-wdx, 0), wr, Color("#30352f"))
	draw_circle(Vector2(wdx, 0), wr, Color("#30352f"))
	draw_circle(Vector2(-wdx, 0), wr * 0.44, Color("#b8b6a8"))
	draw_circle(Vector2(wdx, 0), wr * 0.44, Color("#b8b6a8"))

	# Body rides on the suspension, bobbing relative to the wheels.
	draw_set_transform(_w2s(Vector2(vehicle_x, body_y)), angle, zoom)
	draw_rect(Rect2(-bw * 0.5, body_top, bw, bh), body_col, true)
	draw_rect(Rect2(-bw * 0.23, body_top - 24.0, bw * 0.45, 25.0), Color("#f2d7a8"), true)
	_draw_passenger(_passenger_load_offset())
	draw_rect(Rect2(bw * 0.25, body_top - 15.0, bw * 0.33, bh + 6.0), Color("#596b52"), false, 5.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var over_cab := _w2s(Vector2(vehicle_x, body_y - 58.0))
	if loading:
		draw_string(ThemeDB.fallback_font, over_cab - Vector2(45.0, 0.0), _load_line(), HORIZONTAL_ALIGNMENT_CENTER, 90.0, 18, Color("#8a5a2b"))
	elif is_loaded:
		_draw_emote(over_cab.x, over_cab.y)


func _passenger_load_offset() -> float:
	# How far below its seat the passenger sits while boarding. It starts low,
	# mostly hidden behind the cab, then clambers up to zero as loading finishes.
	if is_loaded:
		return 0.0
	if loading:
		var p := clampf(load_t / LOAD_TIME, 0.0, 1.0)
		return pow(1.0 - p, 3) * 26.0
	return 26.0


func _crew_head_radius(bw: float, bh: float, n: int) -> float:
	# Head size for a crew, derived from the geometry rather than tuned per
	# vehicle: a lone passenger gets the full head, and a crew shrinks only as far
	# as it must to fit the bed. This keeps working for vehicles that do not exist
	# yet — a new body_w/body_h re-solves the layout with no numbers to revisit.
	var solo := bh * SOLO_HEAD
	if n <= 1:
		return solo
	var spacing := (bw * SEAT_SPAN) / float(n - 1)
	# A head may run wider than its slot — animals sit shoulder to shoulder — but
	# past SEAT_OVERLAP the ones in the middle disappear behind their neighbours.
	var fits := spacing * SEAT_OVERLAP / HEAD_W_PER_RADIUS
	return maxf(minf(solo, fits), MIN_HEAD)


func _draw_passenger(y_offset: float) -> void:
	# The loaded animals ride in the cab, drawn in body space so they bob and
	# sag with the suspension. y_offset drops them into their seats during the
	# boarding animation. A single passenger sits high in the cab window; a crew
	# spreads across the bed.
	var n := passengers.size()
	if n == 0:
		return
	var bw: float = vehicle_data.get("body_w", 96.0)
	var bh: float = vehicle_data.get("body_h", 32.0)
	var body_top := 4.0 - bh
	var off := Vector2(0.0, y_offset)
	if n == 1:
		_draw_critter(Vector2(-bw * 0.01, body_top - 12.0) + off, bh * 0.4, passengers[0])
		return
	var left := -bw * SEAT_SPAN * 0.5 - bw * SEAT_SHIFT
	var right := bw * SEAT_SPAN * 0.5 - bw * SEAT_SHIFT
	var r := _crew_head_radius(bw, bh, n)
	for i in n:
		var fx := lerpf(left, right, float(i) / float(n - 1))
		_draw_critter(Vector2(fx, body_top - 6.0) + off, r, passengers[i])
	if has_cage:
		# A divider bar between the animals — the divided cage keeping the peace.
		var bar_x := lerpf(left, right, 0.5)
		draw_line(Vector2(bar_x, body_top - 22.0) + off, Vector2(bar_x, body_top + 6.0) + off, Color("#4a4f45"), 3.0)


func _fur(id: String) -> Color:
	return Color(Animals.get_data(id).get("colour", "#7d6f63"))


func _critter_texture(id: String, mood: String) -> Texture2D:
	var key := id + "_" + mood
	if _critter_art.has(key):
		return _critter_art[key]
	var path := CRITTER_ART_DIR + key + ".png"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_critter_art[key] = tex
	return tex


func _draw_critter(center: Vector2, radius: float, id: String) -> void:
	# One animal, drawn from its mood sprite. passenger_state already reads
	# "content"/"annoyed"/"delighted", which is exactly the filename suffix, so a
	# mood change swaps the texture and nothing else.
	var tex := _critter_texture(id, passenger_state)
	if tex == null:
		_draw_critter_shapes(center, radius, id)
		return
	var art: Dictionary = CRITTER_ART.get(id, {})
	var h := radius * float(art.get("scale", 3.0))
	var w := h * float(tex.get_width()) / float(tex.get_height())
	var pos := center + Vector2(art.get("offset", Vector2.ZERO)) * radius - Vector2(w, h) * 0.5
	draw_texture_rect(tex, Rect2(pos, Vector2(w, h)), false)


func _draw_critter_shapes(center: Vector2, radius: float, id: String) -> void:
	# Fallback used only if a mood sprite is missing: a species silhouette (ears,
	# horns, shell, beak) plus a shared mood-driven face. Feature offsets scale
	# from the reference radius so smaller crew heads stay proportioned.
	var s := radius / 13.0
	var colour := _fur(id)

	# Behind the head — ears, horns, crest, or shell.
	match id:
		"rabbit":
			draw_line(center + Vector2(-5, -8) * s, center + Vector2(-7, -25) * s, colour, 6.0 * s)
			draw_line(center + Vector2(5, -8) * s, center + Vector2(7, -25) * s, colour, 6.0 * s)
		"fox":
			draw_colored_polygon(PackedVector2Array([center + Vector2(-12, -5) * s, center + Vector2(-6, -22) * s, center + Vector2(-1, -8) * s]), colour)
			draw_colored_polygon(PackedVector2Array([center + Vector2(12, -5) * s, center + Vector2(6, -22) * s, center + Vector2(1, -8) * s]), colour)
		"goat":
			draw_line(center + Vector2(-4, -9) * s, center + Vector2(-11, -21) * s, colour.darkened(0.3), 3.5 * s)
			draw_line(center + Vector2(4, -9) * s, center + Vector2(11, -21) * s, colour.darkened(0.3), 3.5 * s)
			draw_circle(center + Vector2(-12, 1) * s, 3.5 * s, colour)
			draw_circle(center + Vector2(12, 1) * s, 3.5 * s, colour)
		"parrot":
			draw_line(center + Vector2(-1, -11) * s, center + Vector2(-5, -23) * s, colour.darkened(0.15), 3.0 * s)
			draw_line(center + Vector2(2, -11) * s, center + Vector2(3, -24) * s, colour.darkened(0.15), 3.0 * s)
		"tortoise":
			draw_circle(center + Vector2(0, 8) * s, radius * 1.2, colour.darkened(0.32))
		_:
			# Wombat: small round ears.
			draw_circle(center + Vector2(-10, -10) * s, 5.0 * s, colour)
			draw_circle(center + Vector2(10, -10) * s, 5.0 * s, colour)

	draw_circle(center, radius, colour)

	# In front of the head — beaks and snouts.
	if id == "parrot":
		draw_colored_polygon(PackedVector2Array([center + Vector2(5, 0) * s, center + Vector2(15, 3) * s, center + Vector2(5, 7) * s]), Color("#e8a63a"))
	elif id == "fox":
		draw_circle(center + Vector2(0, 6) * s, 3.5 * s, colour.lightened(0.4))

	_draw_face(center, s)


func _draw_face(center: Vector2, s: float) -> void:
	var dark := Color("#2c2620")
	match passenger_state:
		"annoyed":
			# Furrowed brows sloping in, dot eyes, a flat set mouth.
			draw_line(center + Vector2(-8, -7) * s, center + Vector2(-2, -4) * s, dark, 1.6)
			draw_line(center + Vector2(7, -7) * s, center + Vector2(1, -4) * s, dark, 1.6)
			draw_circle(center + Vector2(-5, -2) * s, 2.0 * s, dark)
			draw_circle(center + Vector2(4, -2) * s, 2.0 * s, dark)
			draw_line(center + Vector2(-3, 7) * s, center + Vector2(3, 7) * s, dark, 1.6)
		"delighted":
			# Squinting happy eyes and a wide open grin.
			draw_arc(center + Vector2(-5, -2) * s, 3.0 * s, 0.0, PI, 6, dark, 2.0)
			draw_arc(center + Vector2(4, -2) * s, 3.0 * s, 0.0, PI, 6, dark, 2.0)
			draw_arc(center + Vector2(0, 4) * s, 4.0 * s, 0.0, PI, 8, dark, 2.0)
		_:
			# Content: calm dot eyes and a small nose.
			draw_circle(center + Vector2(-5, -2) * s, 2.0 * s, dark)
			draw_circle(center + Vector2(5, -2) * s, 2.0 * s, dark)
			draw_circle(center + Vector2(0, 5) * s, 3.0 * s, dark)


func _draw_emote(screen_x: float, top_y: float) -> void:
	# A short comic call-out above the cab so the mood reads at a glance.
	# Content stays quiet — only the notable moods speak up.
	var text := ""
	var tint := Color("#2c2620")
	match passenger_state:
		"annoyed":
			text = "Oof!"
			tint = Color("#b4472e")
		"delighted":
			text = "Wheee!"
			tint = Color("#2f7d4f")
	if text.is_empty():
		return
	draw_string(ThemeDB.fallback_font, Vector2(screen_x - 40.0, top_y), text, HORIZONTAL_ALIGNMENT_CENTER, 80.0, 20, tint)


func _on_drive_down() -> void:
	drive_pressed = true


func _on_drive_up() -> void:
	drive_pressed = false


func _on_brake_down() -> void:
	brake_pressed = true


func _on_brake_up() -> void:
	brake_pressed = false


func _reset_run() -> void:
	var lvl: Dictionary = Levels.get_level(GameState.current_level)
	track_len = lvl.get("length", 2050.0)
	track_rough = lvl.get("rough", 1.0)
	track_phase = lvl.get("phase", 0.0)
	track_freq = lvl.get("freq", 1.0)
	route = []
	for node in lvl.get("route", DEFAULT_ROUTE):
		if not FUEL_ENABLED and node["type"] == "fuel":
			continue
		route.append({"type": node["type"], "x": float(node["at"]) * track_len})
	nodes_used = {}

	passengers = GameState.loadout_animals.duplicate()
	load_factor = GameState.load_factor()
	has_cage = "divided_cage" in GameState.loadout_equipment
	has_trailer = GameState.loadout_trailer
	vehicle_data = Vehicles.get_data(GameState.current_vehicle())
	veh_max_speed = vehicle_data["max_speed"]
	veh_accel = vehicle_data["acceleration"]
	veh_start_fuel = vehicle_data["start_fuel"]
	veh_fuel_per_px = vehicle_data["fuel_per_px"]
	vehicle_x = 100.0
	speed = 0.0
	fuel = veh_start_fuel
	body_y = terrain_y(vehicle_x) - REST_HEIGHT
	cam_y = terrain_y(vehicle_x)
	body_vy = 0.0
	comfort = COMFORT_MAX
	passenger_state = "content"
	ever_annoyed = false
	ever_delighted = false
	is_loaded = false
	loading = false
	load_t = 0.0
	finish_hold = 0.0
	advancing = false
	drive_pressed = false
	brake_pressed = false
	finished = false
	fuel_label.text = ("Fuel: %d%%   Speed: 0" % roundi(veh_start_fuel)) if FUEL_ENABLED else "Speed: 0"
	message_label.text = "Press DRIVE to coax %s aboard onto the %s." % [_crew_label(), Vehicles.display_name(GameState.current_vehicle())]
	queue_redraw()
