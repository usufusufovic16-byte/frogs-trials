extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Speed run: 8 rhythm platforms at floor level, then ascending finale
	_row(0, 5, 35)
	for i in range(8):
		_row(8 + i * 9, 8 + i * 9 + 5, 35)
	# Ascending finale
	_row(80, 86, 32)
	_row(89, 95, 29)
	_row(98, 104, 26)
	_row(107, 113, 22)
	# Portal platform
	_row(116, 124, 18)
