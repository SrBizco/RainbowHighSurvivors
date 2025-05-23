extends CharacterBody2D

@export var speed := 60
@export var max_health := 3
var health := max_health
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	print("Enemigo golpeado. Vida restante: ", health)

	if health <= 0:
		drop_xp()
		queue_free()

func drop_xp():
	var xp_gem = preload("res://Scenes/exp_gem.tscn").instantiate()
	xp_gem.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", xp_gem)
