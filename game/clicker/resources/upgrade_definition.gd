class_name UpgradeDefinition
extends MyNamedResource

enum UpgradeType {
	TAP_POWER,
	TAP_SPEED,
	CRIT_CHANCE,
	CRIT_MULTIPLIER,
	ORE_VALUE_BONUS,
	OFFLINE_RATE,
}

@export var type: UpgradeType = UpgradeType.TAP_POWER
@export var icon: Texture2D
@export var description: String

@export_category("Cost")
@export var base_cost: float = 10.0
@export var cost_scaling: float = 1.5

@export_category("Effect")
@export var effect_per_level: float = 1.0
@export var max_level: int = 50


