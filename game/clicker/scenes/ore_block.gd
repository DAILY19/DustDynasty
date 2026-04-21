extends Node2D
## OreBlock — a single mining cell rendered as a block tile with an optional crystal overlay.
## Positioned at the cell centre by DiggingView.
## Call setup(block) after instantiation to configure the visual.
## Call break_animate() when the block is broken; the node self-frees after the animation.

const CRYSTAL_TILE_PX: int = 16
const CRYSTAL_FRAME_COUNT: int = 8
const CRYSTAL_FPS: float = 8.0

@onready var dirt_sprite: Sprite2D = $DirtSprite
@onready var crystal_overlay: AnimatedSprite2D = $CrystalOverlay

## Per-texture SpriteFrames cache so each unique crystal sheet is built once.
static var _crystal_cache: Dictionary = {}  # Texture2D -> SpriteFrames


func setup(block: BlockDefinition) -> void:
	# ── Block background sprite ───────────────────────────────────────────
	if block.block_texture:
		dirt_sprite.texture = block.block_texture
		dirt_sprite.region_enabled = false
	elif block.texture:
		dirt_sprite.texture = block.texture
		dirt_sprite.region_enabled = false

	# ── Crystal overlay ────────────────────────────────────────────────────
	if block.crystal_texture == null:
		crystal_overlay.visible = false
		return
	crystal_overlay.sprite_frames = _get_crystal_frames(block.crystal_texture)
	crystal_overlay.visible = true
	crystal_overlay.play("default")


## Pops up briefly then shrinks to zero and frees the node.
func break_animate() -> void:
	crystal_overlay.stop()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.06)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	tween.tween_callback(queue_free)


## Build (or return cached) SpriteFrames for a horizontal crystal strip texture.
static func _get_crystal_frames(sheet: Texture2D) -> SpriteFrames:
	if _crystal_cache.has(sheet):
		return _crystal_cache[sheet]
	var frames := SpriteFrames.new()
	frames.add_animation("default")
	frames.set_animation_speed("default", CRYSTAL_FPS)
	frames.set_animation_loop("default", true)
	for i: int in CRYSTAL_FRAME_COUNT:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * CRYSTAL_TILE_PX, 0, CRYSTAL_TILE_PX, CRYSTAL_TILE_PX)
		frames.add_frame("default", atlas)
	_crystal_cache[sheet] = frames
	return frames
