extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_radius := 500.0
@export var initial_spawn_interval := 2.0
@export var min_interval := 0.5
@export var interval_step := 0.1
@export var difficulty_step_time := 10.0  # cada cuántos segundos se sube dificultad

var spawn_interval: float
var difficulty_timer := Timer.new()
var health_multiplier := 1.0  # 🔥 Nuevo: multiplicador de vida

func _ready():
	spawn_interval = initial_spawn_interval

	# Configurar SpawnTimer
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

	# Configurar DifficultyTimer
	difficulty_timer.wait_time = difficulty_step_time
	difficulty_timer.one_shot = false
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	add_child(difficulty_timer)
	difficulty_timer.start()

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

	# Pasar multiplicador de vida al enemigo
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
