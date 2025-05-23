extends CanvasLayer

@onready var resume_button = $CenterContainer/Panel/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/Panel/VBoxContainer/MainMenuButton

func _ready():
	resume_button.pressed.connect(on_resume_pressed)
	main_menu_button.pressed.connect(on_main_menu_pressed)
	visible = false

func show_pause_menu():
	get_tree().paused = true
	visible = true

func hide_pause_menu():
	get_tree().paused = false
	visible = false

func on_resume_pressed():
	hide_pause_menu()

func on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
