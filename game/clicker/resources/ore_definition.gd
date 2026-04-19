class_name OreDefinition
extends MyNamedResource

@export var texture: Texture2D
@export var value: float = 1.0
@export var hardness: float = 1.0
@export var particle_color: Color = Color.WHITE
@export var noise_threshold: float = 0.0

@export_category("Depth Range")
@export var min_depth: int = 0
@export var max_depth: int = 100

@export_category("Visual")
@export var background_color: Color = Color(0.2, 0.15, 0.1)
## TileSet atlas source ID assigned in the Godot editor when building ClickerTileSet.tres.
## Update this value per-ore after creating the TileSet so digging_view uses the right tile.
@export var tileset_source_id: int = 0
## Crystal overlay color shown on top of the dirt tile for valuable/hard blocks.
## Leave empty for common blocks. Values: "yellow", "green", "blue", "black".
@export var crystal_color: String = ""
