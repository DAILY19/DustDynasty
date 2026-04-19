extends Node2D
## OreBlock — a single mining cell rendered as a dirt tile with an optional crystal overlay.
## Positioned at the cell centre by DiggingView.
## Call setup(ore) after instantiation to configure the visual.
## Call break_animate() when the block is broken; the node self-frees after the animation.

const CRYSTAL_SHEET_PATH: String = \
	"res://assets/sprites/tilesets/Platformer Series - Tileset #02/Animated Objects/"
const CRYSTAL_TILE_PX: int = 16
const CRYSTAL_FRAME_COUNT: int = 8
const CRYSTAL_FPS: float = 8.0

@onready var dirt_sprite: Sprite2D = $DirtSprite
@onready var crystal_overlay: AnimatedSprite2D = $CrystalOverlay

## Cached SpriteFrames shared across all OreBlock instances.
static var _crystal_frames: SpriteFrames = null


func setup(ore: OreDefinition) -> void:
	if ore.crystal_color == "":
		crystal_overlay.visible = false
		return
	crystal_overlay.sprite_frames = _get_crystal_frames()
	crystal_overlay.visible = true
	crystal_overlay.play(ore.crystal_color)


## Pops up briefly then shrinks to zero and frees the node.
func break_animate() -> void:
	crystal_overlay.stop()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.06)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	tween.tween_callback(queue_free)


static func _get_crystal_frames() -> SpriteFrames:
	if _crystal_frames:
		return _crystal_frames
	_crystal_frames = SpriteFrames.new()
	var crystal_files: Dictionary = {
		"yellow": "PS_Crystal_Yellow_1.png",
		"green":  "PS_Crystal_Green_1.png",
		"blue":   "PS_Crystal_Blue_1.png",
		"black":  "PS_Crystal_Black_1.png",
	}
	for color: String in crystal_files:
		_crystal_frames.add_animation(color)
		_crystal_frames.set_animation_speed(color, CRYSTAL_FPS)
		_crystal_frames.set_animation_loop(color, true)
		var tex: Texture2D = load(CRYSTAL_SHEET_PATH + crystal_files[color])
		for i: int in CRYSTAL_FRAME_COUNT:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * CRYSTAL_TILE_PX, 0, CRYSTAL_TILE_PX, CRYSTAL_TILE_PX)
			_crystal_frames.add_frame(color, atlas)
	return _crystal_frames
