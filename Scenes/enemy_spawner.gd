extends Node

@export var enemy_scene: PackedScene
@export var spawn_radius := 500.0
@export var spawn_interval := 2.0  # tiempo inicial entre enemigos
@export var min_interval := 0.3    # tiempo mínimo permitido
@export var interval_step := 0.2   # cuánto reducir cada vez

func _ready():
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTimer.wait_time = spawn_interval

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var angle = randf() * TAU
		var offset = Vector2.RIGHT.rotated(angle) * spawn_radius
		enemy.global_position = player.global_position + offset
		get_tree().current_scene.add_child(enemy)

		# 🪵 Log detallado
		print("[SPAWN] Enemigo creado - tiempo actual entre spawns:", $SpawnTimer.wait_time)

func increase_difficulty():
	var old_interval = spawn_interval
	spawn_interval = max(min_interval, spawn_interval - interval_step)
	$SpawnTimer.wait_time = spawn_interval

	print("[DIFICULTAD+] Tiempo de spawneo reducido de %.2f → %.2f segundos" % [old_interval, spawn_interval])
