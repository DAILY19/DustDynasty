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
## Sprite sheet used for the dirt/background tile (16×16, 2× scaled in OreBlock).
@export var block_texture: Texture2D
## Optional crystal overlay spritesheet (horizontal strip, 8 frames × 16px).
## Leave null for blocks with no crystal. Replaces the old crystal_color string.
@export var crystal_texture: Texture2D
## Optional standalone texture for block icon / inventory display.
@export var texture: Texture2D

@export_category("Generation")
## Noise threshold used by ClickerTerrainGenerator to decide placement.
@export var noise_threshold: float = 0.0
## Relative spawn weight for non-noise weighted random selection (editors, future generators).
@export var spawn_weight: float = 1.0
## Background color hint when the majority of the grid is this block.
@export var background_color: Color = Color(0.2, 0.15, 0.1)

@export_category("Audio")
## Sound played on every tap hit. Leave null to use the default tap sound.
@export var tap_sound: AudioStream
## Sound played when the block breaks. Leave null to use the default break sound.
@export var break_sound: AudioStream

## Convenience: the effective dust value taking scale into account.
func get_effective_value() -> float:
	return value * value_scale
