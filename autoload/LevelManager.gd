extends Node

const SAVE_PATH    := "user://progress.cfg"
const TOTAL_LEVELS := 10
const LEVEL_PATHS  := [
	"",
	"res://сцены/level_1.tscn",
	"res://сцены/level_2.tscn",
	"res://сцены/level_3.tscn",
	"res://сцены/level_4.tscn",
	"res://сцены/level_5.tscn",
	"res://сцены/level_6.tscn",
	"res://сцены/level_7.tscn",
	"res://сцены/level_8.tscn",
	"res://сцены/level_9.tscn",
	"res://сцены/level_10.tscn",
]

var current_level : int = 1
var _unlocked     : int = 1
var _coins        : Dictionary = {}

func _ready() -> void:
	_load()

func go_to_level(n: int) -> void:
	if n < 1 or n > TOTAL_LEVELS:
		return
	current_level = n
	LevelTransition.pending_next_scene = LEVEL_PATHS[n]
	LevelTransition.pending_title = "LEVEL %d" % n
	get_tree().change_scene_to_file("res://сцены/level_transition.tscn")

func restart_current_level() -> void:
	get_tree().reload_current_scene()

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://сцены/МЕНЮ.tscn")

func get_current_level_number() -> int:
	return current_level

func complete_level(n: int) -> void:
	current_level = n
	if n < TOTAL_LEVELS:
		unlock_level(n + 1)
	_save()

func unlock_level(n: int) -> void:
	if n > _unlocked and n <= TOTAL_LEVELS:
		_unlocked = n
		_save()

func is_level_unlocked(n: int) -> bool:
	return n <= _unlocked

func get_max_unlocked() -> int:
	return _unlocked

func save_coins(level_n: int, coins: int) -> void:
	if not _coins.has(level_n) or coins > _coins.get(level_n, 0):
		_coins[level_n] = coins
		_save()

func get_coins(level_n: int) -> int:
	return _coins.get(level_n, -1)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", _unlocked)
	for k in _coins:
		cfg.set_value("coins", str(k), _coins[k])
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	_unlocked = cfg.get_value("progress", "unlocked", 1)
	for k in range(1, TOTAL_LEVELS + 1):
		var v : int = cfg.get_value("coins", str(k), -1)
		if v >= 0:
			_coins[k] = v
