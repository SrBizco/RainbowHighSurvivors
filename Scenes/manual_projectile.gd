extends Area2D

@export var speed := 400
@export var damage := 1
var direction := Vector2.ZERO

func _ready():
	$Timer.timeout.connect(queue_free)
	connect("body_entered", _on_body_entered)

func _process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
