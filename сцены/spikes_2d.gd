extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "лягушка" or body is CharacterBody2D:
		print("Лягушка погибла!")
		# Вместо мгновенной перезагрузки или удаления, 
		# вызываем функцию отложено
		call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()


func _on_finish_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
