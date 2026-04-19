extends Node2D
## DiggingView — the main interactive digging area.
## Player traverses the grid in reading order (left→right, top→bottom).
## On grid completion the blocks refill and the player resets to the start.

signal tile_broken(ore: OreDefinition, position: Vector2)
signal row_cleared(depth: int)

const BREAK_LABEL_SCENE: String = "res://game/clicker/scenes/floating_label.tscn"
const WORKER_SPRITE_SCENE: String = "res://game/clicker/scenes/worker_sprite.tscn"
## Maximum worker sprites shown at once regardless of total worker count.
const MAX_VISIBLE_WORKERS: int = 8

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var background_rect: ColorRect = $BackgroundRect
@onready var depth_progress_bar: ProgressBar = $DepthProgressBar
@onready var break_particles: GPUParticles2D = $BreakParticles
@onready var worker_layer: Node2D = $WorkerLayer
@onready var player_miner: Node2D = $PlayerMiner

## Indexed [col][row] -> OreDefinition (null = empty/broken)
var _grid: Array = []
## HP remaining per cell: indexed [col][row]
var _hp: Array = []
## World seed for noise variation
var _world_seed: int = 0

var _config: ClickerConfig
var _floating_label_scene: PackedScene
var _worker_sprite_scene: PackedScene
var _worker_sprites: Array = []

# ── Traversal state ────────────────────────────────────────────────────────
var _cursor_col: int = 0
var _cursor_row: int = 0
var _blocks_broken_this_click: int = 0
var _mining_active: bool = false


func _ready() -> void:
	_config = ClickerDataManager.config
	_floating_label_scene = load(BREAK_LABEL_SCENE)
	_worker_sprite_scene = load(WORKER_SPRITE_SCENE)
	_world_seed = randi()
	ClickerGameState.depth_changed.connect(_on_depth_changed)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	player_miner.hit_frame.connect(_on_player_hit_frame)
	player_miner.move_finished.connect(_on_player_move_finished)
	_resize_to_grid()
	_generate_grid()
	_refresh_workers()
	_snap_player_to_cursor()


# ── Input ──────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if _mining_active:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_mining_sequence()
	elif event is InputEventScreenTouch and event.pressed:
		_start_mining_sequence()


# ── Mining loop ────────────────────────────────────────────────────────────

func _start_mining_sequence() -> void:
	if _mining_active:
		return
	if _cursor_row >= _config.grid_rows:
		return
	_mining_active = true
	_blocks_broken_this_click = 0
	_mine_current_block()


func _mine_current_block() -> void:
	# Skip null cells (shouldn't happen in normal flow, but defensive)
	if _grid[_cursor_col][_cursor_row] == null:
		_advance_and_move()
		return
	player_miner.start_digging()


## Called when the pickaxe animation reaches the impact frame.
func _on_player_hit_frame() -> void:
	var col: int = _cursor_col
	var row: int = _cursor_row
	if col >= _config.grid_columns or row >= _config.grid_rows:
		return

	var ore: OreDefinition = _grid[col][row]
	if ore == null:
		return

	# Deal damage
	_hp[col][row] -= ClickerGameState.tap_power

	# Earn dust for every hit
	var earned: float = ClickerGameState.mine_ore(ore)
	if earned > 0.0:
		ClickerSoundPlayer.play_tap()
		_spawn_floating_label(_get_cell_center(col, row), ClickerGameState.format_number(earned))

	_play_break_particles(_get_cell_center(col, row), ore.particle_color)

	if _hp[col][row] <= 0.0:
		# Block destroyed — break it and advance
		_break_tile(col, row, ore)
		_advance_and_move()
	else:
		# Block survived — wait for animation to finish, then unlock input
		player_miner.finish_digging()
		_mining_active = false


## Advance the cursor to the next cell and tween the player there.
func _advance_and_move() -> void:
	_blocks_broken_this_click += 1
	var prev_row: int = _cursor_row
	_cursor_col += 1

	if _cursor_col >= _config.grid_columns:
		_cursor_col = 0
		_cursor_row += 1
		# The previous row is now fully traversed → advance depth
		ClickerGameState.advance_depth()
		row_cleared.emit(ClickerGameState.depth)

	# Grid fully traversed?
	if _cursor_row >= _config.grid_rows:
		_begin_grid_reset()
		return

	# Tween player to next cell
	var target: Vector2 = _get_cell_center(_cursor_col, _cursor_row)
	player_miner.move_to(target, _config.player_move_duration)


## Called when the player's move tween finishes.
func _on_player_move_finished() -> void:
	# Continue multi-block mining?
	if _blocks_broken_this_click < _config.blocks_per_click and _cursor_row < _config.grid_rows:
		_mine_current_block()
	else:
		_mining_active = false


# ── Grid reset ─────────────────────────────────────────────────────────────

func _begin_grid_reset() -> void:
	_cursor_col = 0
	_cursor_row = 0
	_generate_grid()
	_update_depth_progress_bar()
	var start_pos: Vector2 = _get_cell_center(0, 0)
	player_miner.reset_to(start_pos, _config.grid_reset_pause)
	# move_finished will fire from reset_to → _on_player_move_finished unlocks input


