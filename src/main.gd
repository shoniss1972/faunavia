extends Control

const TRACK_LENGTH := 2200.0
const FUEL_PICKUP_X := 1050.0
const FINISH_X := 2050.0
const MAX_SPEED := 260.0
const ACCELERATION := 150.0
const BRAKING := 260.0
const COAST_DRAG := 52.0
const FUEL_DRAIN := 5.5

@onready var fuel_label: Label = %FuelLabel
@onready var message_label: Label = %MessageLabel

var vehicle_x := 100.0
var speed := 0.0
var fuel := 100.0
var drive_pressed := false
var brake_pressed := false
var fuel_collected := false
var finished := false


func _ready() -> void:
	set_process(true)
	_reset_run()


func _process(delta: float) -> void:
	if finished:
		queue_redraw()
		return

	var driving := drive_pressed or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
	var braking := brake_pressed or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)

	if driving and fuel > 0.0:
		speed = min(speed + ACCELERATION * delta, MAX_SPEED)
		fuel = max(fuel - FUEL_DRAIN * delta, 0.0)
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
		message_label.text = "Sanctuary reached — driving toy complete!"

	fuel_label.text = "Fuel: %d%%   Speed: %d" % [roundi(fuel), roundi(speed)]
	queue_redraw()


func terrain_y(world_x: float) -> float:
	return 790.0 + sin(world_x * 0.007) * 75.0 + sin(world_x * 0.018) * 28.0


func _draw() -> void:
	var camera_x := clamp(vehicle_x - 220.0, 0.0, TRACK_LENGTH - size.x)

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
	var y := terrain_y(vehicle_x) - 25.0
	var slope := terrain_y(vehicle_x + 18.0) - terrain_y(vehicle_x - 18.0)
	var angle := atan2(slope, 36.0)

	draw_set_transform(Vector2(x, y), angle, Vector2.ONE)
	draw_rect(Rect2(-48, -28, 96, 32), Color("#d9824b"), true)
	draw_rect(Rect2(-22, -52, 43, 25), Color("#f2d7a8"), true)
	draw_rect(Rect2(24, -43, 32, 38), Color("#596b52"), false, 5.0)
	draw_circle(Vector2(-30, 11), 16, Color("#30352f"))
	draw_circle(Vector2(32, 11), 16, Color("#30352f"))
	draw_circle(Vector2(-30, 11), 7, Color("#b8b6a8"))
	draw_circle(Vector2(32, 11), 7, Color("#b8b6a8"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
	drive_pressed = false
	brake_pressed = false
	fuel_collected = false
	finished = false
	fuel_label.text = "Fuel: 62%   Speed: 0"
	message_label.text = "Reach the sanctuary. Pick up fuel on the way."
	queue_redraw()
