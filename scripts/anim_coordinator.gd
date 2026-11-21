extends Node2D
class_name AnimationCoordinator

signal should_play_anim(anim: AnimationProperties)

const ANIMATIONS_DELAY := 0.16
const MULTIPLE_NUMBER := 3
const MULTIPLE_OFFSET := 30.0
const MULTIPLE_DELAY := 0.05

var animated_icon_prefab: PackedScene = preload("res://prefabs/animated_icon.tscn")
var animation_queue: Array[AnimationProperties] = []

func queue_animation(anim: AnimationProperties):
	animation_queue.append(anim)

func play_queued_animations():
	var animations = animation_queue.duplicate()
	animation_queue.clear()

	for anim in animations:
		should_play_anim.emit(anim)
		await get_tree().create_timer(ANIMATIONS_DELAY).timeout

func play_gold_animation(world_pos: Vector2, multiple: bool = false):
	if multiple:
		for i in range(-1, -1 + MULTIPLE_NUMBER):
			var offset_position := Vector2(world_pos.x - MULTIPLE_OFFSET * i, world_pos.y)
			_add_animated_icon(offset_position)
			await get_tree().create_timer(MULTIPLE_DELAY).timeout
	else:
		_add_animated_icon(world_pos)

func _add_animated_icon(world_pos: Vector2):
	var icon: AnimatedIcon = animated_icon_prefab.instantiate()
	add_child(icon)
	icon.global_position = world_pos
	icon.animation_finished.connect(func (): icon.queue_free())