# ── Tile / grid helpers ────────────────────────────────────────────────────

func _break_tile(col: int, row: int, ore: OreDefinition) -> void:
	_grid[col][row] = null
	if tile_map_layer.tile_set != null:
		tile_map_layer.erase_cell(Vector2i(col, row))
	var tile_pos: Vector2 = _get_cell_center(col, row)
	tile_broken.emit(ore, tile_pos)
	ClickerSoundPlayer.play_break(ore.value >= 5.0)
	_update_depth_progress_bar()


func _get_cell_center(col: int, row: int) -> Vector2:
	return Vector2(
		col * _config.tile_size + _config.tile_size * 0.5,
		row * _config.tile_size + _config.tile_size * 0.5)


func _snap_player_to_cursor() -> void:
	player_miner.position = _get_cell_center(_cursor_col, _cursor_row)


## Resize the background rect and progress bar to match the grid dimensions.
func _resize_to_grid() -> void:
	var grid_w: float = _config.grid_columns * _config.tile_size
	var grid_h: float = _config.grid_rows * _config.tile_size
	if background_rect:
		background_rect.size = Vector2(grid_w, grid_h)
	if depth_progress_bar:
		depth_progress_bar.offset_left = 0
		depth_progress_bar.offset_top = grid_h - 8
		depth_progress_bar.offset_right = grid_w
		depth_progress_bar.offset_bottom = grid_h


func _is_row_clear(row: int) -> bool:
	for col in _config.grid_columns:
		if _grid[col][row] != null:
			return false
	return true


# ── Grid generation ────────────────────────────────────────────────────────

func _generate_grid() -> void:
	_grid.clear()
	_hp.clear()

	for col in _config.grid_columns:
		_grid.append([])
		_hp.append([])

	for row in _config.grid_rows:
		var depth: int = ClickerGameState.depth + row
		var new_row: Array = ClickerTerrainGenerator.generate_row(depth, _config.grid_columns, _world_seed)
		for col in _config.grid_columns:
			var ore: OreDefinition = new_row[col]
			_grid[col].append(ore)
			_hp[col].append(ore.hardness if ore else 0.0)

	_repaint_tilemap()
	_update_background()
	_update_depth_progress_bar()


func _repaint_tilemap() -> void:
	tile_map_layer.clear()
	if tile_map_layer.tile_set == null:
		return
	for col in _config.grid_columns:
		for row in _config.grid_rows:
			var ore: OreDefinition = _grid[col][row]
			if ore == null:
				continue
			tile_map_layer.set_cell(Vector2i(col, row), _get_source_id(ore), Vector2i.ZERO)


## Returns the TileSet source ID for this ore.
func _get_source_id(ore: OreDefinition) -> int:
	return ore.tileset_source_id


func _update_background() -> void:
	var instruction: ClickerTerrainInstruction = ClickerDataManager.get_terrain_instruction(ClickerGameState.depth)
	if not instruction or not background_rect:
		return
	var target_color: Color = instruction.background_color
	if background_rect.color.is_equal_approx(target_color):
		return
	var tween: Tween = create_tween()
	tween.tween_property(background_rect, "color", target_color, 1.5).set_ease(Tween.EASE_IN_OUT)


func _on_depth_changed(_new_depth: int) -> void:
	_update_background()


func _update_depth_progress_bar() -> void:
	if not depth_progress_bar:
		return
	var empty: int = 0
	for col in _config.grid_columns:
		for row in _config.grid_rows:
			if _grid[col][row] == null:
				empty += 1
	var total: int = _config.grid_columns * _config.grid_rows
	depth_progress_bar.max_value = total
	depth_progress_bar.value = empty


# ── Workers (cosmetic) ─────────────────────────────────────────────────────

func _on_worker_hired(_worker: WorkerDefinition, _new_count: int) -> void:
	_refresh_workers()


func _refresh_workers() -> void:
	var total: int = 0
	for count in ClickerGameState.worker_counts.values():
		total += count
	var target: int = min(total, MAX_VISIBLE_WORKERS)
	while _worker_sprites.size() > target:
		var s = _worker_sprites.pop_back()
		s.queue_free()
	while _worker_sprites.size() < target:
		var s = _worker_sprite_scene.instantiate()
		worker_layer.add_child(s)
		s.setup(_config.grid_columns, _config.grid_rows, _config.tile_size)
		_worker_sprites.append(s)


# ── Visual helpers ─────────────────────────────────────────────────────────

func _spawn_floating_label(pos: Vector2, text: String) -> void:
	if not _floating_label_scene:
		return
	var label: Node = _floating_label_scene.instantiate()
	add_child(label)
	label.global_position = to_global(pos)
	if label.has_method("show_value"):
		label.show_value(text)


func _play_break_particles(pos: Vector2, color: Color) -> void:
	if not break_particles:
		return
	break_particles.global_position = to_global(pos)
	break_particles.modulate = color
	break_particles.restart()
