extends Area2D

func _ready():
	# 1. Запускаем анимацию. 
	# Убедись, что в AnimatedSprite2D анимация называется "idle" или "default"
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("default")
	
	# 2. Соединяем сигнал столкновения
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что это игрок
	if body is CharacterBody2D:
		collect()

func collect():
	# 1. Отключаем столкновения сразу (отложенно), чтобы не собрать дважды
	set_deferred("monitoring", false)
	
	# 2. Создаем красивую анимацию сбора через Tween
	var tween = create_tween()
	
	# Параллельно: подлетает вверх и становится прозрачной
	tween.parallel().tween_property(self, "position:y", position.y - 50, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	# 3. После завершения анимации удаляем монетку
	tween.finished.connect(queue_free)
	
	print("Монетка собрана!")
