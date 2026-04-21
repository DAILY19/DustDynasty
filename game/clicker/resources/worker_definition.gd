class_name WorkerDefinition
extends MyNamedResource

@export var icon: Texture2D
@export var description: String

@export_category("Cost")
@export var base_cost: float = 50.0
@export var cost_scaling: float = 1.15

@export_category("Output")
@export var dig_power: float = 1.0
@export var dig_speed: float = 1.0


