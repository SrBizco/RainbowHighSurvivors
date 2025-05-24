extends Panel

signal powerup_selected(key: String)

@onready var name_label = $NameLabel
@onready var description_label = $DescriptionLabel
@onready var level_label = $LevelLabel

var powerup_key: String = ""

func setup(key: String, display_name: String, description: String, level: int):
	powerup_key = key
	name_label.text = display_name
	description_label.text = description
	level_label.text = "Lvl.%d" % level

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("powerup_selected", powerup_key)
