extends CanvasLayer

@export var menu_scene   : String = "res://сцены/МЕНЮ.tscn"
@export var level_scene  : String = "res://сцены/level_1.tscn"

@onready var pause_button      : Button  = %PauseButton
@onready var overlay           : Control = %Overlay
@onready var resume_button     : Button  = %ResumeButton
@onready var restart_button    : Button  = %RestartButton
@onready var back_to_menu_button : Button = %BackToMenuButton

var _music_player : AudioStreamPlayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false

	# Release-only: не реагировать на случайный свайп через кнопку
	pause_button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	pause_button.pressed.connect(_toggle_pause)

	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	back_to_menu_button.pressed.connect(_go_to_menu)

	_apply_button_style(resume_button)
	_apply_button_style(restart_button)
	_apply_button_style(back_to_menu_button)

	# Найти музыкальный плеер в сцене
	await get_tree().process_frame
	_music_player = _find_music_player(get_tree().root)


func _find_music_player(node: Node) -> AudioStreamPlayer:
	if node is AudioStreamPlayer and node.bus == "Music":
		return node
	for child in node.get_children():
		var found := _find_music_player(child)
		if found:
			return found
	return null


func _apply_button_style(btn: Button) -> void:
	var font_res := load("res://Free/VMVTZARCARI-Regular.otf")
	if font_res:
		btn.add_theme_font_override("font", font_res)
	btn.add_theme_font_size_override("font_size", 36)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))
	btn.add_theme_color_override("font_pressed_color", Color(0.6, 0.9, 1.0))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	normal.border_color = Color(1, 1, 1, 0.7)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.15, 0.15, 0.22, 0.95)
	hover.border_color = Color(1.0, 0.85, 0.3, 1.0)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed_box := StyleBoxFlat.new()
	pressed_box.bg_color = Color(0.05, 0.15, 0.25, 0.95)
	pressed_box.border_color = Color(0.6, 0.9, 1.0, 1.0)
	pressed_box.set_border_width_all(3)
	pressed_box.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("pressed", pressed_box)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	_set_paused(not get_tree().paused)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	overlay.visible   = paused

	if _music_player:
		var tween := create_tween()
		var target_db := -10.0 if paused else 0.0
		tween.tween_property(_music_player, "volume_db", target_db, 0.3)


func _on_resume() -> void:
	_set_paused(false)


func _on_restart() -> void:
	_set_paused(false)
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	_set_paused(false)
	get_tree().change_scene_to_file(menu_scene)
