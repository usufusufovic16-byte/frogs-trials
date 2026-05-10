extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Two-path level: upper route (harder, shorter) and lower route (easier, longer)
	# Common start
	_row(0, 6, 35)

	# LOWER PATH (floor level)
	_row(8, 14, 35)
	_row(17, 23, 35)
	_row(26, 32, 35)
	_row(35, 41, 35)
	_row(44, 52, 35)

	# UPPER PATH (elevated)
	_row(8, 14, 27)
	_row(17, 23, 23)
	_row(26, 32, 19)
	_row(35, 41, 15)
	_row(44, 52, 11)

	# Merge point — both paths meet here
	_row(52, 65, 11)
	# Final climb
	_row(68, 75, 6)
	# Portal platform
	_row(78, 86, 2)
