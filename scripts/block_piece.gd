extends StaticBody2D
class_name BlockPiece

const BLOCK_SIZE: float = 48
const LINE_VALIDATION_DURATION: float = .7

@export var unplaceable_opacity: float = 0.5
@export var plaecable_opacity: float = 1.0

@export var standardTexture: Texture2D
@export var weakTexture: Texture2D
@export var strongTexture: Texture2D
@export var goldTexture: Texture2D
@export var shieldTexture: Texture2D

var _type: BlockProperties.BlockType = BlockProperties.BlockType.STANDARD
var block_id: int = -1
var collideable := false:
	set(value):
		collideable = value
		collision_layer = scan_collision if true else 0
	get:
		return collideable

@onready var sprite: Sprite2D = $Sprite2D
@onready var valid_sprite: Sprite2D = $ValidSprite
@onready var cracks: Sprite2D = $Cracks
@onready var anim_mask: Sprite2D = $DamageMask
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles

@export var anim_duration := 0.8
@export var cracks_textures: Array[Texture2D]
@export var damage_color: Color = Color.RED
@export var activate_color: Color = Color.WHITE

@export var scan_collision := 2

var anim_tween: Tween = null

func _ready() -> void:
	cracks.visible = false
	anim_mask.modulate = Color.TRANSPARENT
	collision_layer = 0

func set_placeable(placeable: bool):
	modulate = Color(Color.WHITE, plaecable_opacity if placeable else unplaceable_opacity)

func set_type(value: BlockProperties.BlockType):
	_type = value
	sprite.texture = {
		BlockProperties.BlockType.STANDARD: standardTexture,
		BlockProperties.BlockType.WEAK: weakTexture,
		BlockProperties.BlockType.STRONG: strongTexture,
		BlockProperties.BlockType.GOLD: goldTexture,
		BlockProperties.BlockType.SHIELD: shieldTexture
	}[_type]

func validate_line():
	create_tween().tween_property(valid_sprite, "modulate", Color(Color.WHITE, 1), LINE_VALIDATION_DURATION
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func damage(hp: int, total: int):
	animate_mask(damage_color)

	var texture_index := floori((1.0 - (float(hp) / float(total))) * float(cracks_textures.size() + 1)) - 1
	if texture_index >= 0:
		cracks.visible = true
		cracks.texture = cracks_textures[min(cracks_textures.size() - 1, texture_index)]

func animate_mask(color: Color):
	if anim_tween != null && anim_tween.is_running():
		anim_tween.stop()
	anim_mask.modulate = color
	anim_tween = create_tween()
	anim_tween.tween_property(anim_mask, "modulate", Color(color, 0.0), anim_duration
		).set_ease(Tween.EASE_IN)

func explode() -> GPUParticles2D:
	explosion_particles.restart()
	return explosion_particles

func activate():
	animate_mask(activate_color)
