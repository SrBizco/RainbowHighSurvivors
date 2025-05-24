extends Node

@onready var music = $MusicPlayer

# Reproduce música de fondo (loop)
func play_music(stream: AudioStream):
	if stream == null: return
	music.stream = stream
	music.play()

# Reproduce un efecto de sonido individual (simultáneos permitidos)
func play_sfx(stream: AudioStream):
	if stream == null: return
	if not is_inside_tree():
		print("❌ AudioManager no está en el árbol de nodos.")
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "Master"  # Cambiá si usás un bus personalizado
	sfx_player.autoplay = false

	add_child(sfx_player)
	sfx_player.play()

	sfx_player.finished.connect(func():
		sfx_player.queue_free()
	)
