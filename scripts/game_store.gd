extends Node
class_name GameStore

const GRID_WIDTH := 10
const GRID_HEIGHT := 20

const CITY_HP_TOTAL := 300
const MONEY_START := 100
const LINE_GAIN := 30
const LINE_BONUS := 1.5
const GOLD_GAIN := 2
const CITY_INCOME = 20
const SHIELD_BLOCK_GAIN := 20

enum GameState { START_SCREEN, PLAYING, END_SCREEN }

signal block_pool_initiated
signal game_started
signal game_over
signal game_reset

signal on_drag
signal on_drop(placed: bool)
signal on_tetromino_placeable(value: bool, positions: Array[Vector2i])
signal cursor_pos_changed(value: Vector2i)
signal blocks_added(positions: Array[Vector2i])
signal lines_validated(rows: Array[int], blocks: Array[int])
signal remove_blocks(ids: Array[int])
signal move_block(id: int, position: Vector2i)

signal damage_block(block: BlockProperties)
signal destroy_block(id: int)
signal city_damaged(hp: int)
signal city_heal(hp: int)

signal wave_started(number: int)
signal wave_stopped
signal wave_ended
signal time_to_wave_updated(remaining: float)

signal money_updated(value: int, diff: int)

var grid_content: Array[Array]

var is_dragging := false
var hand_tetromino: Array[Array]
var cursor_position: Vector2i = Vector2i(-1, -1)
var can_be_placed := false
var droped_blocks: Array[Vector2i]

var block_pool_instance: BlockPool

var city_hp := 0

var time_to_wave := 1.0
var wave_number := 0
var wave_active := false

var money := 0

var difficulty_settings: DifficultySettings = preload("res://resources/game_difficulty.tres")

var state: GameState = GameState.START_SCREEN

func _ready() -> void:
	for row_idx in GRID_HEIGHT:
		grid_content.append(range(GRID_WIDTH).map(func (_idx): return -1))


func start_game():
	init_game()
	state = GameState.PLAYING
	game_started.emit()

func init_game():
	city_hp = CITY_HP_TOTAL
	wave_number = 0
	time_to_wave = 1.0
	money = MONEY_START

func grab_tetromino(tetromino: Array[Array]):
	is_dragging = true
	hand_tetromino = tetromino.duplicate()
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
		on_tetromino_placeable.emit(false, droped_blocks)
		check_line()

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
	hand_tetromino = shape.duplicate()
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

func check_line():
	var lines: Array[int] = []

	for row_idx in grid_content.size():
		var row: Array = grid_content[row_idx]
		if row.all(func (value: int): return value >= 0):
			lines.append(row_idx)

	if lines.size() > 0:
		var blocks: Array[int] = []
		for row_idx in lines:
			grid_content[row_idx].map(func (id: int): blocks.append(id))
		lines_validated.emit(lines, blocks)

		var money_gain := 0
		for i in lines.size():
			money_gain += roundi(float(LINE_GAIN) * LINE_BONUS**i )
			AnimCoordinator.queue_animation(
				AnimationProperties.new(AnimationProperties.AnimationKind.LINE, -1, lines[i]))
		money += money_gain
		money_updated.emit(money, money_gain)
		AnimCoordinator.play_queued_animations()

		# Wait for animation before removing blocks
		await get_tree().create_timer(BlockPiece.LINE_VALIDATION_DURATION).timeout

		# Delete lines
		for row_idx in lines:
			var row: Array = grid_content[row_idx]
			for col in row.size():
				row[col] = -1
		remove_blocks.emit(blocks)

		# Move blocks above down, starting from the lowest line
		var movements: Dictionary[int, Vector2i] = {}
		var row_moved := 0
		lines.reverse()
		for line_idx in lines:
			for row_idx in range(line_idx - 1 + row_moved, -1, -1):
				if row_idx == GRID_HEIGHT - 1: continue
				var row: Array = grid_content[row_idx]
				var lower_row: Array = grid_content[row_idx + 1]
				for col in row.size():
					if row[col] >= 0:
						lower_row[col] = row[col]
						row[col] = -1
						movements[lower_row[col]] = Vector2i(col, row_idx + 1)
			row_moved += 1
		for block_id in movements.keys():
			move_block.emit(block_id, movements[block_id])

func hit_block(id: int, dmg: int):
	if !block_pool_instance.block_exists(id): return

	var block := block_pool_instance.get_block_by_id(id)
	block.hp = max(0, block.hp - dmg)
	if block.hp > 0:
		damage_block.emit(block)
	else:
		var position := get_block_position(id)
		grid_content[position.y][position.x] = -1
		destroy_block.emit(id)
		if is_dragging:
			check_tetromino_drop_position(cursor_position.x, cursor_position.y)

func hit_city(damages: int):
	if state != GameState.PLAYING: return

	city_hp = max(0, city_hp - damages)
	city_damaged.emit(city_hp)
	if city_hp == 0:
		end_game()

func start_wave():
	wave_active = true
	wave_started.emit(wave_number)

func stop_wave():
	wave_active = false
	wave_number += 1
	wave_stopped.emit()

func end_wave():
	var gain := CITY_INCOME
	var extra_hp := 0
	AnimCoordinator.queue_animation(AnimationProperties.new(AnimationProperties.AnimationKind.CITY_INCOME))
	for row_idx in range(grid_content.size() - 1, -1, -1):
		var row := grid_content[row_idx]
		for id in row:
			if id >= 0:
				var block := block_pool_instance.get_block_by_id(id)
				if block.type == BlockProperties.BlockType.GOLD:
					gain += GOLD_GAIN
					AnimCoordinator.queue_animation(AnimationProperties.new(AnimationProperties.AnimationKind.GOLD_BLOCK, block.id))
				elif block.type == BlockProperties.BlockType.SHIELD:
					extra_hp += SHIELD_BLOCK_GAIN
					AnimCoordinator.queue_animation(AnimationProperties.new(AnimationProperties.AnimationKind.SHIELD_BLOCK, block.id))

	money += gain
	money_updated.emit(money, gain)
	if extra_hp > 0:
		city_hp = min(CITY_HP_TOTAL, city_hp + extra_hp)
		city_heal.emit(city_hp)
	wave_ended.emit()
	AnimCoordinator.play_queued_animations()

func update_time_to_wave(value: float):
	time_to_wave = value
	time_to_wave_updated.emit(time_to_wave)

func spend_money(price: int):
	assert(price <= money, "Bought an overpriced item")
	money = money - price
	money_updated.emit(money, -price)

func get_current_difficulty() -> WaveDifficulty:
	return difficulty_settings.get_wave_difficulty(wave_number)

func end_game():
	if is_dragging:
		is_dragging = false
		hand_tetromino = []
		can_be_placed = false
		droped_blocks = []
		on_tetromino_placeable.emit(false, droped_blocks)
		on_drop.emit(false)

	wave_active = false
	state = GameState.END_SCREEN
	game_over.emit()

func restart_game():
	block_pool_instance.clear()
	for row in grid_content:
		for i in row.size():
			row[i] = -1
	init_game()
	state = GameState.PLAYING
	game_reset.emit()
