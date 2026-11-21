extends Resource
class_name DifficultySettings

@export var waves_difficulty: Array[WaveDifficulty] = []

func get_wave_difficulty(wave: int) -> WaveDifficulty:
	var result :=	WaveDifficulty.new()
	for difficulty in waves_difficulty:
		if wave >= difficulty.wave:
			result = difficulty
		else: break

	return result
