extends Node
## ClickerDataManager — loads all clicker registries from their folders.
## Add new content by dropping .tres files into the registry directories.
## No code changes required for new ores, upgrades, workers, or prestige bonuses.

@export_dir var ores_path: String
@export_dir var blocks_path: String
@export_dir var upgrades_path: String
@export_dir var workers_path: String
@export_dir var prestige_path: String
@export_dir var terrain_path: String
@export_dir var digging_variants_path: String
@export_dir var milestones_path: String
@export_dir var crafting_recipes_path: String

@export var config: ClickerConfig

var ores: Array[OreDefinition]
var blocks: Array[BlockDefinition]
var upgrades: Array[UpgradeDefinition]
var workers: Array[WorkerDefinition]
var prestige_bonuses: Array[PrestigeDefinition]
var terrain_instructions: Array[ClickerTerrainInstruction]
var digging_variants: Array[DiggingViewVariant]
var milestones: Array[DepthMilestone]
var crafting_recipes: Array[CraftingRecipe]

## Lookup: depth -> DepthMilestone (built after loading)
var milestones_by_depth: Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_load_all()


func _load_all() -> void:
	_load_resource_array(ores_path, ores)
	_load_resource_array(blocks_path, blocks)
	_load_resource_array(upgrades_path, upgrades)
	_load_resource_array(workers_path, workers)
	_load_resource_array(prestige_path, prestige_bonuses)
	_load_resource_array(terrain_path, terrain_instructions)
	_load_resource_array(digging_variants_path, digging_variants)
	_load_resource_array(milestones_path, milestones)
	_load_resource_array(crafting_recipes_path, crafting_recipes)

	# Merge legacy terrain instructions into digging_variants if both exist
	for ti in terrain_instructions:
		if ti not in digging_variants:
			digging_variants.append(ti)

	# Sort terrain instructions by min_depth so layering is predictable
	terrain_instructions.sort_custom(func(a, b): return a.min_depth < b.min_depth)

	# Sort variants by min_depth as well
	digging_variants.sort_custom(func(a, b): return a.min_depth < b.min_depth)

	# Sort milestones by depth
	milestones.sort_custom(func(a, b): return a.depth < b.depth)

	# Build milestone lookup
	for milestone in milestones:
		milestones_by_depth[milestone.depth] = milestone


func _load_resource_array(folder: String, array: Array) -> void:
	if folder.is_empty():
		return
	for file_path in Utils.load_directory_recursively(folder):
		if file_path.ends_with(".tres"):
			array.append(load(file_path))


## Returns the ClickerTerrainInstruction active at the given depth.
## Falls back to the last instruction if depth exceeds all ranges.
func get_terrain_instruction(depth: int) -> ClickerTerrainInstruction:
	var result: ClickerTerrainInstruction = null
	for instruction in terrain_instructions:
		if depth >= instruction.min_depth:
			result = instruction
		else:
			break
	return result


## Returns the DiggingViewVariant active at the given depth (weighted random).
func get_variant_for_depth(depth: int) -> DiggingViewVariant:
	return ClickerTerrainGenerator.pick_variant(depth)


## Returns all blocks valid at the given depth (min_depth <= depth <= max_depth).
func get_blocks_for_depth(depth: int) -> Array[BlockDefinition]:
	var result: Array[BlockDefinition] = []
	for block in blocks:
		if depth >= block.min_depth and depth <= block.max_depth:
			result.append(block)
	return result


## Returns the DepthMilestone at exactly this depth, or null.
func get_milestone(depth: int) -> DepthMilestone:
	return milestones_by_depth.get(depth, null)


## Returns ores valid at the given depth (min_depth <= depth <= max_depth).
func get_ores_for_depth(depth: int) -> Array[OreDefinition]:
	var result: Array[OreDefinition] = []
	for ore in ores:
		if depth >= ore.min_depth and depth <= ore.max_depth:
			result.append(ore)
	return result
