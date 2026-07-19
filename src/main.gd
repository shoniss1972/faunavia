extends Control

const TRACK_BUFFER := 160.0          # ground drawn past the sanctuary
const SPEED_TO_MPH := 0.1            # internal units -> a readable mph (truck tops ~30,
									 # a sane pace over hilly wildlife-park ground)
const BRAKING := 260.0
const COAST_DRAG := 52.0
const FUEL_PICKUP_AMOUNT := 45.0
const FOOD_COMFORT := 40.0           # comfort restored at a food store
const REST_HEIGHT := 25.0

# The fuel mechanic. When false: no drain, never runs out, no fuel readout, and
# fuel stops are omitted from routes. When true: distance burns fuel (heavier loads
# faster), the readout shows a range meter, and fuel stops top it up.
const FUEL_ENABLED := true

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
# The vehicle's body box, as fractions of body width. The cab is shared with the
# seating below: passengers ride the bed BEHIND it, so the cab frame never lands
# across a face. Keep these two in agreement — that is the point of sharing them.
const CAB_X := 0.25                # where the cab frame begins
const CAB_W := 0.33                # how wide the cab frame is

# Passenger seating, solved from the body box so new vehicles need no new
# numbers: give the bed's two edges and the crew size, and the layout follows.
const SEAT_BACK := 0.44            # the bed's back edge, behind body centre
const SOLO_HEAD := 0.40            # lone passenger head radius, as a fraction of body height
const HEAD_W_PER_RADIUS := 3.5     # nominal sprite width in units of drawn radius
const HEAD_SPACING := 0.75         # gap between head centres, as a fraction of head width
const MIN_HEAD := 5.0              # never shrink a head below this, even when crowded
const MAX_HEAD := 11.0             # nor grow one past this — else a big, near-empty
								   # truck bed balloons the animals vs smaller vehicles

const SUSPENSION_STIFFNESS := 90.0
const SUSPENSION_DAMPING := 11.0

# The passengers ride from the prepared loadout. Their combined weight, as a
# 0..1 load factor from GameState, feeds handling, fuel use, and suspension sag
# so the cargo is felt, not just labelled.
const ACCEL_MASS_PENALTY := 0.45   # fraction of acceleration lost at load 1.0
const FUEL_MASS_PENALTY := 2.4     # multiplies fuel burn per pixel at load 1.0
const SAG_PER_MASS := 14.0         # extra pixels the body sags at load 1.0
const LOAD_TIME := 1.4             # seconds the reluctant crew takes to clamber aboard

# Comfort is a 0..100 mood EACH passenger builds from how the ride feels. Hard
# suspension jolts drain it; smooth travel restores it. The value is never shown
# as a number — it drives the animal's face, and at zero the animal bails off the
# truck. Every animal shares the same suspension jolt but drains at its own rate
# (see TEMPERAMENT_SENSITIVITY), so a crew reacts as individuals: the timid rabbit
# frets and leaps long before the placid wombat is bothered.
const COMFORT_MAX := 100.0
const COMFORT_JOLT_THRESHOLD := 58.0   # |body_vy| below this counts as a smooth ride
const COMFORT_LOSS_RATE := 0.7         # comfort lost per unit of jolt-over-threshold, per second
const COMFORT_RECOVERY := 18.0         # comfort regained per second on smooth travel
const COMFORT_ANNOYED := 40.0          # at or below this the passenger is annoyed
const COMFORT_DELIGHTED := 80.0        # at or above this, and moving well, it is delighted
const COMFORT_PANIC := 18.0            # at or below this it is on the verge of bailing (telegraph)

# How fast each temperament sheds comfort, as a multiplier on the drain rate. The
# words come from Animals.DATA; a timid animal is twice as fragile as a placid one.
const TEMPERAMENT_SENSITIVITY := {
	"timid": 1.7,     # rabbit — nervous, bolts first
	"loud": 1.3,      # parrot — dramatic
	"sly": 1.0,       # fox — average
	"stubborn": 0.9,  # goat — complains but digs in
	"slow": 0.7,      # tortoise — serene
	"placid": 0.55,   # wombat — barely notices
}

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
var _critter_art := {}   # "<id>_<mood>" -> Texture2D, filled on first draw
var cam_y := 0.0         # smoothed terrain height the camera tracks
var _cam := Vector2.ZERO # world point at the screen's top-left, set each frame
var anim_t := 0.0        # free-running clock for ambient motion (bird wingbeats)
var jolt_cd := 0.0       # cooldown so one bump plays one thud, not a burst
var warn_cd := 0.0       # cooldown for the repeating "about to jump" chirp
var passengers: Array[String] = []
# Per-passenger state, all parallel to `passengers` and (re)built in _reset_run.
var comforts: Array[float] = []       # 0..100 mood
var states: Array[String] = []        # "content" / "annoyed" / "delighted"
var ever_annoyed: Array[bool] = []    # did this animal ever drop to annoyed — for scoring
var bailed: Array[bool] = []          # has it leapt off the truck
var bail_t: Array[float] = []         # seconds since it bailed, for the leaving animation
var load_factor := 0.5
var has_cage := false
var has_trailer := false
var vehicle_data := {}
var veh_max_speed := 260.0
var veh_accel := 150.0
var veh_start_fuel := 55.0
var veh_fuel_per_px := 0.012
var veh_ride := 1.0                   # per-vehicle jolt multiplier (milestone 6)
var is_loaded := false
var loading := false
var load_t := 0.0
var finish_hold := 0.0
var advancing := false
var relief_t := 0.0                    # seconds of visible relief after a food/vet stop
var stop_saved_idx: Array[int] = []    # passengers a stop pulled back from the brink

const FINISH_HOLD_TIME := 2.0   # seconds to celebrate arrival before moving on
const RELIEF_TIME := 1.8        # how long the crew visibly perks up after a stop


func _ready() -> void:
	set_process(true)
	Audio.start_music()
	_reset_run()


func _exit_tree() -> void:
	Audio.stop_engine()


func _update_camera(delta: float) -> void:
	# Settle the camera onto the terrain under the vehicle. Smoothed, so cresting
	# a hill pans the view instead of snapping it — an abrupt camera would read as
	# a jolt the player did not cause, which is exactly the signal comfort uses.
	cam_y = lerpf(cam_y, terrain_y(vehicle_x), 1.0 - exp(-CAM_FOLLOW * delta))


