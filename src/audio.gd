extends Node

# Autoloaded sound engine. Every sound is synthesised in code at startup into
# AudioStreamWAV buffers — no audio files, matching the game's code-drawn art. It
# exposes a small API the scenes call at meaningful moments (a jolt, a bail, a
# lifeline stop) plus a speed-tracked engine loop and a soft music bed, and floats
# a mute button over everything so testers can silence it anywhere.
#
# Design rule carried over from the visuals: every cue means something. Silence
# between events is fine; nothing plays just to fill space.

const MIX_RATE := 22050.0
const TAU_F := TAU

var _sfx: Array[AudioStreamPlayer] = []   # a small pool for one-shot cues
var _sfx_next := 0
var _engine: AudioStreamPlayer
var _music: AudioStreamPlayer
var _voice_amb: AudioStreamPlayer         # one dedicated channel for ambient chatter
var _clips := {}                          # name -> AudioStream (procedural or file)
var _voices := {}                         # animal id -> voice AudioStream (optional)
var _engine_shape := ""
var muted := false
var _mute_button: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_clips()

	for i in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx.append(p)

	_engine = AudioStreamPlayer.new()
	_engine.bus = "Master"
	_engine.volume_db = -60.0
	add_child(_engine)

	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.stream = _clips["music"]
	_music.volume_db = -16.0
	add_child(_music)

	_voice_amb = AudioStreamPlayer.new()
	_voice_amb.bus = "Master"
	add_child(_voice_amb)

	_build_mute_button()
	set_muted(muted)
	set_process_input(true)


# ---- public API ------------------------------------------------------------

