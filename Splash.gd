extends Control

@onready var image_rect : TextureRect       = $TextureRect
@onready var label      : Label             = $Label
@onready var audio      : AudioStreamPlayer = $AudioStreamPlayer

var _can_skip := false


func _ready() -> void:
	# Load resources dynamically — won't crash if files missing
	var tex = load("res://Gemini_Generated_Image_ifxq59ifxq59ifxq.png")
	if tex and image_rect:
		image_rect.texture = tex

	var snd = load("res://neon-lamp-switching-on_mjoagseu.mp3")
	if snd and audio:
		audio.stream = snd

	if image_rect:
		image_rect.modulate.a = 0.0
	if label:
		label.modulate.a = 0.0

	_run_sequence()


func _input(event: InputEvent) -> void:
	if not _can_skip:
		return
	var is_tap := event is InputEventScreenTouch and event.pressed
	var is_key := event is InputEventKey and event.pressed
	if is_tap or is_key:
		_go_to_menu()


func _run_sequence() -> void:
	if audio and audio.stream:
		audio.play()

	var tw := create_tween().set_parallel(true)
	if image_rect:
		tw.tween_property(image_rect, "modulate:a", 1.0, 0.8)
	if label:
		tw.tween_property(label, "modulate:a", 1.0, 0.8)
	await tw.finished

	_can_skip = true
	await get_tree().create_timer(3.2).timeout
	_can_skip = false

	var tw2 := create_tween().set_parallel(true)
	if image_rect:
		tw2.tween_property(image_rect, "modulate:a", 0.0, 0.8)
	if label:
		tw2.tween_property(label, "modulate:a", 0.0, 0.8)
	await tw2.finished

	_go_to_menu()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://сцены/МЕНЮ.tscn")
