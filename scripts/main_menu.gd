extends Control

@export var level_1_scene: String = "res://сцены/level_1.tscn"

@onready var play_button: TextureButton = %PlayButton
@onready var options_button: TextureButton = %OptionsButton
@onready var exit_button: TextureButton = %ExitButton
@onready var fade_rect: ColorRect = %FadeRect

var _hover_tweens: Dictionary = {}


func _ready() -> void:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0

	_wire_button(play_button)
	_wire_button(options_button)
	_wire_button(exit_button)

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _wire_button(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size * 0.5
	btn.mouse_entered.connect(func(): _tween_scale(btn, Vector2(1.07, 1.07)))
	btn.mouse_exited.connect(func(): _tween_scale(btn, Vector2.ONE))
	btn.focus_entered.connect(func(): _tween_scale(btn, Vector2(1.07, 1.07)))
	btn.focus_exited.connect(func(): _tween_scale(btn, Vector2.ONE))


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
	play_button.disabled = not enabled
	options_button.disabled = not enabled
	exit_button.disabled = not enabled


func _on_play_pressed() -> void:
	_set_buttons_enabled(false)
	await _fade_to_black(0.22)
	get_tree().change_scene_to_file(level_1_scene)


func _on_options_pressed() -> void:
	_tween_scale(options_button, Vector2(1.0, 1.0))
	_set_buttons_enabled(true)


func _on_exit_pressed() -> void:
	_set_buttons_enabled(false)
	await _fade_to_black(0.18)
	get_tree().quit()


func _fade_to_black(duration: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await t.finished
