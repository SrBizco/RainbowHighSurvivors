extends Area2D

@export var damage := 1
@export var duration := 3.0
@export var damage_interval := 0.5  # segundos

var hit_timestamps := {}

func _ready():
	await get_tree().create_timer(duration).timeout
	queue_free()

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Enemy") and body.has_method("take_damage"):
			var id = str(body.get_instance_id())
			var now = Time.get_ticks_msec() / 1000.0
			var last_hit = hit_timestamps.get(id, -INF)
			if now - last_hit >= damage_interval:
				body.take_damage(damage)
				hit_timestamps[id] = now
