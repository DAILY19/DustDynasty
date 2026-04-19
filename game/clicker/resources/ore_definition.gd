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
