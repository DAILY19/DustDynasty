extends Node2D
## WorkerSprite — animated visual representation of an auto-miner on the digging grid.
## Moves tile-to-tile using tweens and plays a small squash-and-stretch dig animation.
## Instantiated and managed by digging_view.gd in response to worker_hired signal.

var _columns: int = 10
var _rows: int = 15
var _tile_size: int = 32
var _col: int = 0
var _row: int = 0


## Call after add_child() to place the sprite and start movement.
func setup(columns: int, rows: int, tile_size: int) -> void:
	_columns = columns
	_rows = rows
	_tile_size = tile_size
	_col = randi() % _columns
	_row = randi() % _rows
	position = _cell_center(_col, _row)
	_schedule_next_move()


func _cell_center(col: int, row: int) -> Vector2:
	return Vector2(col * _tile_size + _tile_size * 0.5,
				   row * _tile_size + _tile_size * 0.5)


func _schedule_next_move() -> void:
	if not is_inside_tree():
		return
	var delay: float = randf_range(0.4, 1.4)
	await get_tree().create_timer(delay).timeout
	if is_inside_tree():
		_move_to_next_tile()


func _move_to_next_tile() -> void:
	if not is_inside_tree():
		return
	# Step one cell in a random cardinal direction, wrapping at grid edges.
	var directions: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var dir: Vector2i = directions[randi() % directions.size()]
	_col = wrapi(_col + dir.x, 0, _columns)
	_row = wrapi(_row + dir.y, 0, _rows)

	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", _cell_center(_col, _row), 0.2)
	tween.tween_callback(_play_dig_animation)


func _play_dig_animation() -> void:
	if not is_inside_tree():
		return
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.4, 0.6), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.14)
	tween.tween_callback(_schedule_next_move)
