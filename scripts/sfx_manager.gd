extends Node2D
class_name SFXManager

@export var grumble_volume := 0.0
@export var rain_fade_in := 1.0
@export var rain_fade_out := 1.0


@onready var meteorite_sfx: AudioStreamPlayer = $MeteoriteRainSFX
@onready var game_over_sfx: AudioStreamPlayer = $GameOverSFX
@onready var place_block_sfx: SoundPool = $PlaceBlockSFX
@onready var meteoriteImpact_sfx: SoundPool = $MeteoriteImpactSFX
@onready var newLine_sfx: SoundPool = $NewLineSFX
@onready var coin_sfx: SoundPool = $CoinSFX
@onready var health_sfx: SoundPool = $HealthSFX
@onready var blockDestroyed_sfx: SoundPool = $BlockDestroyedSFX
@onready var cityImpact_sfx: SoundPool = $CityImpactSFX

func _ready() -> void:
	GameStoreInstance.wave_started.connect(on_rain_start)
	GameStoreInstance.wave_ended.connect(on_rain_stop)
	GameStoreInstance.game_over.connect(on_game_over)
	GameStoreInstance.blocks_added.connect(on_place_block)
	GameStoreInstance.damage_block.connect(on_block_hit)
	GameStoreInstance.destroy_block.connect(on_block_destoyed)
	GameStoreInstance.city_damaged.connect(on_city_hit)
	GameStoreInstance.lines_validated.connect(on_line)
	AnimCoordinator.should_play_anim.connect(on_animation)

	meteorite_sfx.volume_db = -80.0

func on_rain_start(_number: int):
	create_tween().tween_property(meteorite_sfx, "volume_db", grumble_volume, rain_fade_in)

func on_rain_stop():
	create_tween().tween_property(meteorite_sfx, "volume_db", -80.0, rain_fade_out)

func on_game_over():
	game_over_sfx.play()
	if meteorite_sfx.volume_db == grumble_volume:
		on_rain_stop()

func on_place_block(_positions):
	place_block_sfx.play_sfx()

func on_block_hit(_block):
	meteoriteImpact_sfx.play_sfx()

func on_block_destoyed(_block):
	blockDestroyed_sfx.play_sfx()

func on_city_hit(_hp):
	meteoriteImpact_sfx.play_sfx()
	cityImpact_sfx.play_sfx()

func on_line(_rows, _blocks):
	newLine_sfx.play_sfx()

func on_animation(animation: AnimationProperties):
	if animation.kind == AnimationProperties.AnimationKind.GOLD_BLOCK:
		coin_sfx.play()
	elif animation.kind == AnimationProperties.AnimationKind.SHIELD_BLOCK:
		health_sfx.play()
	elif animation.kind == AnimationProperties.AnimationKind.LINE || animation.kind == AnimationProperties.AnimationKind.CITY_INCOME:
			for x in 3:
				coin_sfx.play()
				await get_tree().create_timer(0.1).timeout
