extends Timer
class_name  WaveTimer

@export var time_before_wave := 120.0
@export var wave_duration := 10.0

func _ready() -> void:
	GameStoreInstance.wave_started.connect(on_wave_start)
	GameStoreInstance.wave_ended.connect(on_wave_end)
	timeout.connect(on_timeout)

	start(time_before_wave)

func on_timeout():
	if !GameStoreInstance.wave_active:
			GameStoreInstance.start_wave()
	else:
		GameStoreInstance.stop_wave()

func on_wave_start(_number: int):
	start(wave_duration)

func on_wave_end():
	start(time_before_wave)

func _process(_delta: float) -> void:
	if !GameStoreInstance.wave_active && !is_stopped():
		GameStoreInstance.update_time_to_wave(time_left / time_before_wave)
