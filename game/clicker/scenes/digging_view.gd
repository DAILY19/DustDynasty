extends Node2D
## DiggingView — the main interactive digging area.
## A TileMapLayer is populated procedurally per row using ClickerTerrainGenerator.
## Tapping/clicking a tile mines it; breaking it earns coins and may advance depth.

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


func _ready() -> void:
	_config = ClickerDataManager.config
	_floating_label_scene = load(BREAK_LABEL_SCENE)
	_worker_sprite_scene = load(WORKER_SPRITE_SCENE)
	_world_seed = randi()
	ClickerGameState.depth_changed.connect(_on_depth_changed)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	_generate_visible_rows()
	_refresh_workers()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_tap(get_local_mouse_position())
	elif event is InputEventScreenTouch and event.pressed:
		_handle_tap(to_local(event.position))


func _handle_tap(local_pos: Vector2) -> void:
	var col: int = int(local_pos.x / _config.tile_size)
	var row: int = int(local_pos.y / _config.tile_size)
	if col < 0 or col >= _config.grid_columns or row < 0 or row >= _config.grid_rows:
		return

	var ore: OreDefinition = _grid[col][row]
	if ore == null:
		return

	var earned: float = ClickerGameState.try_tap(ore)
	if earned <= 0.0:
		return

	ClickerSoundPlayer.play_tap()
	_hp[col][row] -= ClickerGameState.tap_power
	_spawn_floating_label(local_pos, ClickerGameState.format_number(earned))
	_play_break_particles(local_pos, ore.particle_color)

	if _hp[col][row] <= 0.0:
		_break_tile(col, row, ore)


func _break_tile(col: int, row: int, ore: OreDefinition) -> void:
	_grid[col][row] = null
	tile_map_layer.erase_cell(Vector2i(col, row))
	tile_broken.emit(ore, tile_map_layer.map_to_local(Vector2i(col, row)))
	ClickerSoundPlayer.play_break(ore.value >= 5.0)
	_update_depth_progress_bar()

	if _is_row_clear(row):
		row_cleared.emit(ClickerGameState.depth + row)
		ClickerGameState.advance_depth()
		_shift_rows_up()


func _is_row_clear(row: int) -> bool:
	for col in _config.grid_columns:
		if _grid[col][row] != null:
			return false
	return true


func _shift_rows_up() -> void:
	# Remove top row data, shift everything up, generate new bottom row
	for col in _config.grid_columns:
		_grid[col].pop_front()
		_hp[col].pop_front()

	tile_map_layer.clear()
	var new_depth: int = ClickerGameState.depth + _config.grid_rows - 1
	var new_row: Array = ClickerTerrainGenerator.generate_row(new_depth, _config.grid_columns, _world_seed)

	for col in _config.grid_columns:
		var ore: OreDefinition = new_row[col]
		_grid[col].append(ore)
		_hp[col].append(ore.hardness if ore else 0.0)

	_repaint_tilemap()
	_update_background()
	_update_depth_progress_bar()


func _generate_visible_rows() -> void:
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
	for col in _config.grid_columns:
		for row in _config.grid_rows:
			var ore: OreDefinition = _grid[col][row]
			if ore == null:
				continue
			# Use atlas coords sourced from the ore texture; source 0 covers all ores
			# The actual TileSet is configured in the editor
			tile_map_layer.set_cell(Vector2i(col, row), _get_source_id(ore), Vector2i.ZERO)


## Returns the TileSet source ID for this ore.
## Configured per-ore in each .tres registry file via the tileset_source_id field.
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


func _on_worker_hired(_worker: WorkerDefinition, _new_count: int) -> void:
	_refresh_workers()


## Sync the number of visible WorkerSprites to the total workers hired
## (capped at MAX_VISIBLE_WORKERS for performance).
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
