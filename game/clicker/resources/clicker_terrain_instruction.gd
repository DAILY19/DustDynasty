class_name ClickerTerrainInstruction
extends DiggingViewVariant
## Legacy alias — ClickerTerrainInstruction is now DiggingViewVariant.
## Existing .tres files that reference ClickerTerrainInstruction continue to work.
## New content should use DiggingViewVariant directly.

## Backing store for the ore_distributions alias.
## Stored here so that .tres files using the old property name load correctly.
@export var ore_distributions: Array[BlockDefinition]


## After the resource is fully loaded, copy ore_distributions -> blocks
## in case the .tres file used the old property name.
func _post_load() -> void:
	if blocks.is_empty() and not ore_distributions.is_empty():
		blocks = ore_distributions
