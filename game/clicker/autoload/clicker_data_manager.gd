extends Node
## ClickerDataManager — loads all clicker registries from their folders.
## Add new content by dropping .tres files into the registry directories.
## No code changes required for new ores, upgrades, workers, or prestige bonuses.

@export_dir var ores_path: String
@export_dir var upgrades_path: String
@export_dir var workers_path: String
@export_dir var prestige_path: String
@export_dir var areas_path: String

@export var config: ClickerConfig
## Explicit area references loaded unconditionally — bypasses DirAccess for web compatibility.
@export var areas: Array[Resource]

var ores: Array[OreDefinition]
var upgrades: Array[UpgradeDefinition]
var workers: Array[WorkerDefinition]
var prestige_bonuses: Array[PrestigeDefinition]
var terrain_instructions: Array[ClickerTerrainInstruction]
var digging_variants: Array[DiggingViewVariant]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_load_all()


func _load_all() -> void:
	for item in _load_resource_array(ores_path):
		ores.append(item)
	for item in _load_resource_array(upgrades_path):
		upgrades.append(item)
	for item in _load_resource_array(workers_path):
		workers.append(item)
	for item in _load_resource_array(prestige_path):
		prestige_bonuses.append(item)
	for item in _load_resource_array(areas_path):
		terrain_instructions.append(item)

	# Merge explicit area references first — these are guaranteed on web where DirAccess may fail.
	for area in areas:
		if area is DiggingViewVariant and area not in digging_variants:
			digging_variants.append(area as DiggingViewVariant)

	# Merge anything the dynamic scan picked up that isn't already present.
	for ti in terrain_instructions:
		if ti not in digging_variants:
			digging_variants.append(ti)

	# Sort by sort_index for consistent area ordering
	digging_variants.sort_custom(func(a, b): return a.sort_index < b.sort_index)


func _load_resource_array(folder: String) -> Array:
	if folder.is_empty():
		return []
	var result: Array = []
	for file_path in Utils.load_directory_recursively(folder):
		if file_path.ends_with(".tres"):
			var resource = load(file_path)
			if resource != null:
				result.append(resource)
			else:
				push_warning("ClickerDataManager: failed to load '%s'" % file_path)
	return result
