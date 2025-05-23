extends CanvasLayer

func _ready():
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(on_play_button_pressed)
	$CenterContainer/VBoxContainer/CreditsButton.pressed.connect(on_credits_button_pressed)
	$CenterContainer/VBoxContainer/ExitButton.pressed.connect(on_exit_button_pressed)

func on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func on_credits_button_pressed():
	var dialog := AcceptDialog.new()
	dialog.dialog_text = "Rainbow High: Survivors\nDeveloped by Maximo Gianetti\n2024"
	add_child(dialog)
	dialog.popup_centered()

func on_exit_button_pressed():
	get_tree().quit()
