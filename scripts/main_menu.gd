extends Control

@export var level_1_scene : String = "res://сцены/level_1.tscn"
@export var options_scene : String = "res://сцены/options_menu.tscn"

@onready var play_button    : TextureButton = %PlayButton
@onready var options_button : TextureButton = %OptionsButton
@onready var exit_button    : TextureButton = %ExitButton
@onready var fade_rect      : ColorRect     = %FadeRect
@onready var title_label    : Label         = %Title
@onready var splash_layer   : CanvasLayer   = $SplashLayer
@onready var splash_box     : Control       = $SplashLayer/SplashBox
@onready var yusuf_label    : Label         = $SplashLayer/SplashBox/YusufLabel

var _hover_tweens : Dictionary = {}
var _title_time   : float      = 0.0
var _title_base_y : float      = 0.0
var _title_ready  : bool       = false


func _ready() -> void:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a   = 0.0

	_wire_button(play_button)
	_wire_button(options_button)
	_wire_button(exit_button)

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	_load_settings()
	_run_splash()


func _process(delta: float) -> void:
	if not _title_ready or not title_label:
		return
	_title_time += delta
	title_label.position.y = _title_base_y + sin(_title_time * PI) * 4.0


func _run_splash() -> void:
	_set_buttons_enabled(false)
	yusuf_label.modulate.a = 0.0
	splash_layer.visible   = true

	# Start menu music during splash
	var music := get_node_or_null("MenuMusic") as AudioStreamPlayer
	if music and music.stream:
		music.play()

	# Fade-in YUSUF GAMES label (BG stays black)
	var tw1 := create_tween()
	tw1.tween_property(yusuf_label, "modulate:a", 1.0, 0.8)
	await tw1.finished

	await get_tree().create_timer(3.2).timeout

	# Fade-out entire splash box (reveals menu underneath)
	var tw2 := create_tween()
	tw2.tween_property(splash_box, "modulate:a", 0.0, 0.8)
	await tw2.finished

	splash_layer.visible = false
	splash_box.modulate.a = 1.0  # reset for next time

	# Enable menu and start title wave
	_set_buttons_enabled(true)
	_title_base_y = title_label.position.y
	_title_ready  = true


func _wire_button(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size * 0.5
	btn.mouse_entered.connect(func():
		_play_sfx()
		_tween_scale(btn, Vector2(1.07, 1.07))
	)
	btn.mouse_exited.connect(func():  _tween_scale(btn, Vector2.ONE))
	btn.focus_entered.connect(func(): _tween_scale(btn, Vector2(1.07, 1.07)))
	btn.focus_exited.connect(func():  _tween_scale(btn, Vector2.ONE))


func _tween_scale(node: Control, target: Vector2) -> void:
	var existing : Tween = _hover_tweens.get(node)
	if existing and existing.is_running():
		existing.kill()
	var t := create_tween()
	_hover_tweens[node] = t
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", target, 0.12)


func _play_sfx() -> void:
	var sfx := get_node_or_null("SfxBtn") as AudioStreamPlayer
	if sfx and sfx.stream:
		sfx.play()


func _set_buttons_enabled(enabled: bool) -> void:
	play_button.disabled    = not enabled
	options_button.disabled = not enabled
	exit_button.disabled    = not enabled


func _on_play_pressed() -> void:
	_play_sfx()
	_set_buttons_enabled(false)
	await _fade_to_black(0.22)
	get_tree().change_scene_to_file("res://сцены/level_select.tscn")


func _on_options_pressed() -> void:
	_play_sfx()
	get_tree().change_scene_to_file(options_scene)


func _on_exit_pressed() -> void:
	_play_sfx()
	_set_buttons_enabled(false)
	await _fade_to_black(0.18)
	get_tree().quit()


func _fade_to_black(duration: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await t.finished


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx  := AudioServer.get_bus_index("Music")
	var sfx_idx    := AudioServer.get_bus_index("SFX")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(cfg.get_value("audio", "master", 1.0)))
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(cfg.get_value("audio", "music", 0.5)))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(cfg.get_value("audio", "sfx", 1.0)))
