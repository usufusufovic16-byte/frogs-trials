extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0

# Переменные для двойного прыжка
var jump_count = 0
const MAX_JUMPS = 2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	# 1. Проверяем: касаемся стены И мы не на полу
	if is_on_wall() and not is_on_floor():
		
		# Получаем нормаль стены (куда она "смотрит")
		# Если стена справа, нормаль.x = -1 (надо прыгать влево)
		# Если стена слева, нормаль.x = 1 (надо прыгать вправо)
		var wall_normal = get_wall_normal()
		
		# Поворачиваем спрайт к стене:
		# Если нормаль > 0 (стена слева), flip_h = true (разворот влево)
		sprite.flip_h = (wall_normal.x > 0)
		
		# 2. Если нажат прыжок
		if Input.is_action_just_pressed("ui_accept"): # "ui_accept" — это пробел/enter
			
			# Даем импульс вверх и в сторону от стены
			velocity.y = -400 # Сила вверх
			velocity.x = wall_normal.x * 250 # Отталкивание вбок
			
			# Запускаем анимацию прыжка от стены
			sprite.play("wall_jump")
	# 1. Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Когда мы на земле, сбрасываем счетчик прыжков
		jump_count = 0

	# 2. Логика прыжка
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			
			# Если это второй прыжок, можно добавить спецэффект
			if jump_count == 2:
				play_double_jump_effects()

	# 3. Движение и разворот
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Обновление анимаций
	update_animations(direction)

	move_and_slide()

func update_animations(direction):
	if sprite == null:
		return
	if sprite.animation == "wall_jump" and sprite.is_playing():
		return

	# Дальше твой обычный код анимаций
	if is_on_floor():
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
	else:
		# Логика для воздуха (двойной прыжок или обычный)
		if jump_count == 2:
			if sprite.sprite_frames.has_animation("double_jump"):
				sprite.play("double_jump")
			else:
				sprite.play("jump")
		else:
			sprite.play("jump")

func play_double_jump_effects():
	# Маленький визуальный трюк: чуть-чуть сжимаем лягушку при втором прыжке
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
