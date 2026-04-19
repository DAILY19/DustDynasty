class_name ClickerTerrainGenerator
extends RefCounted
## Populates a TileMapLayer with procedural ore tiles for a given depth row.
## Reads ClickerTerrainInstruction registry data — no hardcoded values.

const TILE_SIZE: int = 32

## Returns a flat array of OreDefinition (or null for empty) for one grid row.
## Length == columns. null means "no ore placed here" (background only).
static func generate_row(depth: int, columns: int, world_seed: int) -> Array:
	var instruction: ClickerTerrainInstruction = ClickerDataManager.get_terrain_instruction(depth)
	if instruction == null or instruction.ore_distributions.is_empty():
		return _empty_row(columns)

	var row: Array = []
	var noise: FastNoiseLite = instruction.noise

	for col in columns:
		var pos := Vector2(col, depth)
		var ore: OreDefinition = _pick_ore(instruction, noise, pos, world_seed)
		row.append(ore)

	return row


## Pick the highest-priority ore whose noise value passes its threshold.
static func _pick_ore(
		instruction: ClickerTerrainInstruction,
		noise: FastNoiseLite,
		pos: Vector2,
		world_seed: int) -> OreDefinition:

	if noise == null:
		return instruction.ore_distributions[-1]

	for ore in instruction.ore_distributions:
		var sample: float = noise.get_noise_2d(pos.x + world_seed * 0.001, pos.y)
		if sample > ore.noise_threshold:
			return ore

	# Fallback: last entry is always the common filler block
	return instruction.ore_distributions[-1]


static func _empty_row(columns: int) -> Array:
	var row: Array = []
	for _i in columns:
		row.append(null)
	return row
