class_name BlockDefinition
extends MyNamedResource

@export_category("Reward")
## Base dust earned when this block is mined.
@export var value: float = 1.0
## Value multiplier that scales with depth or scene level (applied externally).
@export var value_scale: float = 1.0

@export_category("Durability")
## Number of effective hits to break this block.
@export var hardness: float = 1.0

@export_category("Visual")
## Particle color when this block breaks.
@export var particle_color: Color = Color.WHITE
## TileSet atlas source ID for the TileMapLayer display.
@export var tileset_source_id: int = 0
## Crystal overlay color: "yellow", "green", "blue", "black", or "" for none.
@export var crystal_color: String = ""
## Optional standalone texture for block icon / inventory display.
@export var texture: Texture2D

@export_category("Depth Range")
## Minimum depth where this block can appear.
@export var min_depth: int = 0
## Maximum depth where this block can appear.
@export var max_depth: int = 9999

@export_category("Generation")
## Noise threshold used by ClickerTerrainGenerator to decide placement.
@export var noise_threshold: float = 0.0
## Background color hint when the majority of the grid is this block.
@export var background_color: Color = Color(0.2, 0.15, 0.1)

## Convenience: the effective dust value taking scale into account.
func get_effective_value() -> float:
	return value * value_scale
