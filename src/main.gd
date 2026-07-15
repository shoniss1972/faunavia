extends Control

const TRACK_LENGTH := 2200.0
const FUEL_PICKUP_X := 1050.0
const FINISH_X := 2050.0
const MAX_SPEED := 260.0
const ACCELERATION := 150.0
const BRAKING := 260.0
const COAST_DRAG := 52.0
const FUEL_PER_PX := 0.012          # fuel burned per pixel travelled at zero load
const START_FUEL := 55.0
const FUEL_PICKUP_AMOUNT := 45.0
const REST_HEIGHT := 25.0
const SUSPENSION_STIFFNESS := 90.0
const SUSPENSION_DAMPING := 11.0

# The passengers ride from the prepared loadout. Their combined weight, as a
# 0..1 load factor from GameState, feeds handling, fuel use, and suspension sag
# so the cargo is felt, not just labelled.
const ACCEL_MASS_PENALTY := 0.45   # fraction of acceleration lost at load 1.0
const FUEL_MASS_PENALTY := 3.3     # multiplies fuel burn per pixel at load 1.0
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
var fuel_collected := false
var finished := false
var body_y := 0.0
var body_vy := 0.0
var comfort := COMFORT_MAX
var passenger_state := "content"
var passengers: Array[String] = []
var load_factor := 0.5
var has_cage := false
var is_loaded := false
var loading := false
var load_t := 0.0
var finish_hold := 0.0
var advancing := false

const FINISH_HOLD_TIME := 2.0   # seconds to celebrate arrival before moving on


func _ready() -> void:
	set_process(true)
	_reset_run()


func _process(delta: float) -> void:
	if advancing:
		return
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
		var accel := ACCELERATION * (1.0 - load_factor * ACCEL_MASS_PENALTY)
		speed = min(speed + accel * delta, MAX_SPEED)
	elif braking:
		speed = max(speed - BRAKING * delta, 0.0)
	else:
		speed = max(speed - COAST_DRAG * delta, 0.0)

	if fuel <= 0.0:
		speed = max(speed - BRAKING * delta, 0.0)
		message_label.text = "Out of fuel — coast if you can, or reset."

	# Fuel is a range meter: distance travelled burns fuel, and a heavier load
	# burns more per pixel. Speed is a comfort concern, not a fuel one.
	var dist := speed * delta
	fuel = max(fuel - FUEL_PER_PX * (1.0 + load_factor * FUEL_MASS_PENALTY) * dist, 0.0)
	vehicle_x = min(vehicle_x + dist, TRACK_LENGTH)

	if not fuel_collected and abs(vehicle_x - FUEL_PICKUP_X) < 42.0:
		fuel_collected = true
		fuel = min(fuel + FUEL_PICKUP_AMOUNT, 100.0)
		message_label.text = "Fuel collected. Keep going!"

	if vehicle_x >= FINISH_X:
		finished = true
		speed = 0.0
		passenger_state = "delighted"
		var tail := "Preparing next mission..." if GameState.has_more_levels() else "That was the last rescue!"
		message_label.text = "Delivered %s! %s" % [_crew_label(), tail]

	_update_suspension(delta)
	_update_comfort(delta)

	fuel_label.text = "Fuel: %d%%   Speed: %d" % [roundi(fuel), roundi(speed)]
	_update_fuel_colour()
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
	elif comfort >= COMFORT_DELIGHTED and speed > 120.0:
		passenger_state = "delighted"
	else:
		passenger_state = "content"


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
	# The mission is delivered. Move to the next level's prep, or mark the
	# campaign complete after the last one, then return to the prep screen.
	advancing = true
	if GameState.has_more_levels():
		GameState.advance_level()
	else:
		GameState.campaign_done = true
	get_tree().change_scene_to_file("res://src/prep.tscn")


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
	return 790.0 + sin(world_x * 0.007) * 75.0 + sin(world_x * 0.018) * 28.0


func _draw() -> void:
	var camera_x: float = clamp(vehicle_x - 220.0, 0.0, TRACK_LENGTH - size.x)

	# Sky and distant hills.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#dcefd8"))
	var distant := PackedVector2Array([Vector2(0, 760)])
	for screen_x in range(0, int(size.x) + 20, 20):
		var world_x := camera_x * 0.35 + screen_x
		distant.append(Vector2(screen_x, 650.0 + sin(world_x * 0.004) * 60.0))
	distant.append(Vector2(size.x, 900))
	draw_colored_polygon(distant, Color("#a8c99b"))

	# Main terrain.
	var ground := PackedVector2Array([Vector2(0, size.y)])
	for screen_x in range(-20, int(size.x) + 40, 12):
		var world_x := camera_x + screen_x
		ground.append(Vector2(screen_x, terrain_y(world_x)))
	ground.append(Vector2(size.x, size.y))
	draw_colored_polygon(ground, Color("#78945e"))

	_draw_marker(FUEL_PICKUP_X, camera_x, "FUEL", Color("#efb64d"), not fuel_collected)
	_draw_marker(FINISH_X, camera_x, "SANCTUARY", Color("#6b9c72"), true)
	_draw_vehicle(camera_x)


