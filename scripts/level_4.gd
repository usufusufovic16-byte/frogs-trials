extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Ground sections with wide gaps (moving platforms fill them)
	_row(0, 7, 35)
	# Gap 1: x 7..17 (10 tiles — moving platform covers it)
	_row(17, 25, 35)
	# Gap 2: x 25..37 (12 tiles — two platforms)
	_row(37, 44, 35)
	# Gap 3: x 44..56 (12 tiles — moving platform)
	_row(56, 68, 35)
	# Ascending section
	_row(65, 72, 30)
	_row(72, 78, 25)
	_row(78, 85, 20)
	# Portal platform
	_row(85, 92, 16)
