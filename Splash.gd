extends Node2D

@onready var image_rect  : TextureRect       = $TextureRect
@onready var label       : Label             = $Label
@onready var audio       : AudioStreamPlayer = $AudioStreamPlayer

var _can_skip := false


func _ready() -> void:
	image_rect.modulate.a = 0.0
	label.modulate.a      = 0.0
	_run_sequence()


func _input(event: InputEvent) -> void:
	if not _can_skip:
		return
	var is_tap := event is InputEventScreenTouch and event.pressed
	var is_key := event is InputEventKey and event.pressed
	if is_tap or is_key:
		_go_to_menu()


func _run_sequence() -> void:
	audio.play()

	var tw := create_tween().set_parallel(true)
	tw.tween_property(image_rect, "modulate:a", 1.0, 0.8)
	tw.tween_property(label,      "modulate:a", 1.0, 0.8)
	await tw.finished

	_can_skip = true

	await get_tree().create_timer(3.2).timeout

	_can_skip = false
	var tw2 := create_tween().set_parallel(true)
	tw2.tween_property(image_rect, "modulate:a", 0.0, 0.8)
	tw2.tween_property(label,      "modulate:a", 0.0, 0.8)
	await tw2.finished

	_go_to_menu()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://сцены/МЕНЮ.tscn")
