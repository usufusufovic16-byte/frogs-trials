extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# FINAL CHALLENGE — combines everything
	# Section 1: Floor with gaps
	_row(0, 6, 35)
	_row(9, 13, 35)
	_row(16, 20, 35)
	# Section 2: Wide gap area (moving platforms bridge it)
	_row(25, 30, 35)
	# Section 3: Vertical climb
	_row(32, 36, 30)
	_row(38, 42, 25)
	_row(44, 48, 20)
	_row(50, 54, 15)
	# Section 4: Narrow corridor near top
	_row(56, 76, 10)   # floor of corridor
	_row(56, 76, 4)    # ceiling (6 tile gap = 96px clearance)
	# Left wall of corridor entrance
	for y in range(4, 11):
		tile_map.set_cell(Vector2i(55, y), 0, T)
	# Section 5: Final gauntlet platforms
	_row(78, 83, 10)
	_row(86, 91, 7)
	_row(94, 100, 4)
	# VICTORY platform
	_row(103, 114, 3)
