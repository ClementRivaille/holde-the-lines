extends Node2D
class_name MeteoriteSpawner

@export var min_delay := 0.3
@export var max_delay := 0.6

@export var width := 600
@export var active := false

@export var meteorite_prefab: PackedScene = preload("res://prefabs/meteorite.tscn")

var _fromX: float = 0.0
var _toX: float = 0.0

@onready var collision: CollisionShape2D = $DeleteZone/CollisionShape2D
@onready var particles: Node2D = $Particles

func _ready() -> void:
	_fromX = - width / 2.0
	_toX = width / 2.0

	if (active):
		spawn_meteorite()

func on_body_enter_delete_zone(body: Node2D):
	if (body is Meteorite):
		var meteorite: Meteorite = body as Meteorite
		meteorite.stop()

func on_delete_meteorite(meteorite: Meteorite):
	meteorite.queue_free()

func spawn_meteorite():
	if !active: return

	var meteorite: Meteorite = meteorite_prefab.instantiate()
	add_child(meteorite)
	meteorite.on_delete.connect(on_delete_meteorite)
	meteorite.on_explode.connect(on_meteorite_explode)

	meteorite.position = Vector2(randf_range(_fromX, _toX), 0)

	get_tree().create_timer(randf_range(min_delay, max_delay)).timeout.connect(spawn_meteorite)

func on_meteorite_explode(meteorite: Meteorite):
	var explosion := meteorite.explosion_particles
	explosion.reparent(particles, true)
	await explosion.finished
	explosion.queue_free()
