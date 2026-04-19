class_name DepthMilestone
extends MyNamedResource

## A hand-designed milestone level shown at a specific depth.
## The milestone scene is a TileMapLayer scene designed in the editor.

@export var depth: int = 0
@export var milestone_scene: PackedScene
@export var unlock_text: String
@export var reward_coins: float = 0.0
@export var reward_prestige_currency: float = 0.0
