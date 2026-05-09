extends Control

@export var level_1_scene   : String = "res://сцены/level_1.tscn"
@export var options_scene   : String = "res://сцены/options_menu.tscn"

@onready var play_button    : TextureButton    = %PlayButton
@onready var options_button : TextureButton    = %OptionsButton
@onready var exit_button    : TextureButton    = %ExitButton
@onready var fade_rect      : ColorRect        = %FadeRect
@onready var title_label    : Label            = %Title
@onready var menu_music     : AudioStreamPlayer = $MenuMusic
@onready var sfx_btn        : AudioStreamPlayer = $SfxBtn

var _hover_tweens : Dictionary = {}
var _title_time   : float      = 0.0


func _ready() -> void:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0

	_wire_button(play_button)
	_wire_button(options_button)
	_wire_button(exit_button)

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	if menu_music:
		menu_music.play()

	# Load saved volume settings
	_load_settings()


func _process(delta: float) -> void:
	_title_time += delta
	if title_label:
		title_label.position.y = title_label.position.y
		var base_y : float = title_label.get_meta("base_y", title_label.position.y)
		if not title_label.has_meta("base_y"):
			title_label.set_meta("base_y", title_label.position.y)
		title_label.position.y = base_y + sin(_title_time * PI) * 4.0


func _wire_button(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size * 0.5
	btn.mouse_entered.connect(func():
		sfx_btn.play()
		_tween_scale(btn, Vector2(1.07, 1.07))
	)
	btn.mouse_exited.connect(func():  _tween_scale(btn, Vector2.ONE))
	btn.focus_entered.connect(func(): _tween_scale(btn, Vector2(1.07, 1.07)))
	btn.focus_exited.connect(func():  _tween_scale(btn, Vector2.ONE))


func _tween_scale(node: Control, target_scale: Vector2) -> void:
	var existing: Tween = _hover_tweens.get(node)
	if existing and existing.is_running():
		existing.kill()
	var t := create_tween()
	_hover_tweens[node] = t
	t.set_trans(Tween.TRANS_BACK)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", target_scale, 0.12)


func _set_buttons_enabled(enabled: bool) -> void:
	play_button.disabled    = not enabled
	options_button.disabled = not enabled
	exit_button.disabled    = not enabled


func _on_play_pressed() -> void:
	sfx_btn.play()
	_set_buttons_enabled(false)
	await _fade_to_black(0.22)
	get_tree().change_scene_to_file(level_1_scene)


func _on_options_pressed() -> void:
	sfx_btn.play()
	get_tree().change_scene_to_file(options_scene)


func _on_exit_pressed() -> void:
	sfx_btn.play()
	_set_buttons_enabled(false)
	await _fade_to_black(0.18)
	get_tree().quit()


func _fade_to_black(duration: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await t.finished


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
			linear_to_db(cfg.get_value("audio", "master", 1.0)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
			linear_to_db(cfg.get_value("audio", "music", 0.5)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
			linear_to_db(cfg.get_value("audio", "sfx", 1.0)))
