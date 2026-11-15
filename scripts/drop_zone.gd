extends Area2D
class_name DropZone

@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var tilemap: TileMapLayer = $TileMap
@onready var preview_area: Node2D = $Preview
@onready var blocks_area: Node2D = $Blocks

@export var preview_block_prefab: PackedScene = preload("res://prefabs/preview_block.tscn")

var _is_cursor_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(BlockPiece.BLOCK_SIZE * GameStore.GRID_WIDTH, BlockPiece.BLOCK_SIZE * GameStore.GRID_HEIGHT)

	collisionShape.shape = rectangle

	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)

	tilemap.position = Vector2(-float(GameStore.GRID_WIDTH) / 2 * BlockPiece.BLOCK_SIZE, -float(GameStore.GRID_HEIGHT) / 2 * BlockPiece.BLOCK_SIZE)
	for x in range(0, GameStore.GRID_WIDTH):
		for y in range(0, GameStore.GRID_HEIGHT):
			tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0,0))

	GameStoreInstance.on_tetromino_placeable.connect(on_block_placeable)

func on_mouse_enter():
	_is_cursor_inside = true

func on_mouse_exit():
	_is_cursor_inside = false
	GameStoreInstance.update_cursor_position(Vector2i(-1, -1))

func _process(_delta: float) -> void:
	if GameStoreInstance.is_dragging and _is_cursor_inside:
		var local_pos := get_global_mouse_position() - tilemap.global_position
		GameStoreInstance.update_cursor_position(get_coordinates(local_pos))

func get_coordinates(local_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(local_pos)

func on_block_placeable(placeable: bool, positions: Array[Vector2i]):
		preview_area.get_children().map(func (block: Node): block.queue_free())
		if placeable:
			for block_position in positions:
				var global_pos := tilemap.map_to_local(block_position) + tilemap.global_position
				var preview: PreviewBlock = preview_block_prefab.instantiate()
				preview_area.add_child(preview)
				preview.global_position = global_pos
