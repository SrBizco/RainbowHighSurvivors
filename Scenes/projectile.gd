extends Area2D

@export var speed := 300
@export var damage := 1
var direction := Vector2.ZERO

func _process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
