extends Area2D

@onready var anim  : AnimatedSprite2D  = $AnimatedSprite2D
@onready var sfx   : AudioStreamPlayer = $SndCoin
@onready var burst : GPUParticles2D    = $Burst


func _ready() -> void:
	if anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	else:
		anim.play("default")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		collect()


func collect() -> void:
	set_deferred("monitoring", false)
	anim.hide()

	sfx.play()
	burst.emitting = true

	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2.ZERO,      0.12).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(queue_free)

	print("Монетка собрана!")
