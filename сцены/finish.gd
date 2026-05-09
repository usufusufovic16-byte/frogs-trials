extends Area2D

const TRANSITION_SCENE := "res://сцены/level_transition.tscn"

var next_level_path := "res://сцены/level_2.tscn"


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		call_deferred("_change_scene")


func _change_scene() -> void:
	LevelTransition.pending_next_scene = next_level_path
	LevelTransition.pending_title = "LEVEL 2"
	get_tree().change_scene_to_file(TRANSITION_SCENE)
