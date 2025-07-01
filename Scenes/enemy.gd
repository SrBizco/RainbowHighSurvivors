extends CharacterBody2D

@export var speed := 60
@export var max_health := 3
@export var damage_per_tick := 1
@export var damage_interval := 0.5 # segundos entre daños

@onready var sprite = $Sprite
var health := max_health
var player: Node2D = null
var damage_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Animación de caminar
		if not sprite.is_playing():
			sprite.play("walk")

		# Flip horizontal
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

		# Revisar colisiones
		var collision_count = get_slide_collision_count()
		for i in range(collision_count):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("Player"):
				damage_timer -= delta
				if damage_timer <= 0.0:
					collision.get_collider().take_damage(damage_per_tick)
					damage_timer = damage_interval

func take_damage(amount: int):
	health -= amount
	AudioManagerSingleton.play_sfx(load("res://Audio/EnemyHit.wav"))
	print("Enemigo golpeado. Vida restante: ", health)

	show_damage(amount)

	if health <= 0:
		drop_xp()
		queue_free()

func drop_xp():
	var xp_gem = preload("res://Scenes/exp_gem.tscn").instantiate()
	xp_gem.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", xp_gem)

func show_damage(amount: int):
	var damage_label_scene = preload("res://Scenes/damage_label.tscn")
	var damage_label = damage_label_scene.instantiate()
	add_child(damage_label)
	damage_label.position = Vector2(0, -10)
	damage_label.text = str(amount)
	damage_label.start_animation()
