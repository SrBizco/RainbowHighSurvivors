extends Area2D

@export var xp_value := 3
@export var attraction_range := 100.0
@export var attraction_speed := 200.0

var attracted := false
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		queue_free()

func _physics_process(delta):
	if attracted:
		var dir = (player.global_position - global_position).normalized()
		position += dir * attraction_speed * delta
	else:
		if global_position.distance_to(player.global_position) <= attraction_range:
			attracted = true

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.add_xp(xp_value)
		queue_free()