func _process(delta: float) -> void:
	if advancing:
		return
	anim_t += delta
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

	if relief_t > 0.0:
		relief_t = max(relief_t - delta, 0.0)

	_update_suspension(delta)
	_update_comfort(delta)
	_update_audio(delta)

	if FUEL_ENABLED:
		fuel_label.text = "Fuel: %d%%   %d mph" % [roundi(fuel), roundi(speed * SPEED_TO_MPH)]
		_update_fuel_colour()
	else:
		fuel_label.text = "%d mph" % roundi(speed * SPEED_TO_MPH)
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
	# Each passenger reads the ride through the shared suspension: a sharp jolt
	# drains its comfort at a rate set by temperament, calm travel lets it recover.
	# Comfort selects the mood the animal wears, and reaching zero bails it off.
	# The vehicle's ride quality scales how hard each jolt lands: the truck soaks
	# bumps up (ride < 1), the trike rattles (ride > 1) — see milestone 6.
	var jolt := absf(body_vy) * veh_ride
	var over := jolt - COMFORT_JOLT_THRESHOLD
	for i in passengers.size():
		if bailed[i]:
			bail_t[i] += delta
			continue
		var sens: float = TEMPERAMENT_SENSITIVITY.get(Animals.get_data(passengers[i]).get("temperament", ""), 1.0)
		if over > 0.0:
			comforts[i] -= over * COMFORT_LOSS_RATE * sens * delta
		else:
			comforts[i] += COMFORT_RECOVERY * delta
		comforts[i] = clampf(comforts[i], 0.0, COMFORT_MAX)

		if comforts[i] <= 0.0:
			_bail_animal(i)
			continue
		# Just after a food/vet stop the whole crew visibly perks up, so the lifeline
		# reads as a felt relief and not just a line of text (milestone 8).
		if relief_t > 0.0:
			states[i] = "delighted"
		elif comforts[i] <= COMFORT_ANNOYED:
			states[i] = "annoyed"
			ever_annoyed[i] = true
		elif comforts[i] >= COMFORT_DELIGHTED and speed > 120.0:
			states[i] = "delighted"
		else:
			states[i] = "content"


func _update_audio(delta: float) -> void:
	# Runs only on the active drive (after loading, before arrival). Holds the motor
	# under the vehicle, thuds on a real bump, and chirps a warning while a
	# passenger is on the brink — the audible half of the comfort read.
	jolt_cd = maxf(jolt_cd - delta, 0.0)
	warn_cd = maxf(warn_cd - delta, 0.0)
	Audio.engine(speed, veh_max_speed, String(vehicle_data.get("shape", "jeep")))

	var jolt := absf(body_vy) * veh_ride
	if jolt > COMFORT_JOLT_THRESHOLD + 8.0 and jolt_cd <= 0.0:
		var strength := clampf((jolt - COMFORT_JOLT_THRESHOLD) / 60.0, 0.0, 1.0)
		Audio.play("jolt", lerpf(-22.0, -7.0, strength), 0.9 + strength * 0.35)
		jolt_cd = 0.18

	if warn_cd <= 0.0:
		for i in passengers.size():
			if not bailed[i] and comforts[i] <= COMFORT_PANIC:
				Audio.play("warn", -12.0)
				warn_cd = 0.6
				break


func _bail_animal(index: int) -> void:
	# Pushed past its limit, the animal leaps off and trots back down the road. It
	# no longer counts as delivered; the run carries on with whoever is left.
	bailed[index] = true
	bail_t[index] = 0.0
	comforts[index] = 0.0
	states[index] = "annoyed"
	Audio.play("bail", -6.0)
	Audio.play_voice(passengers[index], -5.0, 1.08)
	message_label.text = "%s had enough and jumped off!" % Animals.display_name(passengers[index])


func _active_passengers() -> int:
	var n := 0
	for i in passengers.size():
		if not bailed[i]:
			n += 1
	return n


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
				Audio.stop_engine()
				for i in passengers.size():
					if not bailed[i]:
						states[i] = "delighted"
				var delivered_ok := _active_passengers() > 0
				Audio.play("sanctuary" if delivered_ok else "warn", -5.0)
				var tail := "Preparing next mission..." if GameState.has_more_levels() else "That was the last rescue!"
				var delivered := _active_passengers()
				if delivered == 0:
					message_label.text = "Arrived with an empty truck. %s" % tail
				elif delivered < passengers.size():
					message_label.text = "Delivered %d of %d. %s" % [delivered, passengers.size(), tail]
				else:
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
				# A top-up: lifts spirits, and can pull a fretting animal back from
				# the brink if you reach it before it bails.
				var rescued := _restore_comfort(FOOD_COMFORT)
				relief_t = RELIEF_TIME
				Audio.play("munch", -8.0)
				if rescued != "":
					Audio.play("rescue", -6.0)
				message_label.text = ("Fed the crew — steadied %s just in time!" % rescued) if rescued != "" else "Fed the crew — spirits lift."
			"vet":
				# A full reset: everyone still aboard is calmed completely.
				var vet_saved := _restore_comfort(COMFORT_MAX)
				relief_t = RELIEF_TIME
				Audio.play("vet", -7.0)
				if vet_saved != "":
					Audio.play("rescue", -6.0)
				message_label.text = "Vet check — everyone's calm again."


func _restore_comfort(amount: float) -> String:
	# Top up every animal still aboard. Records every animal that was on the verge
	# of bailing (so the result screen can credit the stop), and returns the first
	# such name for the on-pass message — empty if none was in danger.
	var saved := ""
	for i in passengers.size():
		if bailed[i]:
			continue
		if comforts[i] <= COMFORT_PANIC:
			if saved == "":
				saved = Animals.display_name(passengers[i])
			if i not in stop_saved_idx:
				stop_saved_idx.append(i)
		comforts[i] = min(comforts[i] + amount, COMFORT_MAX)
	return saved


