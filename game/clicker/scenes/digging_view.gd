extends Node2D
## DiggingView — the main interactive digging area.
## Player traverses the grid in reading order (left→right, top→bottom).
## On grid completion the blocks refill and the player resets to the start.

signal tile_broken(block: BlockDefinition, position: Vector2)
signal row_cleared(depth: int)

## Maximum worker sprites shown at once regardless of total worker count.
const MAX_VISIBLE_WORKERS: int = 8

## Default scenes — set in the Inspector. Variants can override ore_block_scene per-grid.
@export var default_ore_block_scene: PackedScene
@export var default_floating_label_scene: PackedScene
@export var default_worker_sprite_scene: PackedScene

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var background_rect: ColorRect = $BackgroundRect
@onready var break_particles: GPUParticles2D = $BreakParticles
@onready var ore_layer: Node2D = $OreLayer
@onready var worker_layer: Node2D = $WorkerLayer
@onready var player_miner: Node2D = $PlayerMiner

## Indexed [col][row] -> BlockDefinition (null = empty/broken)
var _grid: Array = []
## HP remaining per cell: indexed [col][row]
var _hp: Array = []
## Spawned OreBlock nodes indexed by cell position.
var _ore_blocks: Dictionary = {}  # Vector2i -> Node2D
## World seed for noise variation
var _world_seed: int = 0
## Current digging view variant (picked per grid reset).
var _current_variant: DiggingViewVariant = null

var _config: ClickerConfig
## Resolved at runtime — either variant override or the exported default.
var _ore_block_scene: PackedScene
var _worker_sprites: Array = []

# ── Traversal state ────────────────────────────────────────────────────────
var _cursor_col: int = 0
var _cursor_row: int = 0
var _blocks_broken_this_click: int = 0
var _mining_active: bool = false
## Watchdog: seconds _mining_active has been true without resolution.
var _mining_stuck_timer: float = 0.0
const MINING_STUCK_THRESHOLD: float = 2.0


func _ready() -> void:
	_config = ClickerDataManager.config
	_world_seed = randi()
	# Fall back to hard-coded paths when the Inspector exports are not set.
	if not default_ore_block_scene:
		default_ore_block_scene = load("res://game/clicker/scenes/ore_block.tscn")
	if not default_floating_label_scene:
		default_floating_label_scene = load("res://game/clicker/scenes/floating_label.tscn")
	if not default_worker_sprite_scene:
		default_worker_sprite_scene = load("res://game/clicker/scenes/worker_sprite.tscn")
	ClickerGameState.area_changed.connect(_on_area_changed)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	player_miner.hit_frame.connect(_on_player_hit_frame)
	player_miner.move_finished.connect(_on_player_move_finished)
	_resize_to_grid()
	_generate_grid()
	_refresh_workers()
	_snap_player_to_cursor()


# ── Watchdog ──────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _mining_active:
		_mining_stuck_timer += delta
		if _mining_stuck_timer >= MINING_STUCK_THRESHOLD:
			push_error("DiggingView: _mining_active stuck for %.1fs — forcing unlock" % _mining_stuck_timer)
			player_miner.finish_digging()
			_mining_active = false
			_mining_stuck_timer = 0.0
	else:
		_mining_stuck_timer = 0.0


# ── Input ──────────────────────────────────────────────────────────────────
# _unhandled_input only fires when no GUI control (button, panel, etc.)
# has already consumed the event, so no guard is needed here.

func _unhandled_input(event: InputEvent) -> void:
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
	if _cursor_col >= _config.grid_columns or _cursor_row >= _config.grid_rows:
		push_error("DiggingView: _mine_current_block cursor OOB (%d,%d)" % [_cursor_col, _cursor_row])
		_mining_active = false
		return
	# Skip null cells (shouldn't happen in normal flow, but defensive)
	if _grid[_cursor_col][_cursor_row] == null:
		_advance_and_move()
		return
	if player_miner.state != player_miner.State.IDLE:
		push_warning("DiggingView: player_miner not IDLE (state=%d) before start_digging — skipping" % player_miner.state)
		_mining_active = false
		return
	player_miner.start_digging()


## Called when the pickaxe animation reaches the impact frame.
func _on_player_hit_frame() -> void:
	var col: int = _cursor_col
	var row: int = _cursor_row
	if col >= _config.grid_columns or row >= _config.grid_rows:
		push_warning("DiggingView: hit_frame fired with cursor OOB (%d,%d) — unlocking" % [col, row])
		player_miner.finish_digging()
		_mining_active = false
		return

	var block: BlockDefinition = _grid[col][row]
	if block == null:
		push_warning("DiggingView: hit_frame fired on null block at (%d,%d) — unlocking" % [col, row])
		player_miner.finish_digging()
		_mining_active = false
		return

	# Deal damage
	_hp[col][row] -= ClickerGameState.tap_power

	# Earn dust for every hit
	var earned: float = ClickerGameState.mine_block(block)
	if earned > 0.0:
		if block.tap_sound:
			ClickerSoundPlayer.play_stream(block.tap_sound)
		else:
			ClickerSoundPlayer.play_tap()
		_spawn_floating_label(_get_cell_center(col, row), ClickerGameState.format_number(earned))

	_play_break_particles(_get_cell_center(col, row), block.particle_color)

	if _hp[col][row] <= 0.0:
		# Block destroyed — break it and advance
		_break_tile(col, row, block)
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
		row_cleared.emit(_cursor_row)

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

