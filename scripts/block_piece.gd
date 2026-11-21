extends Area2D
class_name BlockPiece

const BLOCK_SIZE: float = 48
const LINE_VALIDATION_DURATION: float = .7

@export var unplaceable_opacity: float = 0.5
@export var plaecable_opacity: float = 1.0

@export var standardTexture: Texture2D
@export var weakTexture: Texture2D
@export var strongTexture: Texture2D
@export var goldTexture: Texture2D

var _type: BlockProperties.BlockType = BlockProperties.BlockType.STANDARD
var block_id: int = -1

@onready var sprite: Sprite2D = $Sprite2D
@onready var valid_sprite: Sprite2D = $ValidSprite
@onready var cracks: Sprite2D = $Cracks
@onready var damage_mask: Sprite2D = $DamageMask
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles

@export_range(0.0, 1.0, 0.05) var damage_mask_max_alpha := 0.70
@export var damage_duration := 0.5
@export var cracks_textures: Array[Texture2D]

var dmg_tween: Tween = null

func _ready() -> void:
	cracks.visible = false
	damage_mask.modulate = Color.TRANSPARENT

func set_placeable(placeable: bool):
	modulate = Color(Color.WHITE, plaecable_opacity if placeable else unplaceable_opacity)

func set_type(value: BlockProperties.BlockType):
	_type = value
	sprite.texture = {
		BlockProperties.BlockType.STANDARD: standardTexture,
		BlockProperties.BlockType.WEAK: weakTexture,
		BlockProperties.BlockType.STRONG: strongTexture,
		BlockProperties.BlockType.GOLD: goldTexture,
	}[_type]

func validate_line():
	create_tween().tween_property(valid_sprite, "modulate", Color(Color.WHITE, 1), LINE_VALIDATION_DURATION
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func set_placed():
	body_entered.connect(on_body_enter)

func on_body_enter(body: Node):
	if body is Meteorite:
		var meteorite := body as Meteorite
		GameStoreInstance.hit_block(block_id, meteorite.strength)
		meteorite.explode()

func damage(hp: int, total: int):
	if dmg_tween != null && dmg_tween.is_running():
		dmg_tween.stop()
	damage_mask.modulate = Color(Color.WHITE, damage_mask_max_alpha)
	dmg_tween = create_tween()
	dmg_tween.tween_property(damage_mask, "modulate", Color(Color.WHITE, 0.0), damage_duration
		).set_ease(Tween.EASE_IN)

	cracks.visible = true
	var texture_index := floori((1.0 - (float(hp) / float(total))) * float(cracks_textures.size()))
	cracks.texture = cracks_textures[min(cracks_textures.size() - 1, texture_index)]

func explode() -> GPUParticles2D:
	explosion_particles.restart()
	return explosion_particles
