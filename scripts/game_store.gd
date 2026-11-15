extends Node
class_name GameStore

const GRID_WIDTH := 10
const GRID_HEIGHT := 20

signal on_drag
signal on_drop
signal on_tetromino_placeable(value: bool, positions: Array[Vector2])
signal cursor_pos_changed(value: Vector2)

var grid_content: Array[Array]

var is_dragging := false
var hand_tetromino: Array[Array]
var cursor_position: Vector2 = Vector2(-1, -1)
var can_be_placed := false
var droped_blocks: Array[Vector2]

func _ready() -> void:
	for row_idx in GRID_HEIGHT:
		grid_content.append(range(GRID_WIDTH).map(func (_idx): return 0))

func grab_tetromino(tetromino: Array[Array]):
	is_dragging = true
	hand_tetromino = tetromino
	on_drag.emit()

func release_tetromino():
	is_dragging = false
	on_drop.emit()

func check_tetromino_drop_position(cursor_x: int, cursor_y: int):
	var center := floori(float(hand_tetromino.size()) / 2.0)

	# Find the highest row from cursor when block can fall
	var target_row := cursor_y
	var candidate: Array[Vector2] = []
	for row in range(target_row, GRID_HEIGHT):
		var center_pos: Vector2 = Vector2(cursor_x, row)
		var has_conflict := false
			# Check validity of every cell of tetromino
		for row_test in range(hand_tetromino.size()):
			var cell_row := center_pos.y - center + row_test
			for col_test in range(hand_tetromino.size()):
				var cell_col = center_pos.x - center + col_test
				var tetromino_cell: int = hand_tetromino[row_test][col_test]
				if tetromino_cell > 0:
					# Out of drop zone
					if cell_col < 0 || cell_col >= GRID_HEIGHT || cell_row < 0 || cell_row >= GRID_WIDTH:
						has_conflict = true
						continue
					# Conflict
					var cell: int = grid_content[cell_row][cell_col]
					if cell > 0:
						has_conflict = true

		if !has_conflict:
			# Write a valid candidate position
			candidate = []
			for row_candidate in range(hand_tetromino.size()):
				var cell_row := center_pos.y - center + row_candidate
				for col_candidate in range(hand_tetromino.size()):
					var cell_col = center_pos.x - center + col_candidate
					candidate.append(Vector2(cell_col, cell_row))

	if candidate.size() > 0:
		can_be_placed = true
		droped_blocks = candidate
		on_tetromino_placeable.emit(can_be_placed, droped_blocks)