func _break_tile(col: int, row: int, block: BlockDefinition) -> void:
	_grid[col][row] = null
	var cell := Vector2i(col, row)
	if _ore_blocks.has(cell):
		_ore_blocks[cell].break_animate()
		_ore_blocks.erase(cell)
	if tile_map_layer.tile_set != null:
		tile_map_layer.erase_cell(cell)
	var tile_pos: Vector2 = _get_cell_center(col, row)
	tile_broken.emit(block, tile_pos)
	if block.break_sound:
		ClickerSoundPlayer.play_stream(block.break_sound)
	else:
		ClickerSoundPlayer.play_break(block.get_effective_value() >= 5.0)
	_update_depth_progress_bar()


func _get_cell_center(col: int, row: int) -> Vector2:
	return Vector2(
		col * _config.tile_size + _config.tile_size * 0.5,
		row * _config.tile_size + _config.tile_size * 0.5)


func _snap_player_to_cursor() -> void:
	player_miner.position = _get_cell_center(_cursor_col, _cursor_row)


## Resize the background rect to match the grid dimensions.
func _resize_to_grid() -> void:
	var grid_w: float = _config.grid_columns * _config.tile_size
	var grid_h: float = _config.grid_rows * _config.tile_size
	if background_rect:
		background_rect.size = Vector2(grid_w, grid_h)


func _is_row_clear(row: int) -> bool:
	for col in _config.grid_columns:
		if _grid[col][row] != null:
			return false
	return true


# ── Grid generation ────────────────────────────────────────────────────────

func _generate_grid() -> void:
	_grid.clear()
	_hp.clear()

	# Use the currently selected area, falling back to the first registered variant.
	_current_variant = ClickerGameState.current_area
	if _current_variant == null and not ClickerDataManager.digging_variants.is_empty():
		_current_variant = ClickerDataManager.digging_variants[0]
	_ore_block_scene = (_current_variant.ore_block_scene
		if _current_variant and _current_variant.ore_block_scene
		else default_ore_block_scene)

	for col in _config.grid_columns:
		_grid.append([])
		_hp.append([])

	for row in _config.grid_rows:
		var terrain_depth: int = row  # row index within the current area (no global depth)
		var new_row: Array = ClickerTerrainGenerator.generate_row(_current_variant, terrain_depth, _config.grid_columns, _world_seed)
		for col in _config.grid_columns:
			var block: BlockDefinition = new_row[col]
			_grid[col].append(block)
			_hp[col].append(block.hardness if block else 0.0)

	_spawn_ore_blocks()
	_update_background()
	_update_depth_progress_bar()


func _repaint_tilemap() -> void:
	tile_map_layer.clear()
	if tile_map_layer.tile_set == null:
		return
	for col in _config.grid_columns:
		for row in _config.grid_rows:
			var block: BlockDefinition = _grid[col][row]
			if block == null:
				continue
			tile_map_layer.set_cell(Vector2i(col, row), block.tileset_source_id, Vector2i.ZERO)


func _spawn_ore_blocks() -> void:
	# Free any blocks that weren't broken during normal mining (e.g. on grid reset).
	for block in _ore_blocks.values():
		if is_instance_valid(block):
			block.queue_free()
	_ore_blocks.clear()

	for col in _config.grid_columns:
		for row in _config.grid_rows:
			var block: BlockDefinition = _grid[col][row]
			if block == null:
				continue
			var ore_block: Node2D = _ore_block_scene.instantiate()
			ore_layer.add_child(ore_block)
			ore_block.position = _get_cell_center(col, row)
			ore_block.setup(block)
			_ore_blocks[Vector2i(col, row)] = ore_block


func _update_background() -> void:
	if not background_rect or not _current_variant:
		return
	var target_color: Color = _current_variant.background_color
	if background_rect.color.is_equal_approx(target_color):
		return
	var tween: Tween = create_tween()
	tween.tween_property(background_rect, "color", target_color, 1.5).set_ease(Tween.EASE_IN_OUT)


func _on_area_changed(_area: DiggingViewVariant) -> void:
	_world_seed = randi()  # new seed so the grid looks different
	_generate_grid()
	_snap_player_to_cursor()


func _update_depth_progress_bar() -> void:
	pass  # DepthProgressBar node removed from scene


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
		var s = default_worker_sprite_scene.instantiate()
		worker_layer.add_child(s)
		s.setup(_config.grid_columns, _config.grid_rows, _config.tile_size)
		_worker_sprites.append(s)


# ── Visual helpers ─────────────────────────────────────────────────────────

func _spawn_floating_label(pos: Vector2, text: String) -> void:
	if not default_floating_label_scene:
		return
	var label: Node = default_floating_label_scene.instantiate()
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
