extends CanvasLayer
class_name LevelTransition

## Заполняется перед вызовом change_scene_to_file на эту сцену.
static var pending_next_scene: String = ""
static var pending_title: String = "LEVEL 2"

const HOLD_SEC := 1.0
const FADE_IN_SEC := 0.45
const FADE_OUT_SEC := 0.35

@onready var _backdrop: ColorRect = $ColorRect
@onready var _label: Label = $CenterContainer/Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var next_path := pending_next_scene
	pending_next_scene = ""
	var title := pending_title
	pending_title = "LEVEL 2"

	if next_path.is_empty():
		push_error("LevelTransition: pending_next_scene пуст — возврат на level_1.")
		get_tree().change_scene_to_file("res://сцены/level_1.tscn")
		return

	_label.text = title
	_label.modulate = Color(1, 1, 1, 0)
	_label.scale = Vector2(0.85, 0.85)
	_backdrop.color = Color(0, 0, 0, 0)

	var tween_in := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_in.tween_property(_backdrop, "color", Color(0, 0, 0, 0.78), FADE_IN_SEC)
	tween_in.tween_property(_label, "modulate", Color(1, 1, 1, 1), FADE_IN_SEC * 1.1).set_delay(0.08)
	tween_in.tween_property(_label, "scale", Vector2.ONE, FADE_IN_SEC * 1.1).set_delay(0.08)
	await tween_in.finished

	await get_tree().create_timer(HOLD_SEC).timeout

	var tween_out := create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_out.tween_property(_backdrop, "color", Color(0, 0, 0, 1), FADE_OUT_SEC)
	tween_out.tween_property(_label, "modulate", Color(1, 1, 1, 0), FADE_OUT_SEC)
	await tween_out.finished

	get_tree().change_scene_to_file(next_path)
