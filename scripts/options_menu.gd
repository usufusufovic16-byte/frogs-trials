extends Control

@export var menu_scene : String = "res://сцены/МЕНЮ.tscn"

@onready var master_slider : HSlider = %MasterSlider
@onready var music_slider  : HSlider = %MusicSlider
@onready var sfx_slider    : HSlider = %SfxSlider
@onready var back_button   : Button  = %BackButton

const CFG_PATH := "user://settings.cfg"


func _ready() -> void:
	_load_settings()

	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back)

	_apply_button_style(back_button)


func _apply_button_style(btn: Button) -> void:
	var font_res := load("res://Free/VMVTZARCARI-Regular.otf")
	if font_res:
		btn.add_theme_font_override("font", font_res)
	btn.add_theme_font_size_override("font_size", 36)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	normal.border_color = Color(1, 1, 1, 0.7)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.15, 0.15, 0.22, 0.95)
	hover.border_color = Color(1.0, 0.85, 0.3, 1.0)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("hover", hover)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG_PATH) == OK:
		master_slider.value = cfg.get_value("audio", "master", 1.0)
		music_slider.value  = cfg.get_value("audio", "music",  0.5)
		sfx_slider.value    = cfg.get_value("audio", "sfx",    1.0)
	else:
		master_slider.value = 1.0
		music_slider.value  = 0.5
		sfx_slider.value    = 1.0

	_apply_volumes()


func _apply_volumes() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
		linear_to_db(master_slider.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		linear_to_db(music_slider.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_slider.value))


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_slider.value)
	cfg.set_value("audio", "music",  music_slider.value)
	cfg.set_value("audio", "sfx",    sfx_slider.value)
	cfg.save(CFG_PATH)


func _on_master_changed(_v: float) -> void:
	_apply_volumes()
	_save_settings()


func _on_music_changed(_v: float) -> void:
	_apply_volumes()
	_save_settings()


func _on_sfx_changed(_v: float) -> void:
	_apply_volumes()
	_save_settings()


func _on_back() -> void:
	get_tree().change_scene_to_file(menu_scene)
