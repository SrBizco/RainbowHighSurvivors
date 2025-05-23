extends CharacterBody2D

@export var speed := 200
@export var max_health := 5
@export var projectile_scene: PackedScene

var health: int
signal player_died

# Experiencia y nivel
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 10

func _ready():
	health = max_health
	xp = 0
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)
	_update_health_bar()
	_update_xp_bar()
	update_level_label()

func _physics_process(_delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		health -= 1
		_update_health_bar()

		print("¡El jugador fue golpeado! Vida actual: ", health)

		if health <= 0:
			print("¡Game Over!")
			player_died.emit()
			queue_free()

func _on_shoot_timer_timeout():
	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.direction = (closest_enemy.global_position - global_position).normalized()
		get_tree().current_scene.add_child(projectile)

func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest = null
	var min_distance = INF

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = enemy

	return closest

func _update_health_bar():
	var ratio := float(health) / max_health
	var fill := $HealthBarContainer/HealthFill

	fill.size.x = 100 * ratio
	fill.size.y = 10

	if ratio <= 0.25:
		fill.color = Color.RED
	elif ratio <= 0.5:
		fill.color = Color.YELLOW
	else:
		fill.color = Color.GREEN

func add_xp(amount: int):
	xp += amount
	print("Ganaste ", amount, " XP. Total: ", xp, "/", xp_to_next_level)

	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		print("🔺 ¡Subiste a nivel ", level, "! XP necesaria para siguiente: ", xp_to_next_level)
		update_level_label()

	_update_xp_bar()

func _update_xp_bar():
	if has_node("/root/Main/HUD/ExpBackground/ExpFill"):  # ajustar según ruta real
		var fill = get_node("/root/Main/HUD/ExpBackground/ExpFill")
		var ratio = float(xp) / xp_to_next_level
		fill.size.x = 500 * ratio
		fill.size.y = 12

func update_level_label():
	var level_label_path = "/root/Main/HUD/ExpBackground/LevelLabel"
	if has_node(level_label_path):
		var level_label = get_node(level_label_path) as Label
		level_label.text = "Lvl.%d" % level
