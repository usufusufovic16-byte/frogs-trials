extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Starting floor
	_row(0, 8, 35)
	# Gap 1 (x 8..10, 3 tiles wide — easy jump)
	_row(11, 20, 35)
	# Gap 2 (x 20..24, 4 tiles — standard jump)
	_row(24, 32, 35)
	# Gap 3 (x 32..38, 6 tiles — double jump or platform)
	_row(30, 34, 31)   # floating bridge in the middle of gap 3
	_row(38, 55, 35)
	# Slightly raised exit platform
	_row(50, 57, 30)
	# Portal area platform top
	_row(57, 62, 26)
