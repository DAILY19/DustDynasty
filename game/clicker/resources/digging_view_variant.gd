class_name DiggingViewVariant
extends MyNamedResource

@export_category("Identity")
## Display name shown in the area-select UI.
@export var area_name: String = ""
## Dust cost to unlock this area. 0 = unlocked from the start (starter area).
@export var purchase_cost: float = 0.0
## Sort order for the area picker (lower index appears first).
@export var sort_index: int = 0

@export_category("Block Palette")
## Ordered list of blocks available in this variant.
## Terrain generation picks from this list via noise thresholds.
@export var blocks: Array[BlockDefinition]

@export_category("Visual Theme")
## Background color for the digging area when this variant is active.
@export var background_color: Color = Color(0.12, 0.08, 0.05)
## Optional ore block scene override (null = use default ore_block.tscn).
@export var ore_block_scene: PackedScene
## Optional player miner scene override (null = use default player_miner.tscn).
@export var player_miner_scene: PackedScene

@export_category("Generation")
## Noise resource for block placement within this variant.
@export var noise: FastNoiseLite


## True if this variant is the starter (free) area.
func is_starter() -> bool:
	return purchase_cost <= 0.0
