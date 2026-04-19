class_name DiggingViewVariant
extends MyNamedResource

@export_category("Selection")
## Relative probability of this variant being chosen for a new grid.
## Higher weight = more likely. A weight of 0 disables the variant.
@export var weight: float = 1.0
## Minimum depth before this variant can be selected.
@export var min_depth: int = 0
## Maximum depth at which this variant can appear (-1 = unlimited).
@export var max_depth: int = -1

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


## Returns true if this variant is valid for the given depth.
func is_available_at_depth(depth: int) -> bool:
	if weight <= 0.0:
		return false
	if depth < min_depth:
		return false
	if max_depth >= 0 and depth > max_depth:
		return false
	return true
