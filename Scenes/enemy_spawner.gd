extends Node

@export var enemy_scene: PackedScene
@export var spawn_radius := 300.0

func _ready():
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var angle = randf() * TAU
		var offset = Vector2.RIGHT.rotated(angle) * spawn_radius
		enemy.global_position = player.global_position + offset
		get_tree().current_scene.add_child(enemy)
