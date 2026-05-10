extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Floor
	_row(0, 80, 35)
	# Section 1: open run
	# Ceiling for narrow corridor 1 (x 10..25, y 30 — 5 tiles clearance = 80px)
	_row(10, 25, 30)
	# Gap in floor under corridor (force player to use corridor)
	for x in range(10, 25):
		tile_map.erase_cell(Vector2i(x, 35))
	_row(10, 25, 35)   # restore floor under corridor (walk-through section)
	# Actually let's do it differently: ceiling low, floor remains, tight passage
	# Ceiling corridor 2 (x 32..50, y 29)
	_row(32, 50, 29)
	# Wall forcing player through corridor (gap at bottom)
	_row(30, 32, 28)
	_row(50, 52, 28)
	# Final section with platforms
	_row(55, 62, 29)
	_row(65, 72, 24)
	_row(72, 80, 20)
	# Portal platform
	_row(80, 88, 16)
