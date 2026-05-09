extends CanvasLayer

const JOYSTICK_RADIUS := 140.0
const KNOB_RADIUS     := 55.0
const JUMP_RADIUS     := 80.0
const DEADZONE        := 0.18

var _joy_idx    : int     = -1
var _joy_base   : Vector2
var _joy_knob   : Vector2
var _joy_left   : bool    = false
var _joy_right  : bool    = false

var _jump_idx     : int  = -1
var _jump_pressed : bool = false
var _jump_center  : Vector2

var _canvas: Control


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS

	var vs := get_viewport().get_visible_rect().size
	_jump_center = Vector2(vs.x - 130.0, vs.y - 130.0)
	_joy_base    = Vector2(160.0, vs.y - 160.0)
	_joy_knob    = _joy_base

	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_canvas)
	_canvas.draw.connect(_draw_hud)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)


func _on_touch(ev: InputEventScreenTouch) -> void:
	var vs := get_viewport().get_visible_rect().size

	if ev.pressed:
		if _jump_idx == -1 and ev.position.x > vs.x * 0.5:
			_jump_idx     = ev.index
			_jump_pressed = true
			Input.action_press("ui_accept")

		elif _joy_idx == -1 and ev.position.x <= vs.x * 0.5:
			_joy_idx  = ev.index
			_joy_base = ev.position
			_joy_knob = ev.position
	else:
		if ev.index == _joy_idx:
			_release_joystick()
		elif ev.index == _jump_idx:
			_release_jump()
		else:
			# Safety: если индекс потерян — сбросить всё
			_release_joystick()
			_release_jump()

	_canvas.queue_redraw()


func _on_drag(ev: InputEventScreenDrag) -> void:
	if ev.index != _joy_idx:
		return

	var delta := ev.position - _joy_base
	var dist  := delta.length()
	if dist > JOYSTICK_RADIUS:
		delta = delta.normalized() * JOYSTICK_RADIUS
	_joy_knob = _joy_base + delta

	var axis := delta.x / JOYSTICK_RADIUS
	if axis < -DEADZONE:
		if not _joy_left:
			_joy_left = true
			Input.action_press("ui_left")
		if _joy_right:
			_joy_right = false
			Input.action_release("ui_right")
	elif axis > DEADZONE:
		if not _joy_right:
			_joy_right = true
			Input.action_press("ui_right")
		if _joy_left:
			_joy_left = false
			Input.action_release("ui_left")
	else:
		_release_movement()

	_canvas.queue_redraw()


func _release_joystick() -> void:
	_joy_idx  = -1
	_joy_knob = _joy_base
	_release_movement()


func _release_movement() -> void:
	if _joy_left:
		_joy_left = false
		Input.action_release("ui_left")
	if _joy_right:
		_joy_right = false
		Input.action_release("ui_right")


func _release_jump() -> void:
	_jump_idx     = -1
	_jump_pressed = false
	Input.action_release("ui_accept")


func _draw_hud() -> void:
	var joy_alpha  := 0.9 if _joy_idx  != -1 else 0.5
	var jump_alpha := 0.9 if _jump_pressed     else 0.5

	# Joystick base
	_canvas.draw_circle(_joy_base, JOYSTICK_RADIUS, Color(1, 1, 1, joy_alpha * 0.35))
	_canvas.draw_arc(_joy_base, JOYSTICK_RADIUS, 0.0, TAU, 64, Color(1, 1, 1, joy_alpha), 2.5)
	_canvas.draw_circle(_joy_knob, KNOB_RADIUS, Color(1, 1, 1, joy_alpha))

	# Jump button
	_canvas.draw_circle(_jump_center, JUMP_RADIUS, Color(0.4, 0.85, 1.0, jump_alpha * 0.55))
	_canvas.draw_arc(_jump_center, JUMP_RADIUS, 0.0, TAU, 64, Color(0.5, 0.9, 1.0, jump_alpha), 2.5)

	# Arrow up inside jump button (scaled for JUMP_RADIUS=80)
	var s := JUMP_RADIUS / 56.0  # scale relative to original 56px radius
	var arrow := PackedVector2Array([
		_jump_center + Vector2(0,   -28) * s,
		_jump_center + Vector2(-18,  -4) * s,
		_jump_center + Vector2(-7,   -4) * s,
		_jump_center + Vector2(-7,   20) * s,
		_jump_center + Vector2(7,    20) * s,
		_jump_center + Vector2(7,    -4) * s,
		_jump_center + Vector2(18,   -4) * s,
	])
	_canvas.draw_colored_polygon(arrow, Color(1, 1, 1, jump_alpha * 0.9))
