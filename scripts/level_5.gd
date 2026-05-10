extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Vertical climb level — staircase rising right to left then right
	# Starting platform
	_row(0, 6, 35)
	# Climb up — platforms alternating left and right
	_row(8, 15, 30)
	_row(4, 11, 25)
	_row(13, 20, 20)
	_row(8, 15, 15)
	_row(18, 25, 10)
	_row(13, 20, 5)
	# Final top platform with portal
	_row(22, 32, 2)
	# Left wall to prevent falling off
	for y in range(0, 36):
		tile_map.set_cell(Vector2i(-1, y), 0, T)
