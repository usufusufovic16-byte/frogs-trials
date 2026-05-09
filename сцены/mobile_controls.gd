extends CanvasLayer

const JOYSTICK_RADIUS := 80.0
const KNOB_RADIUS     := 34.0
const JUMP_RADIUS     := 56.0

# Joystick state
var _joy_idx    : int     = -1
var _joy_base   : Vector2
var _joy_knob   : Vector2
var _joy_left   : bool    = false
var _joy_right  : bool    = false

# Jump button state
var _jump_idx     : int  = -1
var _jump_pressed : bool = false
var _jump_center  : Vector2

var _canvas: Control


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS

	var vs := get_viewport().get_visible_rect().size
	_jump_center = Vector2(vs.x - 100.0, vs.y - 100.0)

	# Placeholder so joystick draws somewhere before first touch
	_joy_base = Vector2(110.0, vs.y - 110.0)
	_joy_knob = _joy_base

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
		# Jump button — right half, near the button circle
		if _jump_idx == -1 and ev.position.x > vs.x * 0.5:
			_jump_idx     = ev.index
			_jump_pressed = true
			Input.action_press("ui_accept")

		# Joystick — left half
		elif _joy_idx == -1 and ev.position.x <= vs.x * 0.5:
			_joy_idx  = ev.index
			_joy_base = ev.position
			_joy_knob = ev.position
	else:
		if ev.index == _joy_idx:
			_release_joystick()
		elif ev.index == _jump_idx:
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
	if axis < -0.2:
		if not _joy_left:
			_joy_left = true
			Input.action_press("ui_left")
		if _joy_right:
			_joy_right = false
			Input.action_release("ui_right")
	elif axis > 0.2:
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
	# ── Joystick ─────────────────────────────────────────────────────────────
	_canvas.draw_circle(_joy_base, JOYSTICK_RADIUS, Color(1, 1, 1, 0.12))
	_canvas.draw_arc(_joy_base, JOYSTICK_RADIUS, 0.0, TAU, 64, Color(1, 1, 1, 0.35), 2.5)
	var knob_color := Color(1, 1, 1, 0.6) if _joy_idx != -1 else Color(1, 1, 1, 0.35)
	_canvas.draw_circle(_joy_knob, KNOB_RADIUS, knob_color)

	# ── Jump button ───────────────────────────────────────────────────────────
	var fill_col := Color(0.4, 0.85, 1.0, 0.5) if _jump_pressed else Color(0.3, 0.7, 1.0, 0.22)
	var ring_col := Color(0.5, 0.9, 1.0, 0.8) if _jump_pressed else Color(0.5, 0.9, 1.0, 0.5)
	_canvas.draw_circle(_jump_center, JUMP_RADIUS, fill_col)
	_canvas.draw_arc(_jump_center, JUMP_RADIUS, 0.0, TAU, 64, ring_col, 2.5)

	# Arrow up inside jump button
	var arrow := PackedVector2Array([
		_jump_center + Vector2(0, -28),
		_jump_center + Vector2(-18, -4),
		_jump_center + Vector2(-7, -4),
		_jump_center + Vector2(-7, 20),
		_jump_center + Vector2(7, 20),
		_jump_center + Vector2(7, -4),
		_jump_center + Vector2(18, -4),
	])
	_canvas.draw_colored_polygon(arrow, Color(1, 1, 1, 0.75))