func play(clip_name: String, volume_db := -8.0, pitch := 1.0) -> void:
	var clip: AudioStreamWAV = _clips.get(clip_name)
	if clip == null:
		return
	var p := _sfx[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx.size()
	p.stream = clip
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


var _audio_unlocked := false


func _input(event: InputEvent) -> void:
	# Web browsers keep the audio context suspended until the first real user
	# gesture, so anything started at load-in (the music bed) comes out silent even
	# though it reports as playing. On the first tap/click/key, re-assert the music
	# now that audio is unlocked. Harmless on desktop. Runs once.
	if _audio_unlocked:
		return
	var pressed := false
	if event is InputEventMouseButton:
		pressed = event.pressed
	elif event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventKey:
		pressed = event.pressed
	if not pressed:
		return
	_audio_unlocked = true
	if _music and _music.stream:
		_music.stop()
		_music.play()


func start_music() -> void:
	if not _music.playing:
		_music.play()


func boarded(ids: Array) -> void:
	# Voice the crew as they settle in — each animal's own call, staggered so a
	# full load doesn't blurt at once. Falls back to the generic chirp with no voices.
	if _voices.is_empty():
		play("load", -8.0)
		return
	for i in range(ids.size()):
		var id: String = ids[i]
		var when := float(i) * 0.17
		if when <= 0.001:
			play_voice(id, -7.0)
		else:
			get_tree().create_timer(when).timeout.connect(func(): play_voice(id, -7.0))


# Per-shape engine trim (dB) to even out the supplied loops against the tuk-tuk.
const ENGINE_GAIN := {
	"truck": 5.0,
	"jeep": 5.0,
}


func engine(speed: float, max_speed: float, shape: String) -> void:
	# Keep a looping motor tone under the vehicle, its pitch and loudness rising
	# with speed. Each vehicle shape has its own timbre so they sound as distinct
	# as they look.
	if shape != _engine_shape:
		_engine_shape = shape
		_engine.stream = _clips.get("engine_" + shape, _clips["engine_jeep"])
		_engine.play()
	elif not _engine.playing:
		_engine.play()
	var t := clampf(speed / maxf(max_speed, 1.0), 0.0, 1.0)
	_engine.pitch_scale = 0.7 + t * 1.15
	# Even out the supplied engine loops: the truck and jeep recordings both came in
	# quieter than the tuk-tuk, so lift them a few dB to match.
	_engine.volume_db = lerpf(-26.0, -10.0, t) + ENGINE_GAIN.get(shape, 0.0)


func stop_engine() -> void:
	if _engine and _engine.playing:
		_engine.stop()
	_engine_shape = ""


func toggle_mute() -> void:
	set_muted(not muted)


func set_muted(m: bool) -> void:
	muted = m
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	if _mute_button:
		_mute_button.set_muted(muted)


# ---- mute button -----------------------------------------------------------

func _build_mute_button() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_mute_button = preload("res://src/mute_button.gd").new()
	_mute_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_mute_button.offset_left = -60.0
	_mute_button.offset_top = 8.0
	_mute_button.offset_right = -8.0
	_mute_button.offset_bottom = 52.0
	_mute_button.toggled.connect(toggle_mute)
	layer.add_child(_mute_button)


# ---- synthesis -------------------------------------------------------------

func _build_clips() -> void:
	_clips["engine_tuktuk"] = _engine_loop(92.0, 15.0, "square")
	_clips["engine_jeep"] = _engine_loop(66.0, 10.0, "saw")
	_clips["engine_truck"] = _engine_loop(46.0, 7.5, "saw")

	_clips["jolt"] = _jolt()
	_clips["bail"] = _bail()
	_clips["warn"] = _warn()
	_clips["munch"] = _munch()
	_clips["vet"] = _bells([660.0, 880.0], 0.34, 0.09)
	_clips["sanctuary"] = _chord([392.0, 494.0, 587.0, 784.0], 0.75)
	_clips["rescue"] = _bells([523.0, 659.0, 784.0], 0.42, 0.11)
	_clips["tap"] = _tap()
	_clips["star"] = _bells([988.0], 0.26, 0.0)
	_clips["load"] = _bells([330.0, 300.0], 0.26, 0.10)
	_clips["music"] = _music_loop()

	_load_overrides()


func _load_overrides() -> void:
	# Prefer a real audio file in res://audio/ over the procedural clip when one is
	# present, so recorded/generated sounds (see docs/AUDIO_BRIEF.md) can be dropped
	# in one at a time — anything missing keeps its synthesised fallback.
	for key in _clips.keys():
		var res: AudioStream = _find_audio("res://audio/" + String(key))
		if res != null:
			if key.begins_with("engine_") or key == "music":
				_set_loop(res)
			_clips[key] = res
	# Optional per-animal voices (voice_<id>), played on load-in and on a bail.
	for id in Animals.DATA.keys():
		var v: AudioStream = _find_audio("res://audio/voice_" + String(id))
		if v != null:
			_voices[id] = v


func _find_audio(base: String) -> AudioStream:
	for ext in [".ogg", ".wav", ".mp3"]:
		var path := base + String(ext)
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is AudioStream:
				return res
	return null


func _set_loop(res: AudioStream) -> void:
	# Route by which loop property the stream actually has, not by class — an
	# imported .mp3/.ogg exposes `loop`, a WAV exposes `loop_mode`. (Class checks
	# proved unreliable for the imported MP3.)
	if "loop" in res:
		res.loop = true
	elif "loop_mode" in res:
		# Loop the whole sample. loop_end is in frames; derive it from the true
		# length and rate so it's correct regardless of the imported format (PCM,
		# QOA, etc.) rather than guessing from the byte count.
		res.loop_mode = AudioStreamWAV.LOOP_FORWARD
		res.loop_begin = 0
		res.loop_end = int(res.get_length() * float(res.mix_rate))


# Per-animal trim (dB) to even out the supplied voice recordings — some came in
# quieter than others (the tortoise reads much softer than the wombat).
const VOICE_GAIN := {
	"tortoise": 6.0,
}


func voice_ambient(animal_id: String, volume_db := -10.0, pitch := 1.0) -> bool:
	# A one-at-a-time ambient call on a dedicated channel: plays the animal's voice,
	# but only if no ambient voice is already sounding — so the crew never talk over
	# each other during the drive. Returns whether a call actually started (the caller
	# uses that to decide when to try again). No-op with no voice pack.
	if not _voices.has(animal_id) or _voice_amb == null or _voice_amb.playing:
		return false
	_voice_amb.stream = _voices[animal_id]
	_voice_amb.volume_db = volume_db + VOICE_GAIN.get(animal_id, 0.0)
	_voice_amb.pitch_scale = pitch
	_voice_amb.play()
	return true


func play_voice(animal_id: String, volume_db := -8.0, pitch := 1.0) -> void:
	if _voices.has(animal_id):
		var p := _sfx[_sfx_next]
		_sfx_next = (_sfx_next + 1) % _sfx.size()
		p.stream = _voices[animal_id]
		p.volume_db = volume_db + VOICE_GAIN.get(animal_id, 0.0)
		p.pitch_scale = pitch
		p.play()


func _wav(samples: PackedFloat32Array, loop := false) -> AudioStreamWAV:
	var n := samples.size()
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = int(MIX_RATE)
	s.stereo = false
	s.data = bytes
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = n
	return s


func _osc(phase: float, wave: String) -> float:
	match wave:
		"square":
			return 1.0 if sin(phase) >= 0.0 else -1.0
		"saw":
			var x := fmod(phase, TAU_F) / TAU_F
			return x * 2.0 - 1.0
		_:
			return sin(phase)


func _engine_loop(freq: float, flutter_hz: float, wave: String) -> AudioStreamWAV:
	# One seamless loop: fundamental + an octave, amplitude-fluttered for a chug.
	# Loop length is a whole number of cycles of every component, so it never clicks.
	var dur := 0.4
	var n := int(MIX_RATE * dur)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		var v := _osc(TAU_F * freq * t, wave) * 0.6
		v += _osc(TAU_F * freq * 2.0 * t, "sine") * 0.2
		var flutter := 0.72 + 0.28 * sin(TAU_F * flutter_hz * t)
		out[i] = v * flutter * 0.5
	return _wav(out, true)


func _env(i: int, n: int, attack: float, release: float) -> float:
	var t := float(i) / float(n)
	var a := clampf(t / maxf(attack, 0.0001), 0.0, 1.0)
	var r := clampf((1.0 - t) / maxf(release, 0.0001), 0.0, 1.0)
	return a * r


func _jolt() -> AudioStreamWAV:
	# A soft low thud with a touch of noise at the leading edge.
	var n := int(MIX_RATE * 0.14)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		var body := sin(TAU_F * 96.0 * t) * exp(-t * 26.0)
		var knock := (randf() * 2.0 - 1.0) * exp(-t * 90.0) * 0.5
		out[i] = (body + knock) * 0.8
	return _wav(out)


func _bail() -> AudioStreamWAV:
	# A comedic hop: a quick up-then-down pitch bend, springy and harmless.
	var n := int(MIX_RATE * 0.34)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in range(n):
		var t := float(i) / MIX_RATE
		var f := 300.0 + 520.0 * sin(t * 9.0) * exp(-t * 3.0)
		phase += TAU_F * f / MIX_RATE
		out[i] = sin(phase) * _env(i, n, 0.02, 0.5) * 0.7
	return _wav(out)


func _warn() -> AudioStreamWAV:
	# A quick anxious two-tone chirp — the "about to jump!" alarm.
	var n := int(MIX_RATE * 0.2)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		var f := 720.0 if t < 0.1 else 900.0
		out[i] = _osc(TAU_F * f * t, "square") * _env(i, n, 0.02, 0.25) * 0.35
	return _wav(out)


func _munch() -> AudioStreamWAV:
	# Three short crunches — a feed at the food stop.
	var n := int(MIX_RATE * 0.3)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		var seg := fmod(t, 0.1) / 0.1
		var crunch := (randf() * 2.0 - 1.0) * exp(-seg * 12.0)
		out[i] = crunch * 0.55
	return _wav(out)


func _bells(freqs: PackedFloat32Array, dur: float, stagger: float) -> AudioStreamWAV:
	# Ascending bell tones (vet chime, rescue fanfare, star ping).
	var n := int(MIX_RATE * dur)
	var out := PackedFloat32Array()
	out.resize(n)
	for k in range(freqs.size()):
		var start := int(stagger * MIX_RATE) * k
		for i in range(start, n):
			var t := float(i - start) / MIX_RATE
			var v := sin(TAU_F * freqs[k] * t) * exp(-t * 7.0)
			out[i] += v * 0.4
	return _wav(out)


func _chord(freqs: PackedFloat32Array, dur: float) -> AudioStreamWAV:
	# A warm sustained chord for the sanctuary arrival.
	var n := int(MIX_RATE * dur)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		var v := 0.0
		for f in freqs:
			v += sin(TAU_F * f * t)
		out[i] = v / float(freqs.size()) * _env(i, n, 0.08, 0.5) * 0.7
	return _wav(out)


func _tap() -> AudioStreamWAV:
	var n := int(MIX_RATE * 0.05)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in range(n):
		var t := float(i) / MIX_RATE
		out[i] = sin(TAU_F * 660.0 * t) * exp(-t * 60.0) * 0.4
	return _wav(out)


func _music_loop() -> AudioStreamWAV:
	# A slow, soft four-chord pad that loops seamlessly — a calm bed, kept quiet.
	var chords := [
		[196.0, 247.0, 294.0],   # G
		[220.0, 277.0, 330.0],   # A minor-ish
		[247.0, 294.0, 392.0],   # C
		[175.0, 220.0, 294.0],   # D
	]
	var chord_dur := 2.2
	var cn := int(MIX_RATE * chord_dur)
	var out := PackedFloat32Array()
	for c in chords:
		for i in range(cn):
			var t := float(i) / MIX_RATE
			var v := 0.0
			for f in c:
				v += sin(TAU_F * f * t)
			v /= float(c.size())
			# gentle swell in and out across each chord so it breathes
			var swell := 0.5 - 0.5 * cos(TAU_F * t / chord_dur)
			out.append(v * swell * 0.5)
	return _wav(out, true)
