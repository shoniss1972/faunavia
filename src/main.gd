extends Control

const TRACK_LENGTH := 2200.0
const FUEL_PICKUP_X := 1050.0
const FINISH_X := 2050.0
const MAX_SPEED := 260.0
const ACCELERATION := 150.0
const BRAKING := 260.0
const COAST_DRAG := 52.0
const FUEL_DRAIN := 5.5
const REST_HEIGHT := 25.0
const SUSPENSION_STIFFNESS := 90.0
const SUSPENSION_DAMPING := 11.0

# One passenger for now. Mass is a 0..1 dial: 0 is an empty cab, 1 is a
# vehicle-straining load. It feeds handling, fuel use, and suspension sag
# so the animal's weight is felt, not just labelled.
const PASSENGER_NAME := "Wombat"
const PASSENGER_MASS := 0.5
const ACCEL_MASS_PENALTY := 0.45   # fraction of acceleration lost at mass 1.0
const FUEL_MASS_PENALTY := 0.6     # extra fuel drain at mass 1.0
const SAG_PER_MASS := 14.0         # extra pixels the body sags at mass 1.0
const LOAD_TIME := 1.4             # seconds the reluctant passenger takes to clamber aboard

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
var is_loaded := false
var loading := false
var load_t := 0.0


func _ready() -> void:
	set_process(true)
	_reset_run()


func _process(delta: float) -> void:
	if finished:
		_update_suspension(delta)
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
		var accel := ACCELERATION * (1.0 - PASSENGER_MASS * ACCEL_MASS_PENALTY)
		var drain := FUEL_DRAIN * (1.0 + PASSENGER_MASS * FUEL_MASS_PENALTY)
		speed = min(speed + accel * delta, MAX_SPEED)
		fuel = max(fuel - drain * delta, 0.0)
	elif braking:
		speed = max(speed - BRAKING * delta, 0.0)
	else:
		speed = max(speed - COAST_DRAG * delta, 0.0)

	if fuel <= 0.0:
		speed = max(speed - BRAKING * delta, 0.0)
		message_label.text = "Out of fuel — coast if you can, or reset."

	vehicle_x = min(vehicle_x + speed * delta, TRACK_LENGTH)

	if not fuel_collected and abs(vehicle_x - FUEL_PICKUP_X) < 42.0:
		fuel_collected = true
		fuel = min(fuel + 55.0, 100.0)
		message_label.text = "Fuel collected. Keep going!"

	if vehicle_x >= FINISH_X:
		finished = true
		speed = 0.0
		passenger_state = "delighted"
		message_label.text = "%s made it to the sanctuary, thrilled!" % PASSENGER_NAME

	_update_suspension(delta)
	_update_comfort(delta)

	fuel_label.text = "Fuel: %d%%   Speed: %d" % [roundi(fuel), roundi(speed)]
	queue_redraw()


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
			message_label.text = "%s aboard! Reach the sanctuary — mind the fuel." % PASSENGER_NAME
	elif drive_requested:
		loading = true
		load_t = 0.0
		message_label.text = "Coaxing %s aboard..." % PASSENGER_NAME


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
	var rest_target := terrain_y(vehicle_x) - REST_HEIGHT + PASSENGER_MASS * SAG_PER_MASS
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
	# A simple critter peeking out of the cab window. Drawn in body space,
	# so it rides and sags with the suspension. Its face acts out the current
	# comfort mood: content, annoyed, or delighted. y_offset drops it down into
	# the seat during the boarding animation.
	var off := Vector2(0.0, y_offset)
	var fur := Color("#7d6f63")
	var dark := Color("#2c2620")
	draw_circle(Vector2(-11, -50) + off, 5, fur)
	draw_circle(Vector2(9, -50) + off, 5, fur)
	draw_circle(Vector2(-1, -40) + off, 13, fur)

	match passenger_state:
		"annoyed":
			# Furrowed brows sloping in, dot eyes, a flat set mouth.
			draw_line(Vector2(-9, -47) + off, Vector2(-3, -44) + off, dark, 1.6)
			draw_line(Vector2(6, -47) + off, Vector2(0, -44) + off, dark, 1.6)
			draw_circle(Vector2(-6, -42) + off, 2.0, dark)
			draw_circle(Vector2(3, -42) + off, 2.0, dark)
			draw_line(Vector2(-4, -33) + off, Vector2(2, -33) + off, dark, 1.6)
		"delighted":
			# Squinting happy eyes and a wide open grin.
			draw_arc(Vector2(-6, -42) + off, 3.0, 0.0, PI, 6, dark, 2.0)
			draw_arc(Vector2(3, -42) + off, 3.0, 0.0, PI, 6, dark, 2.0)
			draw_arc(Vector2(-1, -36) + off, 4.0, 0.0, PI, 8, dark, 2.0)
		_:
			# Content: calm dot eyes and a small nose.
			draw_circle(Vector2(-6, -42) + off, 2.0, dark)
			draw_circle(Vector2(4, -42) + off, 2.0, dark)
			draw_circle(Vector2(-1, -35) + off, 3.0, dark)


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
	vehicle_x = 100.0
	speed = 0.0
	fuel = 62.0
	body_y = terrain_y(vehicle_x) - REST_HEIGHT
	body_vy = 0.0
	comfort = COMFORT_MAX
	passenger_state = "content"
	is_loaded = false
	loading = false
	load_t = 0.0
	drive_pressed = false
	brake_pressed = false
	fuel_collected = false
	finished = false
	fuel_label.text = "Fuel: 62%   Speed: 0"
	message_label.text = "Press DRIVE to coax %s aboard." % PASSENGER_NAME
	queue_redraw()
