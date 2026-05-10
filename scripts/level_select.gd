extends Control

@onready var grid        : GridContainer = %LevelGrid
@onready var back_button : Button        = %BackButton
@onready var fade_rect   : ColorRect     = %FadeRect

var _buttons : Array[Button] = []
var _font    : FontFile


func _ready() -> void:
	_font = load("res://Free/VMVTZARCARI-Regular.otf") as FontFile
	fade_rect.modulate.a = 0.0
	_build_grid()
	back_button.pressed.connect(_on_back_pressed)
	_style_back_button()


func _build_grid() -> void:
	var max_unlocked := LevelManager.get_max_unlocked()

	for i in range(1, LevelManager.TOTAL_LEVELS + 1):
		var btn := Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(130, 110)
		var unlocked := LevelManager.is_level_unlocked(i)
		btn.disabled = not unlocked
		_apply_btn_style(btn, unlocked)
		if unlocked:
			var n := i
			btn.pressed.connect(func(): _go_to_level(n))
		if i == max_unlocked and unlocked:
			_pulse(btn)
		grid.add_child(btn)
		_buttons.append(btn)


func _go_to_level(n: int) -> void:
	_set_disabled(true)
	await _fade_black(0.2)
	LevelManager.go_to_level(n)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://сцены/МЕНЮ.tscn")


func _fade_black(dur: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(fade_rect, "modulate:a", 1.0, dur)
	await t.finished


func _set_disabled(v: bool) -> void:
	for b in _buttons:
		b.disabled = v
	back_button.disabled = v


func _pulse(btn: Button) -> void:
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	btn.pivot_offset = btn.custom_minimum_size * 0.5
	tw.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.5)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.5)


func _apply_btn_style(btn: Button, unlocked: bool) -> void:
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 40)

	var bg_color  := Color(0.1, 0.55, 0.15, 0.95) if unlocked else Color(0.12, 0.12, 0.15, 0.85)
	var brd_color := Color(0.4, 0.9, 0.4, 0.9)    if unlocked else Color(0.3, 0.3, 0.35, 0.7)

	var normal := StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.border_color = brd_color
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.15, 0.75, 0.2, 1.0)
	hover.border_color = Color(1.0, 1.0, 0.4, 1.0)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(10)
	if unlocked:
		btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_color_override("font_color",         Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_hover_color",   Color(1, 1, 0.3, 1))
	btn.add_theme_color_override("font_pressed_color", Color(0.6, 1.0, 0.6, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4, 1))


func _style_back_button() -> void:
	if _font:
		back_button.add_theme_font_override("font", _font)
	back_button.add_theme_font_size_override("font_size", 36)
	back_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	back_button.add_theme_color_override("font_hover_color", Color(1, 1, 0.3, 1))

	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color(0.08, 0.08, 0.14, 0.9)
	sbox.border_color = Color(1, 1, 1, 0.6)
	sbox.set_border_width_all(2)
	sbox.set_corner_radius_all(8)
	back_button.add_theme_stylebox_override("normal", sbox)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.15, 0.15, 0.24, 0.95)
	hover.border_color = Color(1, 1, 0.4, 1)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(8)
	back_button.add_theme_stylebox_override("hover", hover)
