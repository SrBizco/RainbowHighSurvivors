extends Area2D

@export var speed := 300
@export var damage := 2
var direction := Vector2.ZERO

func _process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var player = get_tree().get_first_node_in_group("Player")
		var final_damage = damage
		if player:
			final_damage = int(damage * player.damage_multiplier)
		body.take_damage(final_damage)
		queue_free()
