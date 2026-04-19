class_name ClickerTerrainGenerator
extends RefCounted
## Generates grid rows from DiggingViewVariant data — fully data-driven.
## Each variant defines its own block palette, noise, and generation weights.

const TILE_SIZE: int = 32


## Pick a DiggingViewVariant using weighted random selection for the given depth.
static func pick_variant(depth: int) -> DiggingViewVariant:
	var candidates: Array[DiggingViewVariant] = []
	var total_weight: float = 0.0
	for v in ClickerDataManager.digging_variants:
		if v.is_available_at_depth(depth):
			candidates.append(v)
			total_weight += v.weight
	if candidates.is_empty():
		return null
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for v in candidates:
		cumulative += v.weight
		if roll <= cumulative:
			return v
	return candidates[-1]


## Returns a flat array of BlockDefinition (or null for empty) for one grid row.
## Length == columns. null means "no block placed here" (background only).
static func generate_row(variant: DiggingViewVariant, depth: int, columns: int, world_seed: int) -> Array:
	if variant == null or variant.blocks.is_empty():
		return _empty_row(columns)

	var row: Array = []
	var noise: FastNoiseLite = variant.noise

	for col in columns:
		var pos := Vector2(col, depth)
		var block: BlockDefinition = _pick_block(variant, noise, pos, world_seed)
		row.append(block)

	return row


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
