extends Control

@onready var coins_label  : Label    = %CoinsLabel
@onready var fade_rect    : ColorRect = %FadeRect
@onready var menu_button  : Button   = %MenuButton
@onready var again_button : Button   = %AgainButton

var _font : FontFile


func _ready() -> void:
	_font = load("res://Free/VMVTZARCARI-Regular.otf") as FontFile
	fade_rect.modulate.a = 0.0

	var total := 0
	for lvl in range(1, LevelManager.TOTAL_LEVELS + 1):
		var c := LevelManager.get_coins(lvl)
		if c > 0:
			total += c
	coins_label.text = "COINS COLLECTED: %d" % total

	menu_button.pressed.connect(_on_menu_pressed)
	again_button.pressed.connect(_on_again_pressed)
	_style_button(menu_button)
	_style_button(again_button)

	_play_fanfare()


func _play_fanfare() -> void:
	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		var pulse := create_tween().set_loops(3)
		pulse.set_trans(Tween.TRANS_BACK)
		if has_node("%TitleLabel"):
			var lbl := get_node("%TitleLabel") as Label
			lbl.pivot_offset = lbl.size * 0.5
			pulse.tween_property(lbl, "scale", Vector2(1.1, 1.1), 0.2)
			pulse.tween_property(lbl, "scale", Vector2.ONE, 0.2)
	)


func _on_menu_pressed() -> void:
	_disable_buttons()
	await _fade_black(0.22)
	get_tree().change_scene_to_file("res://сцены/МЕНЮ.tscn")


func _on_again_pressed() -> void:
	_disable_buttons()
	await _fade_black(0.22)
	LevelManager.go_to_level(1)


func _fade_black(dur: float) -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(fade_rect, "modulate:a", 1.0, dur)
	await t.finished


func _disable_buttons() -> void:
	menu_button.disabled  = true
	again_button.disabled = true


func _style_button(btn: Button) -> void:
	if _font:
		btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 42)
	btn.add_theme_color_override("font_color",       Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.3, 1))

	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color(0.08, 0.5, 0.12, 0.95)
	sbox.border_color = Color(0.5, 1.0, 0.5, 0.9)
	sbox.set_border_width_all(3)
	sbox.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", sbox)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.12, 0.7, 0.18, 1.0)
	hover.border_color = Color(1.0, 1.0, 0.4, 1.0)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("hover", hover)
