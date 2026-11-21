extends Node2D
class_name MeteoriteSpawner

@export var min_delay := 0.3
@export var max_delay := 0.6

@export var width := 600
@export var active := false

@export var meteorite_prefab: PackedScene = preload("res://prefabs/meteorite.tscn")
@export var is_main := false
@export var end_wave_delay := 0.5

var _fromX: float = 0.0
var _toX: float = 0.0

@onready var collision: CollisionShape2D = $DeleteZone/CollisionShape2D
@onready var particles: Node2D = $Particles
@onready var meteorites_parent: Node2D = $SpawnedMeteorites


var _wave_ending := false

func _ready() -> void:
	_fromX = - width / 2.0
	_toX = width / 2.0

	GameStoreInstance.wave_started.connect(on_start_wave)
	GameStoreInstance.wave_stopped.connect(on_wave_stopped)

	if (active):
		spawn_meteorite()

func on_body_enter_delete_zone(body: Node2D):
	if (body is Meteorite):
		var meteorite: Meteorite = body as Meteorite
		meteorite.stop()

func on_delete_meteorite(meteorite: Meteorite):
	meteorite.queue_free()
	if _wave_ending:
		if meteorites_parent.get_children().size() == 1:
			_wave_ending = false
			await get_tree().create_timer(end_wave_delay).timeout
			GameStoreInstance.end_wave()

func spawn_meteorite():
	if !active: return

	var meteorite: Meteorite = meteorite_prefab.instantiate()
	meteorites_parent.add_child(meteorite)
	meteorite.on_delete.connect(on_delete_meteorite)
	meteorite.on_explode.connect(on_meteorite_explode)

	meteorite.position = Vector2(randf_range(_fromX, _toX), 0)

	get_tree().create_timer(randf_range(min_delay, max_delay)).timeout.connect(spawn_meteorite)

func on_meteorite_explode(meteorite: Meteorite):
	var explosion := meteorite.explosion_particles
	explosion.reparent(particles, true)
	await explosion.finished
	explosion.queue_free()

func on_start_wave(_number: int):
	active = true
	spawn_meteorite()

func on_wave_stopped():
	active = false
	_wave_ending = is_main
