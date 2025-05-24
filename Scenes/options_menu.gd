extends CanvasLayer

@onready var volume_slider = $OptionsPanel/VolumeSlider
@onready var close_button = $OptionsPanel/CloseButton

func _ready():
	# Leer volumen actual del Master y setear el slider
	var master_index = AudioServer.get_bus_index("Master")
	volume_slider.value = AudioServer.get_bus_volume_db(master_index)

	# Conectar señales
	volume_slider.value_changed.connect(_on_volume_changed)
	close_button.pressed.connect(_on_close_pressed)

func _on_volume_changed(value: float):
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, value)

func _on_close_pressed():
	hide()
	get_node("/root/Main/PauseMenu").show_pause_menu()
