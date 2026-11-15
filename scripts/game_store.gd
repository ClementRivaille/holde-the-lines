extends Node
class_name GameStore

const GRID_WIDTH := 10
const GRID_HEIGHT := 20

signal block_pool_initiated

signal on_drag
signal on_drop(placed: bool)
signal on_tetromino_placeable(value: bool, positions: Array[Vector2i])
signal cursor_pos_changed(value: Vector2i)
signal blocks_added(positions: Array[Vector2i])


var grid_content: Array[Array]

var is_dragging := false
var hand_tetromino: Array[Array]
var cursor_position: Vector2i = Vector2i(-1, -1)
var can_be_placed := false
var droped_blocks: Array[Vector2i]

var block_pool_instance: BlockPool

func _ready() -> void:
	for row_idx in GRID_HEIGHT:
		grid_content.append(range(GRID_WIDTH).map(func (_idx): return -1))

func grab_tetromino(tetromino: Array[Array]):
	is_dragging = true
	hand_tetromino = tetromino
	on_drag.emit()

func release_tetromino():
	is_dragging = false
	on_drop.emit(can_be_placed)

	if can_be_placed:
		var blocks_ids: Array[int] = []
		for row in hand_tetromino:
			for block_val: int in row:
				if block_val >= 0:
					blocks_ids.append(block_val)
		for idx in range(droped_blocks.size()):
			var block := droped_blocks[idx]
			grid_content[block.y][block.x] = blocks_ids[idx]
			var props := block_pool_instance.get_block_by_id(blocks_ids[idx])
			props.in_grid = true
		blocks_added.emit(droped_blocks.duplicate())
		droped_blocks = []
		can_be_placed = false
		on_tetromino_placeable.emit(false, [])

	hand_tetromino = []

func update_cursor_position(position: Vector2i):
	if position.x == cursor_position.x && position.y == cursor_position.y:
		return

	cursor_position = position
	cursor_pos_changed.emit(cursor_position)
	if cursor_position.x != -1 && cursor_position.y != -1 && is_dragging:
		check_tetromino_drop_position(cursor_position.x, cursor_position.y)
	elif can_be_placed:
		can_be_placed = false
		droped_blocks = []
		on_tetromino_placeable.emit(can_be_placed, droped_blocks)

func update_hand_tetromino(shape: Array[Array]):
	hand_tetromino = shape
	if is_dragging:
		check_tetromino_drop_position(cursor_position.x, cursor_position.y)

func check_tetromino_drop_position(cursor_x: int, cursor_y: int):
	var center := floori(float(hand_tetromino.size()) / 2.0)

	# Find the highest row from cursor when block can fall
	var target_row := cursor_y
	var candidate: Array[Vector2i] = []

	var has_conflict := false
	var row := target_row
	while row < GRID_HEIGHT && !has_conflict:
		var center_pos: Vector2 = Vector2(cursor_x, row)
		var is_outside := false
			# Check validity of every cell of tetromino
		for row_test in range(hand_tetromino.size()):
			var cell_row := center_pos.y - center + row_test
			for col_test in range(hand_tetromino.size()):
				var cell_col = center_pos.x - center + col_test
				var tetromino_cell: int = hand_tetromino[row_test][col_test]
				if tetromino_cell >= 0:
					# Out of drop zone
					if cell_col < 0 || cell_col >= GRID_WIDTH || cell_row < 0 || cell_row >= GRID_HEIGHT:
						is_outside = true
						continue
					# Conflict
					var cell: int = grid_content[cell_row][cell_col]
					if cell >= 0:
						has_conflict = true

		if !has_conflict && !is_outside:
			# Write a valid candidate position
			candidate = []
			for row_candidate in range(hand_tetromino.size()):
				var cell_row := center_pos.y - center + row_candidate
				for col_candidate in range(hand_tetromino.size()):
					var cell_col = center_pos.x - center + col_candidate
					if (hand_tetromino[row_candidate][col_candidate] >= 0):
						candidate.append(Vector2(cell_col, cell_row))

		row += 1

	can_be_placed = candidate.size() > 0
	droped_blocks = candidate
	on_tetromino_placeable.emit(can_be_placed, droped_blocks)

func register_block_pool(pool: BlockPool):
	block_pool_instance = pool
	block_pool_initiated.emit()

func get_block_at(position: Vector2i) -> BlockProperties:
	var id :int = grid_content[position.y][position.x]
	if id >= 0:
		return block_pool_instance.get_block_by_id(id)
	return null

func get_block_position(id: int) -> Vector2i:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid_content[y][x] == id:
				return Vector2i(x, y)
	return Vector2i(-1, -1)
