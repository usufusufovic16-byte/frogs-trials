extends Node2D

@onready var tile_map : TileMapLayer = $TileMapLayer

const T := Vector2i(7, 0)


func _ready() -> void:
	_build()


func _row(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		tile_map.set_cell(Vector2i(x, y), 0, T)


func _build() -> void:
	# Long jump level — wide gaps requiring double jump + moving platforms
	# Platforms are small (3-4 tiles) with 7-8 tile gaps between them
	_row(0, 5, 35)
	# Gap 1: 8 tiles (moving platform fills it in the scene)
	_row(13, 17, 35)
	# Gap 2: 8 tiles
	_row(25, 29, 35)
	# Gap 3: 8 tiles
	_row(37, 41, 35)
	# Now ascending
	_row(37, 41, 30)   # stagger up from the last floor platform
	_row(45, 49, 25)
	# Gap 4: 8 tiles (moving platform vertical)
	_row(53, 57, 25)
	_row(60, 64, 20)
	_row(67, 72, 15)
	# Long gap before portal platform (need double jump)
	_row(80, 88, 12)
