extends HBoxContainer
## UpgradeRow — one row inside ShopPanel for a single UpgradeDefinition.

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var cost_label: Label = %CostLabel
@onready var buy_button: Button = %BuyButton
@onready var description_label: Label = %DescriptionLabel

var _upgrade: UpgradeDefinition


func setup(upgrade: UpgradeDefinition) -> void:
	_upgrade = upgrade
	name_label.text = upgrade.get_display_name()
	description_label.text = upgrade.description
	if upgrade.icon:
		icon_texture.texture = upgrade.icon
	refresh()


func refresh() -> void:
	if _upgrade == null:
		return
	var level: int = ClickerGameState.upgrade_levels.get(_upgrade.name, 0)
	var cost: float = ClickerGameState.get_upgrade_cost(_upgrade)
	var can_afford: bool = ClickerGameState.coins >= cost
	var maxed: bool = level >= _upgrade.max_level
	var unlocked: bool = ClickerGameState.depth >= _upgrade.unlock_depth

	level_label.text = "Lv %d / %d" % [level, _upgrade.max_level]
	cost_label.text = ClickerGameState.format_number(cost)
	buy_button.disabled = not can_afford or maxed or not unlocked
	buy_button.text = "MAX" if maxed else ("LOCKED" if not unlocked else "Buy")
	modulate.a = 0.5 if not unlocked else 1.0


func _on_buy_button_pressed() -> void:
	ClickerGameState.buy_upgrade(_upgrade)