func _update_loading(delta: float, drive_requested: bool) -> void:
	# The run does not begin until the passenger is aboard. The first drive
	# request coaxes the reluctant animal, who grumbles its way in over a beat.
	if loading:
		load_t += delta
		if load_t >= LOAD_TIME:
			loading = false
			is_loaded = true
			for i in states.size():
				states[i] = "content"
			Audio.boarded(passengers)
			message_label.text = "%s aboard! Reach the sanctuary — mind the ride." % _crew_label().capitalize()
	elif drive_requested:
		loading = true
		load_t = 0.0
		message_label.text = "Coaxing %s aboard..." % _crew_label()


func _crew_label() -> String:
	if passengers.size() == 1:
		return Animals.display_name(passengers[0])
	return "the crew"


func _advance_after_delivery() -> void:
	# Score the run from who actually arrived, record it (which unlocks the next
	# level and saves), then return to the level select. Stars:
	#   0 — nobody made it (everyone bailed)
	#   1 — arrived short, at least one animal jumped off
	#   2 — the whole crew arrived, but someone spent the trip annoyed
	#   3 — the whole crew arrived and none was ever annoyed (a smooth run)
	advancing = true
	var total := passengers.size()
	var delivered := _active_passengers()
	var earned := 0
	if delivered == 0:
		earned = 0
	elif delivered < total:
		earned = 1
	else:
		earned = 2
		var smooth := true
		for i in total:
			if ever_annoyed[i]:
				smooth = false
				break
		if smooth:
			earned = 3

	# Hand the run's per-passenger outcome to the result screen so it can explain
	# the rating and give a hint pointed at what actually went wrong.
	var roster: Array = []
	for i in total:
		roster.append({
			"id": passengers[i],
			"name": Animals.display_name(passengers[i]),
			"arrived": not bailed[i],
			"rattled": ever_annoyed[i],
		})
	# Credit any lifeline stop that pulled an animal back from the brink — but only
	# if that animal actually arrived (a later bail cancels the save it earned).
	var saved_by_stop: Array = []
	for i in stop_saved_idx:
		if not bailed[i]:
			saved_by_stop.append(Animals.display_name(passengers[i]))
	var detail := {
		"level": GameState.current_level,
		"earned": earned,
		"total": total,
		"delivered": delivered,
		"passengers": roster,
		"saved_by_stop": saved_by_stop,
	}
	GameState.record_result(GameState.current_level, earned, detail)
	get_tree().change_scene_to_file("res://src/result.tscn")


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
	#
	# Long levels need variety, or one repeating hill reads as monotony. Three
	# layers give that without a level editor:
	#   roll — big, slow, gentle landscape swells (a sense of travel; barely bumpy)
	#   env  — a slow envelope on the bumpiness, so roughness ebbs and flows into
	#          calm passages and rough ridges instead of a uniform buzz
	#   bumps — three incommensurate ripples so the pattern doesn't obviously loop
	var t := world_x + track_phase
	var roll := sin(t * 0.0013) * 55.0 + sin(t * 0.00061 + 1.7) * 34.0
	var env := 0.78 + 0.32 * sin(t * 0.00089 + track_phase * 0.01)
	var bumps := (sin(t * 0.007 * track_freq) * 72.0 \
		+ sin(t * 0.018 * track_freq) * 27.0 \
		+ sin(t * 0.011 * track_freq + 2.1) * 21.0) * track_rough * env
	return 790.0 + roll + bumps


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

	# Layered backdrop: a soft sky gradient, drifting clouds, and two parallax hill
	# bands pinned near the horizon so they read as distance rather than scaling up
	# with the zoom. All code-drawn and deterministic — no art pipeline.
	_draw_sky()
	_draw_clouds(camera_x)
	_draw_birds(camera_x)
	var horizon := _w2s(Vector2(0.0, cam_y)).y
	_draw_hills(camera_x, 0.35, horizon - 120.0, 60.0, 0.004, Color("#a8c99b"))
	_draw_hills(camera_x, 0.60, horizon - 74.0, 44.0, 0.006, Color("#8fb082"))

	# Main terrain.
	var ground := PackedVector2Array([Vector2(0, size.y)])
	for screen_x in range(-20, int(size.x) + 40, 12):
		var world_x := camera_x + float(screen_x) / WORLD_ZOOM
		ground.append(Vector2(screen_x, _w2s(Vector2(world_x, terrain_y(world_x))).y))
	ground.append(Vector2(size.x, size.y))
	draw_colored_polygon(ground, Color("#78945e"))

	# Roadside props rooted on the terrain. Their mix shifts with the track's
	# roughness — lush and leafy on gentle routes, rocky and sparse on rough ones —
	# so a route's character (e.g. Level 3's safe road vs shortcut) reads at a glance.
	_draw_ground_props(camera_x, view_w)

	for node in route:
		var style: Dictionary = NODE_STYLE.get(node["type"], NODE_STYLE["fuel"])
		# Every stop is a place — the sign, stall, pump, or building all stay put as
		# the vehicle passes through. What's *collected* is what disappears once used:
		# the food's veg is eaten, the fuel cans are hauled aboard. Both are handled
		# inside their own draw via `used`; the marker itself always stays.
		var used: bool = nodes_used.has(node["x"])
		_draw_marker(node["x"], node["type"], style["label"], Color(style["colour"]), true, used)
	_draw_trailer()
	_draw_vehicle()


func _rand01(seed_val: int) -> float:
	# Cheap deterministic hash → [0, 1). Stable per seed so scenery never flickers.
	var h := sin(float(seed_val) * 12.9898) * 43758.5453
	return h - floor(h)


func _draw_sky() -> void:
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(0, size.y)])
	var top := Color("#eaf5ec")
	var low := Color("#d3e7d6")
	draw_polygon(pts, PackedColorArray([top, top, low, low]))


func _cloud(center: Vector2, r: float) -> void:
	var c := Color(1, 1, 1, 0.5)
	draw_circle(center, r, c)
	draw_circle(center + Vector2(r * 0.9, r * 0.25), r * 0.72, c)
	draw_circle(center + Vector2(-r * 0.9, r * 0.28), r * 0.7, c)
	draw_circle(center + Vector2(0, -r * 0.35), r * 0.66, c)


