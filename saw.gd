extends Area2D

func _on_body_entered(body):
	if body.name == "лягушка" or body is CharacterBody2D:
		# Можно добавить звук удара, если он у тебя есть
		print("Пила задела лягушку!")
		
		# Небольшая пауза перед перезагрузкой (0.1 сек)
		await get_tree().create_timer(0.1).timeout
		
		# Перезапуск уровня
		get_tree().reload_current_scene()
