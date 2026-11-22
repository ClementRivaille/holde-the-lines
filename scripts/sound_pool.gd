extends AudioStreamPlayer
class_name SoundPool

@export var max_instances := 10
@export_range(0.0, 1.0, 0.01) var pitch_variation := 0.0
@export var random_stream: Array[AudioStream] = []

func play_sfx():
	if get_children().size() < max_instances:
		_play()

func _play():
	var player = AudioStreamPlayer.new()
	add_child(player)

	player.volume_db = volume_db
	player.bus = bus
	player.stream = stream
	if random_stream.size() > 0:
		player.stream = random_stream[randi() % random_stream.size()]
	player.pitch_scale = 1.0 - pitch_variation + randf() * pitch_variation * 2

	player.play()
	await player.finished
	player.queue_free()
