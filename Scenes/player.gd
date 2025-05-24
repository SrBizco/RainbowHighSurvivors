extends CharacterBody2D

@export var speed := 200
@export var max_health := 5
@export var projectile_scene: PackedScene
@export var aoe_projectile_scene: PackedScene
@export var manual_projectile_scene: PackedScene
@onready var sprite = $Sprite  # AnimatedSprite2D

var health: int
signal player_died
var spacing = 20.0
var is_horizontal = abs(last_movement_direction.x) > abs(last_movement_direction.y)

# Power-up stats
var attraction_range: float = 100.0
var damage_multiplier: float = 1.0
var auto_projectile_count := 1
var aoe_count: int = 0
var manual_projectile_count: int = 0
var regen_timer: Timer = null
var last_movement_direction: Vector2 = Vector2.RIGHT

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

	if direction != Vector2.ZERO:
		last_movement_direction = direction

		# 🟢 Reproducir animación solo si no está activa
		if not sprite.is_playing():
			sprite.play("walk")

		# 🔁 Flip horizontal si se mueve en X
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		sprite.stop()

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
	# 🔫 Disparo automático múltiple
	var enemies = get_tree().get_nodes_in_group("Enemy")

	# Ordenarlos por cercanía
	enemies.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
)
	# Disparar hacia los enemigos más cercanos (sin repetir)
	for i in range(min(auto_projectile_count, enemies.size())):
		var target = enemies[i]
		if not target: continue
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.direction = (target.global_position - global_position).normalized()
		get_tree().current_scene.add_child(projectile)
		AudioManagerSingleton.play_sfx(load("res://Audio/AutoShot.wav"))


	# 💥 Proyectiles de área (AOE)
	for i in aoe_count:
		var aoe = aoe_projectile_scene.instantiate()
		var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		aoe.global_position = global_position + offset
		get_tree().current_scene.add_child(aoe)

	# ➡️ Proyectiles frontales (manual_projectile)
	for i in manual_projectile_count:
		var manual_proj = manual_projectile_scene.instantiate()

		var relative = (i - (manual_projectile_count - 1) / 2.0)
		var offset = Vector2.ZERO

		if is_horizontal:
			offset.y = spacing * relative  # 🟢 desplazamiento en Y cuando disparás horizontal
		else:
			offset.x = spacing * relative  # 🟢 desplazamiento en X cuando disparás vertical

		manual_proj.global_position = global_position + offset
		manual_proj.direction = last_movement_direction.normalized()
		get_tree().current_scene.add_child(manual_proj)
		AudioManagerSingleton.play_sfx(load("res://Audio/ManualShot.mp3"))

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
		AudioManagerSingleton.play_sfx(load("res://Audio/LevelUp.wav"))
		xp_to_next_level = int(xp_to_next_level * 1.2)
		print("🔺 ¡Subiste a nivel ", level, "! XP necesaria para siguiente: ", xp_to_next_level)
		update_level_label()
		get_node("/root/Main/PowerUpSelector").show_selector()

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

func start_regeneration():
	if regen_timer == null:
		regen_timer = Timer.new()
		regen_timer.wait_time = 5.0
		regen_timer.one_shot = false
		regen_timer.timeout.connect(_on_regen_tick)
		add_child(regen_timer)
		regen_timer.start()
	else:
		regen_timer.wait_time = max(regen_timer.wait_time - 0.5, 1.0)  # mejora con nivel
		print("Tiempo de regeneración reducido a: ", regen_timer.wait_time)

func _on_regen_tick():
	if health < max_health:
		health += 1
		print("Regeneraste 1 vida. Vida actual: ", health)
		_update_health_bar()
