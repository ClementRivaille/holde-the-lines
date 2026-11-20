extends RigidBody2D
class_name Meteorite

signal on_delete(meteorite: Meteorite)

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Trail

@export var min_width: float = 24.0
@export var max_width: float = 46.0

@export var trail_width := 0.8
@export var collision_width := 0.8

@export var min_speed := 1.0
@export var max_speed := 2.0

@export var min_trail_alpha := 0.6

@export var max_trail_points = 40

var _stopped := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = randf_range(min_width, max_width)

	var circle: CircleShape2D = collision.shape
	circle.radius = width * collision_width / 2.0

	trail.width = width * trail_width
	sprite.scale = Vector2.ONE * width / sprite.texture.get_width()
	trail.modulate = Color(Color.WHITE, randf_range(min_trail_alpha, 1.0))

	gravity_scale = randf_range(min_speed, max_speed)

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
