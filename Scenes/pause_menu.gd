extends CanvasLayer

@onready var resume_button = $CenterContainer/Panel/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/Panel/VBoxContainer/MainMenuButton
@onready var options_button = $CenterContainer/Panel/VBoxContainer/OptionsButton
@onready var options_menu = get_node("/root/Main/OptionsMenu")

func _ready():
	resume_button.pressed.connect(on_resume_pressed)
	main_menu_button.pressed.connect(on_main_menu_pressed)
	options_button.pressed.connect(on_options_pressed)
	visible = false

func show_pause_menu():
	get_tree().paused = true
	visible = true

func hide_pause_menu():
	visible = false

func on_resume_pressed():
	AudioManagerSingleton.play_sfx(load("res://Audio/ButtonSFX.wav"))
	hide_pause_menu()
	get_tree().paused = false

func on_main_menu_pressed():
	AudioManagerSingleton.play_sfx(load("res://Audio/ButtonSFX.wav"))
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func on_options_pressed():
	AudioManagerSingleton.play_sfx(load("res://Audio/ButtonSFX.wav"))
	hide_pause_menu()
	options_menu.show()
