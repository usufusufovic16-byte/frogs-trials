extends CanvasLayer

@export var menu_scene: String = "res://сцены/МЕНЮ.tscn"

@onready var pause_button: TextureButton = %PauseButton
@onready var overlay: Control = %Overlay
@onready var back_to_menu_button: TextureButton = %BackToMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false

	pause_button.pressed.connect(_toggle_pause)
	back_to_menu_button.pressed.connect(_go_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	var should_pause := not get_tree().paused
	_set_paused(should_pause)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	overlay.visible = paused


func _go_to_menu() -> void:
	_set_paused(false)
	get_tree().change_scene_to_file(menu_scene)
