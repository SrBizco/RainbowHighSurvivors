extends CanvasLayer

@onready var master_slider = $OptionsPanel/MasterVolumeSlider
@onready var music_slider = $OptionsPanel/MusicVolumeSlider
@onready var sfx_slider = $OptionsPanel/SFXVolumeSlider
@onready var close_button = $OptionsPanel/CloseButton

func _ready():
	var master_index = AudioServer.get_bus_index("Master")
	var music_index = AudioServer.get_bus_index("Music")
	var sfx_index = AudioServer.get_bus_index("VFX")

	# Obtener dB actuales y convertir a lineal (0-1)
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_index))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_index))
	sfx_slider.value = db2linear(AudioServer.get_bus_volume_db(sfx_index))

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	close_button.pressed.connect(_on_close_pressed)

func _on_master_volume_changed(value: float):
	var index = AudioServer.get_bus_index("Master")
	if value <= 0.01:
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_music_volume_changed(value: float):
	var index = AudioServer.get_bus_index("Music")
	if value <= 0.01:
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_sfx_volume_changed(value: float):
	var index = AudioServer.get_bus_index("VFX")
	if value <= 0.01:
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, linear2db(value))

func _on_close_pressed():
	hide()
	get_node("/root/Main/PauseMenu").show_pause_menu()

func linear2db(linear: float) -> float:
	if linear == 0:
		return -80  # silencio total
	return 20.0 * (log(linear) / log(10))

func db2linear(db: float) -> float:
	return pow(10.0, db / 20.0)
