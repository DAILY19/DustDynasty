class_name ClickerTerrainInstruction
extends Resource

## One procedural layer rule for the clicker digging view.
## Instructions are sorted by min_depth and applied in order.
## The first instruction whose depth range contains the current depth wins.

@export var min_depth: int = 0
@export var max_depth: int = 100

## Ordered list of ores to try. Each ore is placed if noise > its noise_threshold.
## Falls back to the last entry if no ore matches.
@export var ore_distributions: Array[OreDefinition]

## FastNoiseLite used to vary ore placement within this layer.
@export var noise: FastNoiseLite

## Tile used to draw unbreakable background walls (behind ores).
@export var background_color: Color = Color(0.12, 0.08, 0.05)
