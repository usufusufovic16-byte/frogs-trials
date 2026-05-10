extends Area2D

const TRANSITION_SCENE := "res://сцены/level_transition.tscn"

@export var next_level_path : String = "res://сцены/level_2.tscn"
@export var level_number    : int    = 1


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		call_deferred("_change_scene")


func _change_scene() -> void:
	if next_level_path.is_empty():
		push_error("Portal: next_level_path not set!")
		return
	LevelManager.complete_level(level_number)
	var title : String
	if next_level_path.ends_with("victory.tscn"):
		title = "YOU WIN!"
	else:
		title = "LEVEL %d" % (level_number + 1)
	LevelTransition.pending_next_scene = next_level_path
	LevelTransition.pending_title = title
	get_tree().change_scene_to_file(TRANSITION_SCENE)
