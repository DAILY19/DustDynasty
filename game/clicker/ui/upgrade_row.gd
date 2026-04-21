extends PanelContainer
## UpgradeRow — one row inside ShopPanel for a single UpgradeDefinition.

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var cost_label: Label = %CostLabel
@onready var buy_button: Button = %BuyButton
@onready var description_label: Label = %DescriptionLabel

var _upgrade: UpgradeDefinition


func _ready() -> void:
	add_theme_stylebox_override("panel", UIStyle.make_row_bg())
	name_label.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	description_label.add_theme_color_override("font_color", UIStyle.TEXT_DIM)
	level_label.add_theme_color_override("font_color", UIStyle.TEXT_DIM)
	cost_label.add_theme_color_override("font_color", UIStyle.GOLD_ACCENT)
	buy_button.add_theme_stylebox_override("normal", UIStyle.make_button_normal())
	buy_button.add_theme_stylebox_override("hover", UIStyle.make_button_hover())
	buy_button.add_theme_stylebox_override("pressed", UIStyle.make_button_pressed())
	buy_button.pressed.connect(_on_buy_button_pressed)


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
	var can_afford: bool = ClickerGameState.dust >= cost
	var maxed: bool = level >= _upgrade.max_level

	level_label.text = "Lv %d / %d" % [level, _upgrade.max_level]
	cost_label.text = ClickerGameState.format_number(cost)
	buy_button.disabled = not can_afford or maxed
	buy_button.text = "MAX" if maxed else "Buy"
	modulate.a = 1.0


func _on_buy_button_pressed() -> void:
	ClickerGameState.buy_upgrade(_upgrade)