func _draw_clouds(camera_x: float) -> void:
	# A few clouds drifting slowly against the camera, wrapped across the sky.
	var span := size.x + 240.0
	for i in range(5):
		var raw := float(i) * 300.0 + 90.0 - camera_x * 0.18
		var cx := fmod(fmod(raw, span) + span, span) - 120.0
		var cy := 46.0 + _rand01(i * 53 + 9) * 150.0
		_cloud(Vector2(cx, cy), 18.0 + _rand01(i * 7 + 3) * 16.0)


func _bird(center: Vector2, wing: float, col: Color) -> void:
	# A shallow "M" — two strokes rising to a peak, the wing height animated so the
	# bird flaps as it drifts. A small body dot at the peak anchors the shape.
	draw_line(center + Vector2(-12.0, 0.0), center + Vector2(-2.5, -wing), col, 2.4)
	draw_line(center + Vector2(2.5, -wing), center + Vector2(12.0, 0.0), col, 2.4)
	draw_circle(center + Vector2(0.0, -wing + 1.0), 1.8, col)


func _draw_birds(camera_x: float) -> void:
	# A few small flocks gliding against the camera, wrapped across the sky.
	# Deterministic anchors; wings flap on the free-running clock so they read as
	# alive even when the vehicle is stopped.
	var span := size.x + 260.0
	var col := Color(0.20, 0.23, 0.28, 0.9)
	# Kept in the open sky band below the status panel and above the hills.
	var band := clampf(_w2s(Vector2(0.0, cam_y)).y - 200.0, 60.0, size.y)
	for i in range(3):
		var raw := float(i) * 250.0 + 120.0 - camera_x * 0.24
		var fx := fmod(fmod(raw, span) + span, span) - 130.0
		var fy := 176.0 + _rand01(i * 41 + 6) * band * 0.5
		var flap := 5.5 + sin(anim_t * 5.0 + float(i) * 1.7) * 4.0
		_bird(Vector2(fx, fy + sin(anim_t * 0.9 + i) * 3.0), flap, col)
		_bird(Vector2(fx + 26.0, fy + 11.0 + sin(anim_t * 0.9 + i + 1.0) * 3.0), flap * 0.9, col)
		_bird(Vector2(fx - 22.0, fy + 9.0 + sin(anim_t * 0.9 + i + 2.0) * 3.0), flap * 0.85, col)


func _draw_hills(camera_x: float, parallax: float, y_base: float, amp: float, freq: float, colour: Color) -> void:
	var pts := PackedVector2Array([Vector2(0, size.y)])
	for screen_x in range(0, int(size.x) + 20, 20):
		var wx := camera_x * parallax + float(screen_x) / WORLD_ZOOM
		pts.append(Vector2(screen_x, y_base + sin(wx * freq) * amp))
	pts.append(Vector2(size.x, size.y))
	draw_colored_polygon(pts, colour)


func _draw_ground_props(camera_x: float, view_w: float) -> void:
	# Props sit at deterministic world positions on the terrain line and are drawn
	# in world scale (through the zoom) so they pass by with the ground. The type
	# mix tracks roughness: lush at gentle roughness, rocky and sparse when rough.
	const SPACING := 55.0
	var lush := clampf(1.0 - (track_rough - 0.5) / 0.85, 0.0, 1.0)
	var zoom := Vector2(WORLD_ZOOM, WORLD_ZOOM)
	var start_i := int(floor(camera_x / SPACING)) - 1
	var end_i := int(ceil((camera_x + view_w) / SPACING)) + 1
	for i in range(start_i, end_i):
		if _rand01(i * 3 + 1) > 0.5 + 0.15 * lush:
			continue  # gaps between props, a touch denser when lush
		var world_x := (float(i) + _rand01(i * 7 + 2)) * SPACING
		if world_x < 60.0 or world_x > track_len + TRACK_BUFFER - 40.0:
			continue
		var base := _w2s(Vector2(world_x, terrain_y(world_x)))
		if base.x < -60.0 or base.x > size.x + 60.0:
			continue
		draw_set_transform(base, 0.0, zoom)
		var pick := _rand01(i * 13 + 5)
		var scl := 0.8 + _rand01(i * 5 + 4) * 0.5
		if pick < 0.15 + (1.0 - lush) * 0.5:
			_prop_rock(scl)
		elif pick < 0.55 + 0.2 * lush:
			_prop_tree(scl)
		elif pick < 0.85:
			_prop_bush(scl)
		else:
			_prop_tuft(scl, lush, i)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _prop_tree(s: float) -> void:
	draw_rect(Rect2(-2.0 * s, -12.0 * s, 4.0 * s, 12.0 * s), Color("#6b5540"))
	draw_circle(Vector2(0, -16.0 * s), 9.0 * s, Color("#5f7d47"))
	draw_circle(Vector2(-5.0 * s, -12.0 * s), 6.5 * s, Color("#688a4d"))
	draw_circle(Vector2(5.0 * s, -12.0 * s), 6.5 * s, Color("#688a4d"))


func _prop_bush(s: float) -> void:
	draw_circle(Vector2(-5.0 * s, -4.0 * s), 6.5 * s, Color("#6f8a54"))
	draw_circle(Vector2(5.0 * s, -4.0 * s), 6.5 * s, Color("#6f8a54"))
	draw_circle(Vector2(0, -8.0 * s), 7.5 * s, Color("#77935b"))


func _prop_rock(s: float) -> void:
	draw_circle(Vector2(0, -4.0 * s), 6.0 * s, Color("#8f948a"))
	draw_circle(Vector2(3.0 * s, -3.0 * s), 4.0 * s, Color("#a1a69b"))
	draw_circle(Vector2(-4.0 * s, -2.5 * s), 3.5 * s, Color("#7f847a"))


func _prop_tuft(s: float, lush: float, seed_val: int) -> void:
	var blade := Color("#6d8a4e")
	for k in range(3):
		var bx := (float(k) - 1.0) * 3.0 * s
		draw_line(Vector2(bx, 0), Vector2(bx - 1.5 * s, -7.0 * s), blade, 1.5)
	if lush > 0.5 and _rand01(seed_val * 19 + 6) < 0.6:
		draw_circle(Vector2(0, -7.5 * s), 1.6 * s, Color("#e0c65c"))


