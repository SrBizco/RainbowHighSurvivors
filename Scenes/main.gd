extends Node2D

# Referencias a nodos importantes
@onready var pause_menu = $PauseMenu
@onready var match_timer = $MatchTimer
@onready var timer_label = $HUD/TimerLabel
@onready var win_lose_panel = $HUD/WinLosePanel
@onready var player = $Player
@onready var spawner = $EnemySpawner

# Control de tiempo
var seconds_elapsed: int = 0
var next_difficulty_increase := 120  # tiempo en segundos para la primera subida
var max_duration: int = 1200  # 30 minutos

func _ready():
	AudioManagerSingleton.play_music(load("res://Audio/GameplayMusic.wav"))
	$PowerUpManager.set_player($Player)
	match_timer.timeout.connect(on_match_timer_timeout)
	player.player_died.connect(show_defeat_screen)
	
	# Ocultar panel de victoria/derrota al empezar
	win_lose_panel.visible = false
	
	# Conectar botones del panel
	win_lose_panel.get_node("VBoxContainer/RetryButton").pressed.connect(on_retry_pressed)
	win_lose_panel.get_node("VBoxContainer/MenuButton").pressed.connect(on_return_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause") and win_lose_panel.visible == false:
		if not pause_menu.visible:
			pause_menu.show_pause_menu()
		else:
			pause_menu.hide_pause_menu()

func on_match_timer_timeout():
	seconds_elapsed += 1
	update_timer_label()

	# Solo subir dificultad si pasamos el umbral actual
	if seconds_elapsed == next_difficulty_increase:
		spawner.increase_difficulty()
		next_difficulty_increase += 120  # programamos la siguiente subida

	if seconds_elapsed >= max_duration:
		show_victory_screen()


func update_timer_label():
	var minutes = seconds_elapsed / 60
	var seconds = seconds_elapsed % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func show_victory_screen():
	if win_lose_panel.visible: return
	get_tree().paused = true
	win_lose_panel.visible = true
	win_lose_panel.get_node("Label").text = "🎉 You Win!"

func show_defeat_screen():
	if win_lose_panel.visible: return
	get_tree().paused = true
	AudioManagerSingleton.play_sfx(load("res://Audio/Death.wav"))
	win_lose_panel.visible = true
	win_lose_panel.get_node("Label").text = "💀 Game Over"

func on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func on_return_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