func _draw_marker(world_x: float, camera_x: float, label_text: String, marker_color: Color, visible_marker: bool) -> void:
	if not visible_marker:
		return
	var x := world_x - camera_x
	if x < -80.0 or x > size.x + 80.0:
		return
	var y := terrain_y(world_x)
	draw_line(Vector2(x, y), Vector2(x, y - 110), Color("#3d4b38"), 7.0)
	draw_rect(Rect2(x - 45, y - 145, 90, 42), marker_color, true)
	draw_string(ThemeDB.fallback_font, Vector2(x - 38, y - 117), label_text, HORIZONTAL_ALIGNMENT_CENTER, 76, 15, Color("#263127"))


func _draw_vehicle(camera_x: float) -> void:
	var x := vehicle_x - camera_x
	var slope := terrain_y(vehicle_x + 18.0) - terrain_y(vehicle_x - 18.0)
	var angle := atan2(slope, 36.0)
	var ground_y := terrain_y(vehicle_x)

	# Wheels stay planted on the ground and follow the slope.
	draw_set_transform(Vector2(x, ground_y - 11.0), angle, Vector2.ONE)
	draw_circle(Vector2(-30, 0), 16, Color("#30352f"))
	draw_circle(Vector2(32, 0), 16, Color("#30352f"))
	draw_circle(Vector2(-30, 0), 7, Color("#b8b6a8"))
	draw_circle(Vector2(32, 0), 7, Color("#b8b6a8"))

	# Body rides on the suspension, bobbing relative to the wheels.
	draw_set_transform(Vector2(x, body_y), angle, Vector2.ONE)
	draw_rect(Rect2(-48, -28, 96, 32), Color("#d9824b"), true)
	draw_rect(Rect2(-22, -52, 43, 25), Color("#f2d7a8"), true)
	_draw_passenger(_passenger_load_offset())
	draw_rect(Rect2(24, -43, 32, 38), Color("#596b52"), false, 5.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if loading:
		draw_string(ThemeDB.fallback_font, Vector2(x - 45.0, body_y - 58.0), _load_line(), HORIZONTAL_ALIGNMENT_CENTER, 90.0, 18, Color("#8a5a2b"))
	elif is_loaded:
		_draw_emote(x, body_y - 58.0)


func _passenger_load_offset() -> float:
	# How far below its seat the passenger sits while boarding. It starts low,
	# mostly hidden behind the cab, then clambers up to zero as loading finishes.
	if is_loaded:
		return 0.0
	if loading:
		var p := clampf(load_t / LOAD_TIME, 0.0, 1.0)
		return pow(1.0 - p, 3) * 26.0
	return 26.0


func _draw_passenger(y_offset: float) -> void:
	# The loaded animals ride in the cab, drawn in body space so they bob and
	# sag with the suspension. y_offset drops them into their seats during the
	# boarding animation. A single passenger sits high in the cab window; a crew
	# spreads across the bed.
	var n := passengers.size()
	if n == 0:
		return
	var off := Vector2(0.0, y_offset)
	if n == 1:
		_draw_critter(Vector2(-1.0, -40.0) + off, 13.0, _fur(passengers[0]))
		return
	for i in n:
		var fx := lerpf(-32.0, 12.0, float(i) / float(n - 1))
		_draw_critter(Vector2(fx, -38.0) + off, 11.0, _fur(passengers[i]))
	if has_cage:
		# A divider bar between the animals — the divided cage keeping the peace.
		var bar_x := lerpf(-32.0, 12.0, 0.5)
		draw_line(Vector2(bar_x, -50.0) + off, Vector2(bar_x, -22.0) + off, Color("#4a4f45"), 3.0)


func _fur(id: String) -> Color:
	return Color(Animals.get_data(id).get("colour", "#7d6f63"))


func _draw_critter(center: Vector2, radius: float, colour: Color) -> void:
	# One animal head with ears and a mood-driven face. All feature offsets are
	# scaled from the reference radius so crews of smaller heads stay proportioned.
	var s := radius / 13.0
	var dark := Color("#2c2620")
	draw_circle(center + Vector2(-10, -10) * s, 5.0 * s, colour)
	draw_circle(center + Vector2(10, -10) * s, 5.0 * s, colour)
	draw_circle(center, radius, colour)

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
	passengers = GameState.loadout_animals.duplicate()
	load_factor = GameState.load_factor()
	has_cage = "divided_cage" in GameState.loadout_equipment
	vehicle_x = 100.0
	speed = 0.0
	fuel = START_FUEL
	body_y = terrain_y(vehicle_x) - REST_HEIGHT
	body_vy = 0.0
	comfort = COMFORT_MAX
	passenger_state = "content"
	is_loaded = false
	loading = false
	load_t = 0.0
	finish_hold = 0.0
	advancing = false
	drive_pressed = false
	brake_pressed = false
	fuel_collected = false
	finished = false
	fuel_label.text = "Fuel: %d%%   Speed: 0" % roundi(START_FUEL)
	message_label.text = "Press DRIVE to coax %s aboard." % _crew_label()
	queue_redraw()
