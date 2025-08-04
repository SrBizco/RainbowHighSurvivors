extends Node

@onready var music = $MusicPlayer

func play_music(stream: AudioStream):
	if stream == null:
		return
	music.stream = stream
	music.bus = "Music"
	music.play()

func play_sfx(stream: AudioStream):
	if stream == null:
		return
	if not is_inside_tree():
		print("❌ AudioManager no está en el árbol.")
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "VFX"
	sfx_player.autoplay = false

	add_child(sfx_player)
	sfx_player.play()

	sfx_player.finished.connect(func():
		sfx_player.queue_free()
	)
