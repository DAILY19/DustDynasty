class_name ClickerTerrainGenerator
extends RefCounted
## Generates grid rows from DiggingViewVariant data — fully data-driven.
## Each variant defines its own block palette, noise, and generation weights.

const TILE_SIZE: int = 32


## Returns a flat array of BlockDefinition (or null for empty) for one grid row.
## Length == columns. null means "no block placed here" (background only).
static func generate_row(variant: DiggingViewVariant, row: int, columns: int, world_seed: int) -> Array:
	if variant == null or variant.blocks.is_empty():
		return _empty_row(columns)

	var result: Array = []
	var noise: FastNoiseLite = variant.noise

	for col in columns:
		var pos := Vector2(col, row)
		var block: BlockDefinition = _pick_block(variant, noise, pos, world_seed)
		result.append(block)

	return result


## Pick the highest-priority block whose noise value passes its threshold.
static func _pick_block(
		variant: DiggingViewVariant,
		noise: FastNoiseLite,
		pos: Vector2,
		world_seed: int) -> BlockDefinition:

	if noise == null:
		return variant.blocks[-1]

	for block in variant.blocks:
		var sample: float = noise.get_noise_2d(pos.x + world_seed * 0.001, pos.y)
		if sample > block.noise_threshold:
			return block

	# Fallback: last entry is always the common filler block
	return variant.blocks[-1]


static func _empty_row(columns: int) -> Array:
	var row: Array = []
	for _i in columns:
		row.append(null)
	return row
