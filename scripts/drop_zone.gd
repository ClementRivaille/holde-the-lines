extends Area2D
class_name DropZone

@onready var collisionShape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(BlockPiece.BLOCK_SIZE * GameStore.GRID_WIDTH, BlockPiece.BLOCK_SIZE * GameStore.GRID_HEIGHT)

	collisionShape.shape = rectangle

	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)

func on_mouse_enter():
	pass

func on_mouse_exit():
	pass
