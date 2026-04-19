class_name PrestigeDefinition
extends MyNamedResource

enum BonusType {
	EARNINGS_MULTIPLIER,
	STARTING_DEPTH,
	WORKER_EFFICIENCY,
	OFFLINE_BONUS,
	TAP_POWER_BONUS,
}

@export var type: BonusType = BonusType.EARNINGS_MULTIPLIER
@export var icon: Texture2D
@export var description: String

@export_category("Effect")
@export var base_multiplier: float = 1.1
@export var cost_per_level: float = 1.0
