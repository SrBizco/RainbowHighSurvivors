extends Node

class_name PowerUpManager

const MAX_LEVEL = 8
var player: Node = null

func is_ready() -> bool:
	return player != null

var powerups = {
	"xp_range": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.attraction_range += 20.0,
		"description": func(level): return "Increases XP attraction range to %d px" % (100 + level * 20)
	},

	"speed": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.speed += 20,
		"description": func(level): return "Increases movement speed to %d" % (200 + level * 20)
	},

	"regen": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.start_regeneration(),
		"description": func(level): return "Heals 1 HP every %d sec" % int(6 - level * 0.5)
	},

	"aoe_blast": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.aoe_count += 1,
		"description": func(level): return "Blast damages enemies in range (%dx explosion)" % level
	},

	"manual_projectile": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.manual_projectile_count += 1,
		"description": func(level): return "Adds %d front-firing projectile(s)" % level
	},

	"damage_boost": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.damage_multiplier += 0.1,
		"description": func(level): return "Increases damage by %d%%" % int(10 * level)
	},

	"auto_projectile": {
		"level": 0,
		"apply": func():
			if is_ready():
				player.auto_projectile_count += 1,
		"description": func(level): return "Fires %d automatic projectile(s)" % level
	},
}

func set_player(p: Node):
	player = p

func get_available_powerups():
	var list = []
	for key in powerups.keys():
		if powerups[key]["level"] < MAX_LEVEL:
			list.append(key)
	return list

func apply_powerup(key: String):
	if not powerups.has(key): return
	if powerups[key]["level"] >= MAX_LEVEL: return

	powerups[key]["level"] += 1
	powerups[key]["apply"].call()

func get_powerup_level(key: String) -> int:
	if not powerups.has(key): return 0
	return powerups[key]["level"]

func get_powerup_description(key: String) -> String:
	if not powerups.has(key): return ""
	var lvl = powerups[key]["level"] + 1
	return powerups[key]["description"].call(lvl)
