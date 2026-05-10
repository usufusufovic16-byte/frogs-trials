extends AnimatableBody2D

@export var distance : float = 80.0
@export var duration : float = 1.5
@export var horizontal : bool = true

var _start_pos : Vector2

func _ready() -> void:
	_start_pos = position
	_start_loop()

func _start_loop() -> void:
	var axis := Vector2(1.0, 0.0) if horizontal else Vector2(0.0, 1.0)
	var target_a := _start_pos + axis * distance
	var target_b := _start_pos - axis * distance
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", target_a, duration)
	tw.tween_property(self, "position", target_b, duration * 2.0)
	tw.tween_property(self, "position", _start_pos, duration)
