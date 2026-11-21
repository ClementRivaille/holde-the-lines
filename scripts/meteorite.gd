extends RigidBody2D
class_name Meteorite

signal on_delete(meteorite: Meteorite)
signal on_explode(meteorite: Meteorite)

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Trail
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles

@export var min_width: float = 24.0
@export var max_width: float = 46.0

@export var min_strength := 20
@export var max_strength := 40

@export var trail_width := 0.8
@export var collision_width := 0.8

@export var min_speed := 1.0
@export var max_speed := 2.0

@export var min_trail_alpha := 0.6

@export var max_trail_points = 40

var _strength := 0
var _stopped := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trail.modulate = Color(Color.WHITE, randf_range(min_trail_alpha, 1.0))
	gravity_scale = randf_range(min_speed, max_speed)

	body_entered.connect(on_collide)

func set_strength(strength: float):
	_strength = lerp(min_strength, max_strength, strength)
	var width := lerpf(min_width, max_width, strength)

	var circle: CircleShape2D = collision.shape
	circle.radius = width * collision_width / 2.0

	trail.width = width * trail_width
	sprite.scale = Vector2.ONE * width / sprite.texture.get_width()

func _physics_process(_delta: float) -> void:
	update_trail()

	if _stopped && trail.points.size() == 0:
		on_delete.emit(self)

func update_trail():
	if trail.points.size() == max_trail_points || (_stopped && trail.points.size() > 0):
		trail.remove_point(0)
	if !_stopped:
		trail.add_point(global_position)

func stop():
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
	update_trail()
	_stopped = true

func explode():
	stop()
	sprite.visible = false
	explosion_particles.restart()
	on_explode.emit(self)

func on_collide(body: Node):
	if !_stopped:
		if body is BlockPiece:
			var block := body as BlockPiece
			if block.collideable:
				GameStoreInstance.hit_block(block.block_id, _strength)
				explode()
		elif body is CityDome:
			GameStoreInstance.hit_city(_strength)
			explode()
