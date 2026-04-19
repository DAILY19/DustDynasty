class_name ClickerTerrainInstruction
extends DiggingViewVariant
## Legacy alias — ClickerTerrainInstruction is now DiggingViewVariant.
## Existing .tres files that reference ClickerTerrainInstruction continue to work.
## New content should use DiggingViewVariant directly.

## Backward-compatible alias for DiggingViewVariant.blocks.
@export var ore_distributions: Array[BlockDefinition]:
	get:
		return blocks
	set(value):
		blocks = value