func _draw_marker(world_x: float, node_type: String, label_text: String, marker_color: Color, visible_marker: bool, used := false) -> void:
	if not visible_marker:
		return
	var base := _w2s(Vector2(world_x, terrain_y(world_x)))
	if base.x < -220.0 or base.x > size.x + 220.0:
		return
	# Everything for a stop is drawn in world units through the camera transform, so
	# it grows with the zoom like the rest of the ground. draw_set_transform is
	# absolute (not stacked), so each stop keeps a single local frame: ground at
	# y = 0, up is negative y.
	draw_set_transform(base, 0.0, Vector2(WORLD_ZOOM, WORLD_ZOOM))
	var font := ThemeDB.fallback_font
	match node_type:
		"sanctuary":
			_draw_sanctuary(font)
		"food":
			_draw_signpost(label_text, marker_color, font)
			_draw_food_stall(used)
		"vet":
			_draw_signpost(label_text, marker_color, font)
			_draw_vet_stop()
		"fuel":
			_draw_signpost(label_text, marker_color, font)
			_draw_fuel_stop(used)
		_:
			_draw_signpost(label_text, marker_color, font)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_signpost(label_text: String, marker_color: Color, font: Font) -> void:
	draw_line(Vector2.ZERO, Vector2(0, -110), Color("#3d4b38"), 7.0)
	# Size the sign to the label so longer names don't truncate.
	var text_w := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	var sign_w := maxf(90.0, text_w + 24.0)
	draw_rect(Rect2(-sign_w * 0.5, -145, sign_w, 42), marker_color, true)
	draw_string(font, Vector2(-sign_w * 0.5 + 12.0, -117), label_text, HORIZONTAL_ALIGNMENT_CENTER, sign_w - 24.0, 15, Color("#263127"))


func _draw_food_stall(eaten: bool) -> void:
	# A crate at the foot of the FOOD sign. The crate stays put; its veg is only
	# drawn until the crew eats it (the stall isn't the meal — the veg is).
	draw_colored_polygon(PackedVector2Array([
		Vector2(-32, 0), Vector2(32, 0), Vector2(26, -22), Vector2(-26, -22)]),
		Color("#7a4a2b"))
	draw_line(Vector2(-28, -11), Vector2(28, -11), Color("#5e3a22"), 1.5)
	if eaten:
		return
	_draw_lettuce(Vector2(-16, -22))
	_draw_lettuce(Vector2(-1, -21))
	_draw_carrot(Vector2(14, -22))
	_draw_carrot(Vector2(20, -23))
	_draw_carrot(Vector2(26, -22))


func _draw_lettuce(p: Vector2) -> void:
	draw_circle(p, 7.0, Color("#5f9e49"))
	draw_circle(p + Vector2(-3, -2), 4.5, Color("#7fbc5e"))
	draw_circle(p + Vector2(3, -2), 4.5, Color("#7fbc5e"))
	draw_circle(p + Vector2(0, -3), 4.0, Color("#a3d982"))


func _draw_carrot(p: Vector2) -> void:
	# p is where the carrot pokes out of the crate; body tapers down, fronds up.
	var top := p.y - 12.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(p.x - 4, top), Vector2(p.x + 4, top), Vector2(p.x, p.y)]),
		Color("#e07a2e"))
	var ftop := Vector2(p.x, top)
	draw_line(ftop, ftop + Vector2(-3, -6), Color("#4e8f3a"), 1.5)
	draw_line(ftop, ftop + Vector2(0, -7), Color("#4e8f3a"), 1.5)
	draw_line(ftop, ftop + Vector2(3, -6), Color("#4e8f3a"), 1.5)


func _draw_fuel_stop(collected: bool) -> void:
	# A little pallet at the foot of the FUEL sign holding jerry cans. The pallet
	# stays put; the cans are the pickup, so they vanish once the vehicle fuels up.
	draw_rect(Rect2(-30, -6, 60, 6), Color("#6f5a3c"), true)              # pallet
	draw_line(Vector2(-30, -3), Vector2(30, -3), Color("#54462e"), 1.5)
	if collected:
		return
	_draw_fuel_can(Vector2(-13, -6))
	_draw_fuel_can(Vector2(9, -6))


func _draw_fuel_can(base: Vector2) -> void:
	# A red jerry can standing on the pallet: body, spout cap, handle, and an X
	# brace so it reads as a fuel container rather than a plain box. `base` is the
	# bottom-centre where the can sits.
	var body := Color("#c0392b")
	draw_rect(Rect2(base.x - 7, base.y - 19, 14, 19), body, true)         # body
	draw_rect(Rect2(base.x - 5, base.y - 23, 10, 4), Color("#8f271c"), true)  # cap plate
	draw_rect(Rect2(base.x + 2, base.y - 26, 3, 4), Color("#7a2018"), true)   # spout
	draw_line(base + Vector2(-4, -23), base + Vector2(4, -23), Color("#8f271c"), 2.0)  # handle
	draw_line(base + Vector2(-6, -17), base + Vector2(6, -3), Color("#e08b80"), 1.4)   # brace
	draw_line(base + Vector2(6, -17), base + Vector2(-6, -3), Color("#e08b80"), 1.4)


func _draw_vet_stop() -> void:
	# A vet nurse tending a small animal on a table beside the VET sign, so the stop
	# reads as care being given rather than a bare marker.
	draw_rect(Rect2(8, -26, 40, 4), Color("#cfcabe"), true)   # table top
	draw_line(Vector2(12, -22), Vector2(12, 0), Color("#9a958a"), 2.0)
	draw_line(Vector2(44, -22), Vector2(44, 0), Color("#9a958a"), 2.0)
	draw_circle(Vector2(30, -32), 5.0, Color("#b0a89a"))       # patient body
	draw_circle(Vector2(36, -34), 3.2, Color("#b0a89a"))       # patient head
	draw_line(Vector2(38, -35), Vector2(41, -37), Color("#8f877a"), 1.4)  # ear
	_draw_person(-8.0, 1.0, Color("#4a9b8e"), true)


