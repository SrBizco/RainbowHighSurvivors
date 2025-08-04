extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var boss_enemy_scenes: Array[PackedScene] = []
@export var spawn_radius := 500.0
@export var initial_spawn_interval := 2.0
@export var min_interval := 0.5
@export var interval_step := 0.1
@export var difficulty_step_time := 10.0 

var spawn_interval: float
var difficulty_timer := Timer.new()
var health_multiplier := 1.0  
var boss_timer: Timer 

func _ready():
	spawn_interval = initial_spawn_interval

	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

	difficulty_timer.wait_time = difficulty_step_time
	difficulty_timer.one_shot = false
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	add_child(difficulty_timer)
	difficulty_timer.start()

	boss_timer = Timer.new()
	boss_timer.wait_time = 180.0  # 3 minutos
	boss_timer.one_shot = false
	boss_timer.timeout.connect(_on_boss_timer_timeout)
	add_child(boss_timer)
	boss_timer.start()

func _on_spawn_timer_timeout():
	if enemy_scenes.is_empty():
		return

	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	var chosen_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = chosen_scene.instantiate()
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * spawn_radius
	enemy.global_position = player.global_position + offset

	if enemy.has_method("apply_health_multiplier"):
		enemy.apply_health_multiplier(health_multiplier)

	get_tree().current_scene.add_child(enemy)

	print("[SPAWN] Enemigo creado - intervalo actual: %.2f s" % spawn_interval)

func _on_difficulty_timer_timeout():
	var old_interval = spawn_interval
	spawn_interval = max(min_interval, spawn_interval - interval_step)
	$SpawnTimer.wait_time = spawn_interval

	print("[DIFICULTAD+] Intervalo reducido de %.2f → %.2f segundos" % [old_interval, spawn_interval])

func get_health_multiplier():
	return health_multiplier

func _on_boss_timer_timeout():
	if boss_enemy_scenes.is_empty():
		push_error("No hay escenas de jefe configuradas en 'boss_enemy_scenes'")
		return

	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	var boss_scene = boss_enemy_scenes[randi() % boss_enemy_scenes.size()]
	var boss = boss_scene.instantiate()
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * spawn_radius
	boss.global_position = player.global_position + offset

	if boss.has_method("apply_health_and_damage_multipliers"):
		boss.apply_health_and_damage_multipliers(health_multiplier * 10.0, 10.0)

	get_tree().current_scene.add_child(boss)

	print("[SPAWN BOSS] Jefe invocado con vida ×3 y daño ×3")
