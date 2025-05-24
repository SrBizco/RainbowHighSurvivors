extends CanvasLayer

@onready var hbox = $PanelBackground/HBoxContainer
@onready var powerup_manager = get_node("/root/Main/PowerUpManager")

var panel_scene := preload("res://Scenes/PowerUpPanel.tscn")

func show_selector():
	visible = true
	get_tree().paused = true
	_show_two_random_powerups()

func _show_two_random_powerups():
	# Eliminar paneles anteriores
	for child in hbox.get_children():
		hbox.remove_child(child)
		child.queue_free()

	var options = powerup_manager.get_available_powerups()
	options.shuffle()

	for i in range(2):
		if i >= options.size():
			break

		var key = options[i]
		var panel = panel_scene.instantiate()
		var display_name = key.capitalize().replace("_", " ")
		var description = powerup_manager.get_powerup_description(key)
		var level = powerup_manager.get_powerup_level(key) + 1

		panel.call_deferred("setup", key, display_name, description, level)
		panel.powerup_selected.connect(_on_powerup_chosen)
		hbox.add_child(panel)

func _on_powerup_chosen(key: String):
	print("Elegiste power-up: ", key)
	powerup_manager.apply_powerup(key)
	visible = false
	get_tree().paused = false
