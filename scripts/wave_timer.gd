extends Timer
class_name  WaveTimer

@export var time_before_wave := 120.0
@export var wave_duration := 10.0
@export var wave_delay := 3.0

var _is_wave_delaying := false

func _ready() -> void:
	GameStoreInstance.wave_started.connect(on_wave_start)
	GameStoreInstance.wave_stopped.connect(on_wave_stop)
	timeout.connect(on_timeout)

	start(time_before_wave)

func on_timeout():
	if !GameStoreInstance.wave_active:
		if _is_wave_delaying:
			_is_wave_delaying = false
			start(time_before_wave)
		else:
			GameStoreInstance.start_wave()
	else:
		GameStoreInstance.stop_wave()

func on_wave_start(_number: int):
	start(wave_duration)

func on_wave_stop():
	_is_wave_delaying = true
	start(wave_delay)

func _process(_delta: float) -> void:
	if !GameStoreInstance.wave_active && !_is_wave_delaying && !is_stopped():
		GameStoreInstance.update_time_to_wave(time_left / time_before_wave)