func _draw_person(x: float, facing: float, torso_col: Color, medic: bool) -> void:
	# A simple androgynous, gender-neutral figure. facing +1 reaches to the right.
	var skin := Color("#e6c6a4")
	draw_line(Vector2(x - 3, -14), Vector2(x - 3, 0), Color("#33415c"), 3.0)
	draw_line(Vector2(x + 3, -14), Vector2(x + 3, 0), Color("#33415c"), 3.0)
	draw_rect(Rect2(x - 7, -34, 14, 21), torso_col, true)
	draw_line(Vector2(x - 6 * facing, -31), Vector2(x - 11 * facing, -21), torso_col, 3.0)
	draw_line(Vector2(x + 6 * facing, -31), Vector2(x + 13 * facing, -27), skin, 3.0)  # reaching arm
	draw_circle(Vector2(x, -40), 6.0, skin)
	draw_arc(Vector2(x, -41), 6.2, PI, TAU, 10, Color("#5a4632"), 3.0)   # hair
	if medic:
		draw_rect(Rect2(x - 1, -30, 2, 8), Color("#d64d3f"), true)       # chest cross
		draw_rect(Rect2(x - 3.5, -27, 7, 2), Color("#d64d3f"), true)


func _draw_sanctuary(font: Font) -> void:
	# A little shelter building rather than a signboard — the journey's destination
	# should look like somewhere the animals arrive, not another roadside marker.
	draw_rect(Rect2(-48, -70, 96, 70), Color("#cdb48b"), true)            # walls
	draw_colored_polygon(PackedVector2Array([
		Vector2(-56, -70), Vector2(56, -70), Vector2(0, -104)]),
		Color("#6b9c72"))                                                 # gable roof
	draw_rect(Rect2(-13, -40, 26, 40), Color("#7a5a3c"), true)            # door
	draw_circle(Vector2(7, -20), 1.6, Color("#d8c39a"))                   # doorknob
	draw_rect(Rect2(-38, -58, 16, 16), Color("#a9d0dc"), true)            # windows
	draw_rect(Rect2(22, -58, 16, 16), Color("#a9d0dc"), true)
	var bw := 96.0
	draw_rect(Rect2(-bw * 0.5, -90, bw, 18), Color("#3f6f4b"), true)      # banner
	draw_string(font, Vector2(-bw * 0.5 + 6.0, -76), "SANCTUARY", HORIZONTAL_ALIGNMENT_CENTER, bw - 12.0, 13, Color("#eef3ea"))
	draw_line(Vector2(0, -104), Vector2(0, -120), Color("#3d4b38"), 2.0)  # flagpole
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -120), Vector2(15, -116), Vector2(0, -112)]),
		Color("#e0b34a"))


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

	# Overflow passengers ride here, seated on the box rim so their heads poke up
	# like the crew in the bed. Real passenger indices, so mood and the bail hop
	# carry over. Still inside the box transform, so they bob with the trailer.
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
		var seat_y := -20.0 + _passenger_load_offset()
		for k in tm:
			var fx := (tleft + tright) * 0.5 if tm == 1 else lerpf(tleft, tright, float(k) / float(tm - 1))
			_draw_seat(Vector2(fx, seat_y), tr, t_ids[k])
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
	var shape := String(vehicle_data.get("shape", "jeep"))

	# Wheels stay planted on the ground and follow the slope. The tuk-tuk runs a
	# smaller front wheel, so its silhouette reads as a three-wheeler.
	var front_wr := wr * 0.82 if shape == "tuktuk" else wr
	draw_set_transform(_w2s(Vector2(vehicle_x, ground_y - wr * 0.7)), angle, zoom)
	draw_circle(Vector2(-wdx, 0), wr, Color("#30352f"))
	draw_circle(Vector2(wdx, 0), front_wr, Color("#30352f"))
	draw_circle(Vector2(-wdx, 0), wr * 0.44, Color("#b8b6a8"))
	draw_circle(Vector2(wdx, 0), front_wr * 0.44, Color("#b8b6a8"))

	# Body rides on the suspension, bobbing relative to the wheels. The bed box is
	# shared (passengers seat against it); each vehicle adds its own superstructure
	# so the three read as distinct silhouettes, not one recoloured box (milestone 6
	# / owner ideas: identifiable vehicles, tuk-tuk).
	draw_set_transform(_w2s(Vector2(vehicle_x, body_y)), angle, zoom)
	draw_rect(Rect2(-bw * 0.5, body_top, bw, bh), body_col, true)
	_draw_passenger(_passenger_load_offset())
	match shape:
		"tuktuk":
			_veh_tuktuk(bw, bh, body_top, body_col)
		"truck":
			_veh_truck(bw, bh, body_top, body_col)
		_:
			_veh_jeep(bw, bh, body_top, body_col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var over_cab := _w2s(Vector2(vehicle_x, body_y - 58.0))
	if loading:
		draw_string(ThemeDB.fallback_font, over_cab - Vector2(45.0, 0.0), _load_line(), HORIZONTAL_ALIGNMENT_CENTER, 90.0, 18, Color("#8a5a2b"))
	elif is_loaded:
		_draw_emote(over_cab.x, over_cab.y)


func _draw_driver(seat_x: float, head_y: float, scale := 1.0) -> void:
	# The player, a simple gender-neutral figure seated at the controls: shoulders,
	# head, a cap, and a hand reaching forward to steer. Faces the way of travel.
	var skin := Color("#e3c29e")
	var shirt := Color("#455f9c")
	draw_rect(Rect2(seat_x - 5.0 * scale, head_y + 3.0 * scale, 10.0 * scale, 11.0 * scale), shirt, true)
	draw_line(Vector2(seat_x + 3.0 * scale, head_y + 6.0 * scale), Vector2(seat_x + 9.0 * scale, head_y + 8.0 * scale), skin, 2.4 * scale)
	draw_circle(Vector2(seat_x, head_y), 5.0 * scale, skin)
	draw_arc(Vector2(seat_x, head_y - 0.5 * scale), 5.2 * scale, PI, TAU, 10, Color("#4b3a2a"), 2.6 * scale)


func _veh_tuktuk(bw: float, bh: float, body_top: float, col: Color) -> void:
	# A rounded driver pod at the front under a bright canopy on posts — the classic
	# tuk-tuk look over an open rear bed where the animals ride.
	var canopy := Color("#e0a23e")
	# Rounded front cabin.
	draw_rect(Rect2(bw * 0.12, body_top - 16.0, bw * 0.40, bh + 16.0), col, true)
	draw_circle(Vector2(bw * 0.50, body_top - 4.0), bh * 0.52 + 6.0, col)
	draw_rect(Rect2(bw * 0.20, body_top - 12.0, bw * 0.26, 13.0), Color("#bfe6df"), true)  # windshield
	# Canopy roof and its support posts.
	draw_line(Vector2(-bw * 0.42, body_top - 2.0), Vector2(-bw * 0.42, body_top - 22.0), col.darkened(0.2), 2.5)
	draw_line(Vector2(bw * 0.46, body_top - 2.0), Vector2(bw * 0.46, body_top - 22.0), col.darkened(0.2), 2.5)
	draw_rect(Rect2(-bw * 0.48, body_top - 25.0, bw * 0.98, 6.0), canopy, true)
	draw_circle(Vector2(-bw * 0.48, body_top - 22.0), 3.0, canopy)
	draw_circle(Vector2(bw * 0.50, body_top - 22.0), 3.0, canopy)
	draw_circle(Vector2(bw * 0.54, body_top + bh * 0.4), 2.6, Color("#f2e28a"))  # headlight
	_draw_driver(bw * 0.26, body_top - 9.0, 1.35)


func _veh_jeep(bw: float, bh: float, body_top: float, col: Color) -> void:
	# Open-topped and rugged: a raked windshield, a roll bar over the bed, chunky
	# wheel arches, and a round headlight. No solid roof — that's the truck's cue.
	var frame := col.darkened(0.35)
	# Raked windshield at the front.
	draw_line(Vector2(bw * 0.28, body_top), Vector2(bw * 0.14, body_top - 20.0), frame, 3.0)
	draw_rect(Rect2(bw * 0.02, body_top - 20.0, bw * 0.14, 4.0), frame, true)   # visor
	# Roll bar over the rear bed.
	draw_line(Vector2(-bw * 0.30, body_top), Vector2(-bw * 0.30, body_top - 18.0), frame, 3.0)
	draw_line(Vector2(-bw * 0.30, body_top - 18.0), Vector2(bw * 0.02, body_top - 18.0), frame, 3.0)
	draw_line(Vector2(bw * 0.02, body_top - 18.0), Vector2(bw * 0.02, body_top), frame, 3.0)
	# Wheel arches and a headlight.
	draw_rect(Rect2(-bw * 0.5, body_top + bh * 0.55, bw, bh * 0.5), col.darkened(0.18), true)
	draw_circle(Vector2(bw * 0.47, body_top + bh * 0.35), 3.2, Color("#f2e28a"))
	_draw_driver(bw * 0.06, body_top - 11.0, 1.4)


func _veh_truck(bw: float, bh: float, body_top: float, col: Color) -> void:
	# Cab-forward hauler: a tall boxy cab at the front with a window, a low side
	# rail down the long cargo bed, and a front bumper — a clearly bigger rig.
	var cab := col.darkened(0.12)
	draw_rect(Rect2(bw * 0.18, body_top - 30.0, bw * 0.30, bh + 30.0), cab, true)   # tall cab
	draw_rect(Rect2(bw * 0.22, body_top - 26.0, bw * 0.20, 17.0), Color("#bfe6df"), true)  # window
	draw_rect(Rect2(-bw * 0.5, body_top - 6.0, bw * 0.64, 6.0), col.darkened(0.25), true)  # bed rail
	draw_rect(Rect2(bw * 0.46, body_top + bh * 0.5, bw * 0.06, bh * 0.6), Color("#40352c"), true)  # bumper
	draw_circle(Vector2(bw * 0.5, body_top + bh * 0.3), 3.0, Color("#f2e28a"))  # headlight
	_draw_driver(bw * 0.30, body_top - 22.0, 1.5)  # in the cab window


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
	# Head size for a crew, solved from the bed rather than tuned per vehicle: fit
	# n heads between the bed's back edge and the cab, letting each overlap its
	# neighbour down to HEAD_SPACING before shrinking them. A lone passenger gets
	# the full head. New vehicles re-solve from their own body box — no numbers to
	# revisit.
	var bed := bw * (SEAT_BACK + CAB_X)
	var head_w := bed / (1.0 + HEAD_SPACING * float(n - 1))
	return clampf(minf(bh * SOLO_HEAD, head_w / HEAD_W_PER_RADIUS), MIN_HEAD, MAX_HEAD)


func _seating_split() -> Array:
	# Split passengers into [bed_indices, trailer_indices]. Without a trailer
	# everyone rides the bed; with one, fill the vehicle to its own slot capacity
	# and overflow into the trailer — so a load that "needs a trailer" is actually
	# seen using it rather than crammed into the cab with the trailer left empty.
	var bed: Array[int] = []
	var trailer_ids: Array[int] = []
	var veh_cap := int(vehicle_data.get("capacity", 2))
	var used := 0
	for i in passengers.size():
		var s := int(Animals.get_data(passengers[i]).get("size", 1))
		if has_trailer and used + s > veh_cap:
			trailer_ids.append(i)
		else:
			used += s
			bed.append(i)
	return [bed, trailer_ids]


func _draw_passenger(y_offset: float) -> void:
	# The loaded animals ride in the cab and, when a trailer is hitched, spill into
	# it (the trailer's occupants are drawn by _draw_trailer, in its own transform).
	# Drawn in body space so they bob and sag with the suspension. y_offset drops
	# them into their seats during the boarding animation. A lone passenger sits
	# high in the cab window; a crew spreads across the bed.
	var total := passengers.size()
	if total == 0:
		return
	var bw: float = vehicle_data.get("body_w", 96.0)
	var bh: float = vehicle_data.get("body_h", 32.0)
	var body_top := 4.0 - bh
	var off := Vector2(0.0, y_offset)
	if total == 1:
		_draw_seat(Vector2(-bw * 0.01, body_top - 12.0) + off, minf(bh * SOLO_HEAD, MAX_HEAD), 0)
		return
	# Heads sit wholly between the bed's back edge and the cab, so the cab frame
	# never crosses a face. Bailed animals keep their slot (drawn leaping away)
	# so the survivors do not shuffle sideways when one jumps off.
	var bed: Array = _seating_split()[0]
	var m := bed.size()
	if m == 0:
		return
	var r := _crew_head_radius(bw, bh, m)
	var half := r * HEAD_W_PER_RADIUS * 0.5
	var left := -bw * SEAT_BACK + half
	var right := bw * CAB_X - half
	if right < left:
		# Bed too narrow for the crew even at MIN_HEAD: stack them at its centre
		# rather than letting the row invert and run backwards.
		left = (left + right) * 0.5
		right = left
	for k in m:
		var fx := (left + right) * 0.5 if m == 1 else lerpf(left, right, float(k) / float(m - 1))
		_draw_seat(Vector2(fx, body_top - 6.0) + off, r, bed[k])
	if has_cage and m > 1:
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


const BAIL_ANIM := 0.7   # seconds the leaping-off animation plays before the animal is gone


func _draw_seat(center: Vector2, radius: float, index: int) -> void:
	# One seated animal, wearing its own mood. If it has bailed, it hops up and
	# back off the truck over BAIL_ANIM seconds, fading as it goes, then is gone.
	# (Drawn inside the vehicle's body transform, so this stays in body space —
	# no draw_set_transform here, which would overwrite that transform.)
	var mood: String = states[index]
	if not bailed[index]:
		_draw_critter(center, radius, passengers[index], mood, 1.0)
		return
	var t := bail_t[index]
	if t >= BAIL_ANIM:
		return
	var p := t / BAIL_ANIM
	center += Vector2(-radius * 5.0 * p, -radius * 3.0 * sin(p * PI))
	_draw_critter(center, radius, passengers[index], mood, 1.0 - p)


func _draw_critter(center: Vector2, radius: float, id: String, mood: String, alpha: float) -> void:
	# One animal, drawn from its mood sprite. The mood string is the filename
	# suffix ("content"/"annoyed"/"delighted"), so a mood change swaps the texture
	# and nothing else. `alpha` fades it out during the bail hop.
	var tex := _critter_texture(id, mood)
	if tex == null:
		_draw_critter_shapes(center, radius, id, mood)
		return
	var art: Dictionary = CRITTER_ART.get(id, {})
	var h := radius * float(art.get("scale", 3.0))
	var w := h * float(tex.get_width()) / float(tex.get_height())
	var pos := center + Vector2(art.get("offset", Vector2.ZERO)) * radius - Vector2(w, h) * 0.5
	draw_texture_rect(tex, Rect2(pos, Vector2(w, h)), false, Color(1, 1, 1, alpha))


func _draw_critter_shapes(center: Vector2, radius: float, id: String, mood: String) -> void:
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

	_draw_face(center, s, mood)


func _draw_face(center: Vector2, s: float, mood: String) -> void:
	var dark := Color("#2c2620")
	match mood:
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
	# A short comic call-out above the cab so the crew's state reads at a glance.
	# It follows whoever is worst off — the animal nearest bailing gets the shout,
	# since that is the one the player must act on. Only notable moods speak up.
	var worst := -1
	for i in passengers.size():
		if bailed[i]:
			continue
		if worst < 0 or comforts[i] < comforts[worst]:
			worst = i
	if worst < 0:
		return
	# A stop just topped them up: shout the relief so the lifeline is unmistakable.
	if relief_t > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(screen_x - 90.0, top_y), "Phew!",
			HORIZONTAL_ALIGNMENT_CENTER, 180.0, 20, Color("#2f7d4f"))
		return
	var text := ""
	var tint := Color("#2c2620")
	if comforts[worst] <= COMFORT_PANIC:
		text = "About to jump!"
		tint = Color("#b4472e")
	elif states[worst] == "annoyed":
		text = "Oof!"
		tint = Color("#b4472e")
	elif states[worst] == "delighted":
		text = "Wheee!"
		tint = Color("#2f7d4f")
	if text.is_empty():
		return
	draw_string(ThemeDB.fallback_font, Vector2(screen_x - 90.0, top_y), text, HORIZONTAL_ALIGNMENT_CENTER, 180.0, 20, tint)


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
	# On a level that offered a route choice, the picked route carries its own
	# terrain and stops; otherwise the level's own fields drive the track.
	var track_src: Dictionary = GameState.loadout_route if not GameState.loadout_route.is_empty() else lvl
	track_len = track_src.get("length", 2050.0)
	track_rough = track_src.get("rough", 1.0)
	track_phase = track_src.get("phase", 0.0)
	track_freq = track_src.get("freq", 1.0)
	route = []
	for node in track_src.get("route", DEFAULT_ROUTE):
		if not FUEL_ENABLED and node["type"] == "fuel":
			continue
		route.append({"type": node["type"], "x": float(node["at"]) * track_len})
	nodes_used = {}

	passengers = GameState.loadout_animals.duplicate()
	comforts.clear()
	states.clear()
	ever_annoyed.clear()
	bailed.clear()
	bail_t.clear()
	for _p in passengers:
		comforts.append(COMFORT_MAX)
		states.append("content")
		ever_annoyed.append(false)
		bailed.append(false)
		bail_t.append(0.0)
	load_factor = GameState.load_factor()
	has_cage = "divided_cage" in GameState.loadout_equipment
	has_trailer = GameState.loadout_trailer
	vehicle_data = Vehicles.get_data(GameState.current_vehicle())
	veh_max_speed = vehicle_data["max_speed"]
	veh_accel = vehicle_data["acceleration"]
	veh_start_fuel = vehicle_data["start_fuel"]
	veh_fuel_per_px = vehicle_data["fuel_per_px"]
	veh_ride = vehicle_data.get("ride", 1.0)
	vehicle_x = 100.0
	speed = 0.0
	fuel = veh_start_fuel
	body_y = terrain_y(vehicle_x) - REST_HEIGHT
	cam_y = terrain_y(vehicle_x)
	body_vy = 0.0
	is_loaded = false
	loading = false
	load_t = 0.0
	finish_hold = 0.0
	advancing = false
	relief_t = 0.0
	stop_saved_idx.clear()
	drive_pressed = false
	brake_pressed = false
	finished = false
	fuel_label.text = ("Fuel: %d%%   0 mph" % roundi(veh_start_fuel)) if FUEL_ENABLED else "0 mph"
	message_label.text = "Press DRIVE to coax %s aboard onto the %s." % [_crew_label(), Vehicles.display_name(GameState.current_vehicle())]
	queue_redraw()
