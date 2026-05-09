extends CharacterBody2D

const SPEED         : float = 200.0
const JUMP_VELOCITY : float = -350.0
const MAX_JUMPS     : int   = 2

var jump_count : int   = 0
var gravity    : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _was_on_floor : bool = false

@onready var sprite     : AnimatedSprite2D  = $AnimatedSprite2D
@onready var snd_jump   : AudioStreamPlayer = $SndJump
@onready var snd_land   : AudioStreamPlayer = $SndLand
@onready var snd_death  : AudioStreamPlayer = $SndDeath


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# Landing squash
	if on_floor and not _was_on_floor:
		snd_land.play()
		_squash(Vector2(1.2, 0.8))

	_was_on_floor = on_floor

	# Wall jump
	if is_on_wall() and not on_floor:
		var wall_normal := get_wall_normal()
		sprite.flip_h = (wall_normal.x > 0)
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = -400.0
			velocity.x = wall_normal.x * 250.0
			sprite.play("wall_jump")
			_do_jump()

	# Gravity
	if not on_floor:
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# Jump
	if Input.is_action_just_pressed("ui_accept"):
		if on_floor or jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			_do_jump()
			if jump_count == 2:
				play_double_jump_effects()

	# Horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	update_animations(direction)
	move_and_slide()


func _do_jump() -> void:
	snd_jump.play()
	Input.vibrate_handheld(40)
	_stretch(Vector2(0.85, 1.15))


func die() -> void:
	snd_death.play()
	Input.vibrate_handheld(120)


func update_animations(direction: float) -> void:
	if sprite == null:
		return
	if sprite.animation == "wall_jump" and sprite.is_playing():
		return
	if is_on_floor():
		sprite.play("idle" if direction == 0.0 else "run")
	else:
		if jump_count == 2 and sprite.sprite_frames.has_animation("double_jump"):
			sprite.play("double_jump")
		else:
			sprite.play("jump")


func play_double_jump_effects() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.05)
	tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)


func _squash(target: Vector2) -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "scale", target,         0.06).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "scale", Vector2.ONE,    0.1).set_trans(Tween.TRANS_BACK)


func _stretch(target: Vector2) -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "scale", target,         0.05).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "scale", Vector2.ONE,    0.1).set_trans(Tween.TRANS_BACK)
